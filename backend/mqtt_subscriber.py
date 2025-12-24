# mqtt_subscriber.py (VERSI FINAL)
import json
import time
import paho.mqtt.client as mqtt

from flask import Flask
from config import Config
from models import db, SensorReading, User
from app import compute_bpm_spo2_steps_speed, determine_status


# ============================
# MQTT CONFIG (samakan dengan ESP32)
# ============================
MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"
MQTT_PORT     = 8883
MQTT_TOPIC    = "esp32_1/raw-data"
STATUS_TOPIC  = "esp32_1/status"
MQTT_USERNAME = "Tubes_iot123"
MQTT_PASSWORD = "Tubes_iot123"

# ============================
# Flask App (untuk DB)
# ============================
flask_app = Flask(__name__)
flask_app.config.from_object(Config)
db.init_app(flask_app)

# ============================
# GLOBAL MQTT CLIENT
# ============================
client = mqtt.Client(client_id="backend_subscriber")


# ============================================================
# SAVE READING + PUBLISH STATUS KE ESP32
# ============================================================
def save_reading(payload):
    global client

    with flask_app.app_context():

        user_id = payload.get('user_id')
        temp_c  = payload.get('temp_c')
        humidity= payload.get('humidity')
        accel_x = payload.get('accel_x')
        accel_y = payload.get('accel_y')
        accel_z = payload.get('accel_z')
        samples = payload.get('samples', [])

        if not samples:
            print("Tidak ada samples[] → abaikan.")
            return

        last_bpm = None
        last_spo2 = None
        last_steps = 0
        last_speed = 0.0

        # Proses SEMUA sampel batch
        for s in samples:
            ir_value  = s.get('ir')
            red_value = s.get('red')

            bpm, spo2, steps, speed_mps = compute_bpm_spo2_steps_speed(
                user_id, ir_value, red_value, accel_x, accel_y, accel_z
            )
            last_bpm   = bpm
            last_spo2  = spo2
            last_steps = steps
            last_speed = speed_mps

        # Status final
        status = determine_status(last_bpm, last_spo2)

        # Simpan 1 record ke DB
        reading = SensorReading(
            user_id=user_id,
            ir_value=ir_value,
            red_value=red_value,
            temp_c=temp_c,
            humidity=humidity,
            accel_x=accel_x,
            accel_y=accel_y,
            accel_z=accel_z,
            bpm=last_bpm,
            spo2=last_spo2,
            steps=last_steps,
            speed_mps=last_speed,
            status=status,
        )
        db.session.add(reading)
        db.session.commit()

        print(f"[DB] Insert reading id={reading.id} user={user_id} bpm={last_bpm} spo2={last_spo2} status={status}")
        # ==== PUBLISH STATUS KE ESP32 ====
        status_payload = json.dumps({
            "user_id": user_id,
            "bpm": last_bpm,
            "spo2": last_spo2,
            "status": determine_status(last_bpm, last_spo2)
        })

        client.publish(STATUS_TOPIC, status_payload)
        print(f"[MQTT PUBLISH] -> {STATUS_TOPIC}: {status_payload}")

        # =====================================================
        # PUBLISH STATUS KE ESP32
        # =====================================================
        status_payload = {
            "user_id": user_id,
            "bpm": last_bpm,
            "spo2": last_spo2,
            "status": status
        }
        json_payload = json.dumps(status_payload)

        if client.is_connected():
            result = client.publish(STATUS_TOPIC, json_payload)
            # mqtt_publish(topic, current_user.id)
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f"[MQTT->ESP32] Status sent: {json_payload}")
            else:
                print(f"[MQTT->ESP32] FAILED to publish, rc={result.rc}")
        else:
            print("[MQTT->ESP32] Client not connected! (FAILED publish)")


# ============================================================
# MQTT CALLBACKS
# ============================================================
def on_connect(client, userdata, flags, rc):
    print("on_connect rc =", rc)
    if rc == 0:
        print("MQTT connected → subscribe ke:", MQTT_TOPIC)
        client.subscribe(MQTT_TOPIC)
    else:
        print("MQTT failed, rc =", rc)


def on_message(client, userdata, msg):
    try:
        payload_str = msg.payload.decode('utf-8')
        data = json.loads(payload_str)
        print(f"\n[MQTT] Topic={msg.topic} Payload={data}")
        save_reading(data)
    except Exception as e:
        print("Error memproses pesan:", e)


# ============================================================
# MAIN
# ============================================================
def main():
    global client

    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    # TLS untuk HiveMQ Cloud
    client.tls_set()
    client.tls_insecure_set(True)

    client.on_connect = on_connect
    client.on_message = on_message

    print(f"Connecting to MQTT {MQTT_BROKER}:{MQTT_PORT} ...")
    rc = client.connect(MQTT_BROKER, MQTT_PORT, 60)
    print("client.connect rc =", rc)

    client.loop_start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Stop subscriber...")
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
