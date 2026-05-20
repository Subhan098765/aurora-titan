# AURORA V3 "Titan"

Aurora is a World Crisis Response Network powered by Flutter, FastAPI, and Gemini AI. It provides real-time situational awareness and resource deployment management using intelligent agents.

## Architecture
- **Frontend (Mobile)**: Flutter 3 with Riverpod for state management and get_it for dependency injection.
- **Backend (API)**: FastAPI with SQLite and SQLAlchemy.
- **AI Engine**: Google Gemini via Python SDK for live crisis analysis and RAG-lite chat.
- **Real-Time Data**: WebSocket streaming via FastAPI for real-time log ingestion.

## Setup Instructions

### 1. Backend Setup
The backend requires Python 3.12+ and Redis (optional for rate-limiting).

#### Run Locally
```bash
cd aurora_backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn server:app --host 0.0.0.0 --port 8000 --reload
```

#### Run with Docker
```bash
cd aurora_backend
docker-compose up -d --build
```

### 2. Frontend Setup
Make sure you have Flutter SDK installed.

```bash
cd aurora
flutter pub get
flutter run
```

## Features
- **Global Dashboard**: See key metrics and live updates.
- **Live Agents**: Monitor AI agents orchestrating responses via WebSockets.
- **Resource Deployment**: Deploy resources in real-time.
- **AI Copilot**: Ask questions to the Gemini-powered AI assistant.
- **System Terminal**: Watch the stream of logs sent from the backend in real-time.
