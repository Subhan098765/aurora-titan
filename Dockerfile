FROM python:3.12-slim

WORKDIR /app

COPY aurora_backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY aurora_backend/ .

EXPOSE 8000

CMD ["sh", "-c", "uvicorn server:app --host 0.0.0.0 --port ${PORT:-8000}"]
