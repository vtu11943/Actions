#!/usr/bin/env bash
set -e

mkdir -p fastapi_app streamlit_app

cat > fastapi_app/main.py <<'PY'
# FastAPI back‑end
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Demo API")


class Item(BaseModel):
    name: str
    value: float


@app.get("/")
def root():
    return {"msg": "Hello from FastAPI!"}


@app.post("/echo")
def echo(item: Item):
    # Simply bounce the payload back
    return {"you_sent": item}
PY

cat > streamlit_app/app.py <<'PY'
# Streamlit front‑end
import streamlit as st
import requests

st.title("Streamlit ↔ FastAPI demo 👋")

# ------------------------------------------------------------------ sidebar
backend_url = st.sidebar.text_input("FastAPI base URL",
                                    value="http://api:8000")  # “api” == service name
st.sidebar.markdown(
    "Edit the URL if you run the API elsewhere.\n"
    "Inside docker‑compose the hostname **api** resolves automatically."
)

# ------------------------------------------------------------------ GET /
st.subheader("Ping the API (GET /)")
if st.button("Ping"):
    try:
        r = requests.get(f"{backend_url}/")
        st.json(r.json())
    except Exception as e:
        st.error(f"Request failed: {e}")

# ------------------------------------------------------------------ POST /echo
st.subheader("Echo endpoint (POST /echo)")
name  = st.text_input("Name",  "Alice")
value = st.number_input("Value", 42.0)
if st.button("Send"):
    try:
        payload = {"name": name, "value": value}
        r = requests.post(f"{backend_url}/echo", json=payload)
        st.json(r.json())
    except Exception as e:
        st.error(f"Request failed: {e}")
PY

cat > Dockerfile.api <<'DOCKER'
# ---------- build FastAPI image ----------
FROM python:3.11-slim
WORKDIR /app

# install requirements
RUN pip install --no-cache-dir fastapi uvicorn[standard]

# copy src
COPY fastapi_app/ /app

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

DOCKER

cat > Dockerfile.streamlit <<'DOCKER'
# ---------- build Streamlit image ----------
FROM python:3.11-slim
WORKDIR /app

RUN pip install --no-cache-dir streamlit requests

COPY streamlit_app/ /app

EXPOSE 8501
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]

DOCKER

cat > docker-compose.yml <<'YML'
version: "3.9"

services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.api
    container_name: fastapi_service
    ports:
      - "8000:8000"

  web:
    build:
      context: .
      dockerfile: Dockerfile.streamlit
    container_name: streamlit_service
    depends_on:
      - api
    ports:
      - "8501:8501"

YML

echo "✔ Project scaffolding complete."
