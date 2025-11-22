import asyncio
import json
from datetime import datetime
from asyncio_mqtt import Client, MqttError
from .config import MQTT_BROKER, MQTT_PORT, MQTT_TOPIC
from .db import AsyncSessionLocal
from .crud import save_ppg_batch, save_motion_batch, save_env

async def handle_message(topic: str, payload: bytes):
    try:
        data = json.loads(payload.decode())
    except Exception as e:
        print("Invalid JSON", e)
        return

    device_id = data.get("device_id", "unknown")
    ts_str = data.get("timestamp", None)
    if ts_str:
        try:
            ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        except:
            ts = datetime.utcnow()
    else:
        ts = datetime.utcnow()

    async with AsyncSessionLocal() as session:
        # PPG
        ppg = data.get("ppg")
        if ppg:
            await save_ppg_batch(session, device_id, ts, ppg)

        mpu = data.get("mpu")
        if mpu:
            await save_motion_batch(session, device_id, ts, mpu)

        dht = data.get("dht")
        if dht:
            await save_env(session, device_id, ts, dht.get("temp"), dht.get("hum"))

async def mqtt_loop():
    reconnect_interval = 5
    while True:
        try:
            async with Client(MQTT_BROKER, port=MQTT_PORT) as client:
                async with client.unfiltered_messages() as messages:
                    await client.subscribe(MQTT_TOPIC)
                    print("Subscribed to", MQTT_TOPIC)
                    async for msg in messages:
                        topic = msg.topic
                        payload = msg.payload
                        # process asynchronously (do not block loop)
                        asyncio.create_task(handle_message(topic, payload))
        except MqttError as error:
            print("MQTT error:", error)
            await asyncio.sleep(reconnect_interval)
