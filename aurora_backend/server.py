import asyncio
import logging
import httpx
import redis.asyncio as redis
from typing import List, Dict, Any
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect, Depends
from fastapi.middleware.cors import CORSMiddleware
try:
    from fastapi_limiter import FastAPILimiter
    HAS_LIMITER = True
except ImportError:
    HAS_LIMITER = False
from pydantic import BaseModel
from sqlalchemy.orm import Session

from database import engine, Base, get_db
import models
from agents.supervisor_agent import SupervisorAgent
from agents.knowledge_agent import KnowledgeRetrievalAgent

# Init Database
Base.metadata.create_all(bind=engine)

app = FastAPI(title="AURORA Antigravity API v3", version="3.0")

@app.on_event("startup")
async def startup():
    if HAS_LIMITER:
        try:
            redis_conn = redis.from_url("redis://localhost", encoding="utf-8", decode_responses=True)
            await FastAPILimiter.init(redis_conn)
        except Exception:
            # Fallback if Redis is not available locally
            pass


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

supervisor = SupervisorAgent()
knowledge_agent = KnowledgeRetrievalAgent()

# WebSockets Connection Manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except Exception:
                pass

manager = ConnectionManager()

# Models
class SignalPayload(BaseModel):
    signals: List[Dict[str, Any]]

class ChatPayload(BaseModel):
    question: str
    image_base64: str | None = None


class ResourcePayload(BaseModel):
    name: str
    task: str
    callsign: str
    type_icon: str
    eta_minutes: int
    color_hex: str

class UserCreate(BaseModel):
    username: str
    password: str
    role: str = "agent"

class Token(BaseModel):
    access_token: str
    token_type: str

SECRET_KEY = "aurora-super-secret-key-titan"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

import bcrypt
from jose import JWTError, jwt
from datetime import datetime, timedelta
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False

def get_password_hash(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=401,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(models.User).filter(models.User.username == username).first()
    if user is None:
        raise credentials_exception
    return user

@app.post("/api/v1/auth/register", response_model=Token)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.username == user.username).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    hashed_password = get_password_hash(user.password)
    db_user = models.User(username=user.username, hashed_password=hashed_password, role=user.role)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    access_token = create_access_token(data={"sub": db_user.username, "role": db_user.role})
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/api/v1/auth/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect username or password", headers={"WWW-Authenticate": "Bearer"})
    access_token = create_access_token(data={"sub": user.username, "role": user.role}, expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    return {"access_token": access_token, "token_type": "bearer"}

@app.websocket("/ws/stream")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            # We wait for client pings or we just keep the connection alive
            data = await websocket.receive_text()
            await manager.broadcast(f"Client message: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket)

@app.post("/api/v1/analyze-crisis")
async def analyze_crisis(payload: SignalPayload):
    try:
        result = supervisor.process_signals(payload.signals)
        # Broadcast traces instantly to all connected WebSocket clients
        for trace in result["trace"]:
            if trace:
                await manager.broadcast(trace)
        return {"status": "success", "crisis": result["crisis"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/chat")
async def chat_knowledge(payload: ChatPayload):
    try:
        answer = knowledge_agent.query(payload.question, payload.image_base64)
        return {"answer": answer}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/resources")
def get_resources(db: Session = Depends(get_db)):
    units = db.query(models.ResourceUnit).all()
    # Seed if empty
    if not units:
        seed_data = [
            models.ResourceUnit(name="USAF Drone Fleet Alpha", task="Visual Verification", callsign="DRN-US", type_icon="flight", eta_minutes=3, color_hex="0xFF00E5FF"),
            models.ResourceUnit(name="UN Peacekeepers", task="Logistics Blockade", callsign="UN-11", type_icon="local_police", eta_minutes=8, color_hex="0xFF448AFF"),
        ]
        db.add_all(seed_data)
        db.commit()
        units = db.query(models.ResourceUnit).all()
    return units

@app.post("/api/v1/resources")
def create_resource(unit: ResourcePayload, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.role.lower() != "commander":
        raise HTTPException(status_code=403, detail="Only Commanders can deploy resources")
        
    db_unit = models.ResourceUnit(
        name=unit.name,
        task=unit.task,
        callsign=unit.callsign,
        type_icon=unit.type_icon,
        eta_minutes=unit.eta_minutes,
        color_hex=unit.color_hex
    )
    db.add(db_unit)
    db.commit()
    db.refresh(db_unit)
    return db_unit

@app.get("/api/v1/crises/live")
async def get_live_crises():
    """Fetch live crisis data from USGS Earthquake API and combine with simulation"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson", timeout=5.0)
            if response.status_code == 200:
                data = response.json()
                features = data.get("features", [])
                crises = []
                for f in features:
                    props = f.get("properties", {})
                    geom = f.get("geometry", {})
                    coords = geom.get("coordinates", [0, 0])
                    crises.append({
                        "name": props.get("title", "Unknown Event"),
                        "loc": [coords[1], coords[0]], # Lat, Lng
                        "type": "earthquake",
                        "magnitude": props.get("mag", 0),
                        "url": props.get("url", ""),
                    })
                return {"status": "success", "crises": crises}
            else:
                return {"status": "error", "message": "USGS API returned non-200"}
    except Exception as e:
        return {"status": "error", "message": str(e)}

@app.get("/api/v1/health")
async def health_check():
    return {"status": "AURORA V3 TITAN CLUSTER LIVE"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
