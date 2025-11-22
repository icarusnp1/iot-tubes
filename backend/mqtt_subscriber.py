# mqtt_subscriber.py
import json
import time
import paho.mqtt.client as mqtt

from flask import Flask
from config import Config
from models import db, SensorReading, User
from app import compute_bpm_spo2_steps_speed, determine_status   # reuse fungsi

# Konfigurasi MQTT (samakan dengan ESP32)
MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"
MQTT_PORT     = 8883
MQTT_TOPIC    = "esp32_1/raw-data"
MQTT_USERNAME = "Tubes_iot123"
MQTT_PASSWORD = "Tubes_iot123"

# Buat app Flask hanya untuk akses DB
flask_app = Flask(__name__)
flask_app.config.from_object(Config)
db.init_app(flask_app)


def save_reading(payload: dict):
    print("DEBUG save_reading payload:", payload)

    with flask_app.app_context():
        user_id = payload.get('user_id')
        if not user_id:
            print("payload tanpa user_id, abaikan")
            return

        user = User.query.get(user_id)
        if not user:
            print(f"user_id {user_id} tidak ditemukan di DB")
            return

        temp_c    = payload.get('temp_c')
        humidity  = payload.get('humidity')
        accel_x   = payload.get('accel_x')
        accel_y   = payload.get('accel_y')
        accel_z   = payload.get('accel_z')

        samples = payload.get('samples', [])
        if not samples:
            print("payload tanpa 'samples', abaikan")
            return

        inserted = 0

        for sample in samples:
            ir_value  = sample.get('ir')
            red_value = sample.get('red')

            if ir_value is None or red_value is None:
                print("sample tanpa ir/red, skip:", sample)
                continue

            bpm, spo2, steps, speed_mps = compute_bpm_spo2_steps_speed(
                user_id, ir_value, red_value, accel_x, accel_y, accel_z
            )
            status = determine_status(bpm, spo2)

            reading = SensorReading(
                user_id=user_id,
                ir_value=ir_value,
                red_value=red_value,
                temp_c=temp_c,
                humidity=humidity,
                accel_x=accel_x,
                accel_y=accel_y,
                accel_z=accel_z,
                bpm=bpm,
                spo2=spo2,
                steps=steps,
                speed_mps=speed_mps,
                # activity bisa diisi nanti oleh frontend
                status=status
            )
            db.session.add(reading)
            inserted += 1

        if inserted > 0:
            db.session.commit()
            print(f"[DB] Insert {inserted} samples for user={user_id}")
        else:
            print("Tidak ada sample valid untuk disimpan")


def on_connect(client, userdata, flags, rc):
    print("on_connect rc =", rc)
    if rc == 0:
        print("MQTT connected, subscribe ke", MQTT_TOPIC)
        client.subscribe(MQTT_TOPIC)
    else:
        print("MQTT failed connect, rc =", rc)


def on_message(client, userdata, msg):
    try:
        payload_str = msg.payload.decode('utf-8')
        data = json.loads(payload_str)
        print(f"[MQTT] Topic={msg.topic} Payload={data}")
        save_reading(data)
    except Exception as e:
        print("Error memproses pesan:", e)


def main():
    client = mqtt.Client(client_id="backend_subscriber")
    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    # TLS untuk HiveMQ Cloud
    client.tls_set()
    client.tls_insecure_set(True)

    client.on_connect = on_connect
    client.on_message = on_message

    print(f"Mencoba connect ke MQTT {MQTT_BROKER}:{MQTT_PORT} ...")
    rc = client.connect(MQTT_BROKER, MQTT_PORT, 60)
    print("Hasil client.connect rc =", rc)

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
