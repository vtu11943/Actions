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
