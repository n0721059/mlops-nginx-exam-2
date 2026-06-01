# Build context is the repo root (set in docker-compose.yml).
FROM python:3.12-slim

WORKDIR /app

# Install deps first so this layer is cached across code changes.
COPY src/api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# main.py loads model.joblib from its OWN directory (os.path.dirname(__file__)),
# so the model must live right next to main.py — both go into /app.
COPY src/api/v1/main.py .
COPY model/model.joblib .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
