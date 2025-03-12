FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY plant_plots.py .
ENTRYPOINT ["python", "plant_plots.py"]
