FROM python:3.11-slim
WORKDIR /app
# Sistem bağımlılıklarını (gcc vb.) şimdilik imajın içine gömüyoruz
RUN apt-get update && apt-get install -y netbase gcc && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
COPY wheels ./wheels
# İnternete çıkmadan klasörden kur diyoruz
RUN pip install --no-cache-dir --no-index --find-links=wheels -r requirements.txt
COPY . .
CMD ["uvicorn", "src.app.main:app", "--host", "0.0.0.0", "--port", "9999"]
