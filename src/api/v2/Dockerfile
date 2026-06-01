# Build context.
FROM python:3.12-slim

WORKDIR /app

COPY src/api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# v2 = debug variant; copy v2's main.py next to the model.
COPY src/api/v2/main.py .
COPY model/model.joblib .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
