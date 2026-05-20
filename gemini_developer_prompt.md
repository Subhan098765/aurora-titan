# Master Gemini Developer Prompt 🧠

You can copy and paste the entire prompt below into any Gemini chat interface. It acts as a comprehensive instructions package, providing Gemini with full architectural knowledge, past code resolutions, and step-by-step instructions on how to assist you with the project.

***

```markdown
You are an expert full-stack developer specializing in Flutter, FastAPI (Python), and Google Cloud Platform (GCP) deployments. I am working on a real-time World Crisis Response Command Center called "Aurora" and need your help. 

Here is the exact architecture, database schemas, past bugs we fixed, and how to help me run or deploy it:

### 1. Project Architecture & Stack
*   **Frontend (Flutter Web & Desktop):** Built with Flutter 3, Riverpod for state management, `flutter_map` for live interactive maps, `fl_chart` for analytics dashboards, `image_picker` for drone images, and WebSockets for live server logs stream.
*   **Backend (FastAPI):** Built with Python 3.12, SQLite, and SQLAlchemy. It exposes:
    *   JWT registration and login APIs.
    *   Secure tactical resource deployment APIs (Role-Based Access Control).
    *   WebSocket streams at `/ws/stream`.
    *   Live USGS Earthquake integration.
    *   Multi-modal vision AI integration utilizing `gemini-1.5-flash` to analyze base64-encoded drone images.

### 2. Critical Bug Fixes & Code Workarounds We Implemented
If we face any issues running the project locally, remember that we successfully patched these specific errors:
1.  **FastAPI Limiter Import Crash:** The local `fastapi-limiter` package (v0.2.0) has a broken/empty `__init__.py` file on Windows. We wrapped the imports and startup calls in a try-except block:
    ```python
    try:
        from fastapi_limiter import FastAPILimiter
        HAS_LIMITER = True
    except ImportError:
        HAS_LIMITER = False
    ```
2.  **Missing multipart parser:** FastAPI requires `python-multipart` to parse form logins. We resolved this by installing `python-multipart`.
3.  **Passlib Bcrypt Version Error:** The deprecated `passlib` library crashes on modern Python 3.12 runtimes when interacting with `bcrypt 4.x` (raising `AttributeError: module 'bcrypt' has no attribute '__about__'`). We fully migrated `server.py` to use `bcrypt` directly:
    ```python
    import bcrypt
    
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        try:
            return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
        except Exception:
            return False
            
    def get_password_hash(password: str) -> str:
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    ```
4.  **Cloud Run Port Configuration:** Google Cloud Run dynamically binds to the `$PORT` environment variable. We set up our `Dockerfile` run command to support this:
    ```dockerfile
    CMD ["sh", "-c", "uvicorn server:app --host 0.0.0.0 --port ${PORT:-8000}"]
    ```

### 3. Current Task
[INSERT YOUR SPECIFIC REQUEST HERE, e.g.:
- "Help me compile the frontend and deploy it to Vercel."
- "Write a new backend endpoint to fetch historical crises."
- "Guide me through creating a Google Cloud SQL instance."
- "Explain how to hook up my live Gemini API Key."
]

Please provide clear, step-by-step guidance, clean code blocks, and professional advice matching this stack!
```
