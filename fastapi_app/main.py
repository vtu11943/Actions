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
