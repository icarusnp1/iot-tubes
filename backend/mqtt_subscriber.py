# mqtt_subscriber.py
import json
import time
import paho.mqtt.client as mqtt

from flask import Flask
from config import Config
from models import db, SensorReading, User
from app import compute_bpm_spo2_steps_speed, determine_status   # reuse fungsi

# Konfigurasi MQTT
MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"
MQTT_PORT     = 8883
MQTT_TOPIC    = "esp32_1/raw-data"  # samakan dengan ESP32
MQTT_USERNAME = "Tubes_iot123"
MQTT_PASSWORD = "Tubes_iot123"

# Buat app Flask hanya untuk akses DB
flask_app = Flask(__name__)
flask_app.config.from_object(Config)
db.init_app(flask_app)


def save_reading(payload):
    print("DEBUG save_reading payload:", payload)
    """
    payload = dict hasil json.loads dari message ESP32
    Contoh:
    {
      "user_id": 1,
      "ir_value": 123456,
      "red_value": 123000,
      "temp_c": 30.5,
      "humidity": 70.1,
      "accel_x": 0.01,
      "accel_y": 0.02,
      "accel_z": 0.98
    }
    """
    with flask_app.app_context():
        user_id = payload.get('user_id')
        if not user_id:
            print("payload tanpa user_id, abaikan")
            return

        user = User.query.get(user_id)
        if not user:
            print(f"user_id {user_id} tidak ditemukan")
            return

        ir_value  = payload.get('ir_value')
        red_value = payload.get('red_value')
        temp_c    = payload.get('temp_c')
        humidity  = payload.get('humidity')
        accel_x   = payload.get('accel_x')
        accel_y   = payload.get('accel_y')
        accel_z   = payload.get('accel_z')

        # 🔴 PERBAIKAN: kirim user_id sebagai argumen pertama
        bpm, spo2, steps, speed_mps = compute_bpm_spo2_steps_speed(
            user_id, ir_value, red_value, accel_x, accel_y, accel_z
        )
        status = determine_status(bpm, spo2)

        print(f"DEBUG BPM/SpO2 user={user_id}: bpm={bpm}, spo2={spo2}, status={status}")

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
            # activity bisa di-update belakangan oleh frontend
            status=status
        )
        db.session.add(reading)
        db.session.commit()
        print(f"[DB] Insert reading id={reading.id} user={user_id}")


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
    # pakai client_id biar jelas di HiveMQ
    client = mqtt.Client(client_id="backend_subscriber")

    # SET KREDENSIAL
    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    # TLS untuk HiveMQ Cloud (port 8883)
    client.tls_set()               # pakai CA default
    client.tls_insecure_set(True)  # abaikan verifikasi sertifikat (DEV ONLY)

    # callback
    client.on_connect = on_connect
    client.on_message = on_message

    print(f"Mencoba connect ke MQTT {MQTT_BROKER}:{MQTT_PORT} ...")
    rc = client.connect(MQTT_BROKER, MQTT_PORT, 60)
    print("Hasil client.connect rc =", rc)  # 0 = sukses (untuk koneksi awal)

    # (opsional) debug lebih detail:
    # client.on_log = lambda c, u, level, buf: print("LOG:", buf)

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
