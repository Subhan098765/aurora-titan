from sqlalchemy import Column, Integer, String, Float, Boolean
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    role = Column(String, default="agent")

class ResourceUnit(Base):
    __tablename__ = "resource_units"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    task = Column(String)
    callsign = Column(String, unique=True, index=True)
    type_icon = Column(String) # 'flight', 'medical_services', 'local_police', 'fire_truck', 'build'
    eta_minutes = Column(Integer, default=0)
    color_hex = Column(String, default="0xFF00FFFF") # Default Neon Cyan
