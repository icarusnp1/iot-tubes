# mqtt_subscriber.py (forwarder)
import json
import time
import requests
import paho.mqtt.client as mqtt

MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"
MQTT_PORT     = 8883
MQTT_USERNAME = "Tubes_iot123"
MQTT_PASSWORD = "Tubes_iot123"

RAW_TOPIC     = "esp32_1/raw-data"

# Arahkan ke app.py
APP_BASE_URL  = "http://127.0.0.1:5000"
INGEST_URL    = f"{APP_BASE_URL}/api/ingest-esp32-batch"

# Samakan dengan Config.INGEST_API_KEY
INGEST_API_KEY = "dev-ingest-key"

client = mqtt.Client(client_id="mqtt_forwarder_raw_v1")


def on_connect(client, userdata, flags, rc):
    print("[MQTT] on_connect rc =", rc)
    if rc == 0:
        client.subscribe(RAW_TOPIC, qos=0)
        print("[MQTT] subscribed:", RAW_TOPIC)
    else:
        print("[MQTT] connect failed rc =", rc)


def on_message(client, userdata, msg):
    try:
        payload_str = msg.payload.decode("utf-8", errors="replace")
        data = json.loads(payload_str)
    except Exception as e:
        print("[MQTT] invalid payload:", e)
        return

    try:
        r = requests.post(
            INGEST_URL,
            json=data,
            headers={"X-API-KEY": INGEST_API_KEY},
            timeout=5,
        )
        if r.status_code != 200:
            print("[HTTP] ingest failed:", r.status_code, r.text[:200])
        else:
            out = r.json()
            print(
                f"[HTTP] OK user={out.get('user_id')} "
                f"steps={out.get('steps')} "
                f"speed={out.get('speed_kmh')} km/h"
            )

    except Exception as e:
        print("[HTTP] error:", e)


def main():
    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    client.tls_set()
    client.tls_insecure_set(True)  # dev

    client.on_connect = on_connect
    client.on_message = on_message

    print(f"[MQTT] connecting {MQTT_BROKER}:{MQTT_PORT} ...")
    client.connect(MQTT_BROKER, MQTT_PORT, 60)

    client.loop_start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
