import asyncio
from fastapi import FastAPI
from .db import engine
from . import models
from .mqtt_worker import mqtt_loop

app = FastAPI(title="IoT Health Backend")

@app.on_event("startup")
async def startup_event():
    # create tables
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.create_all)
    # start mqtt worker in background
    loop = asyncio.get_running_loop()
    loop.create_task(mqtt_loop())
    print("MQTT worker started")

@app.get("/health")
async def health():
    return {"status": "ok"}
