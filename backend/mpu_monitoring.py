# mqtt_subscriber.py (forwarder)
import json
import time
import requests
import paho.mqtt.client as mqtt
from models import db, User, UserHealth, SensorReading
from motion_algo import compute_steps_speed_from_batch, build_motion_payload
import matplotlib.pyplot as plt
import app


MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"
MQTT_PORT     = 8883
MQTT_USERNAME = "Tubes_iot123"
MQTT_PASSWORD = "Tubes_iot123"

RAW_TOPIC     = "esp32_1/raw-data"

# Samakan dengan Config.INGEST_API_KEY
INGEST_API_KEY = "dev-ingest-key"

client = mqtt.Client(client_id="mqtt_forwarder_raw_v2")
# Global storage for plotting
AX_ALL = []
AY_ALL = []
AZ_ALL = []
STEPS_ALL = []


def on_connect(client, userdata, flags, rc):
    print("[MQTT] on_connect rc =", rc)
    if rc == 0:
        client.subscribe(RAW_TOPIC, qos=0)
        print("[MQTT] subscribed:", RAW_TOPIC)
    else:
        print("[MQTT] connect failed rc =", rc)


def on_message(client, userdata, msg):
	try:
		payload_str = msg.payload.decode("utf-8")
		data = json.loads(payload_str)

		# user_id = int(data["user_id"])
		# user = User.query.get(user_id)
		# height_cm, step_len_m = _get_motion_params(user)

		steps, speed_mps = compute_steps_speed_from_batch(
			data,
			height_cm=175,
			calibrated_step_length_m=114,
		)

		# ───── Store gyroscope data ─────
		AX_ALL.extend(data["ax"])
		AY_ALL.extend(data["ay"])
		AZ_ALL.extend(data["az"])

		# ───── Store steps (aligned to batch) ─────
		# Repeat steps value so it lines up with ax/ay/az length
		STEPS_ALL.extend([steps] * len(data["ax"]))

	except Exception as e:
		print("[MQTT] invalid payload:", e)

def _get_motion_params(user: User):
    height_cm = None
    step_len_m = None
    if user.health:
        height_cm = _safe_float(user.health.height_cm)
        step_len_m = _safe_float(getattr(user.health, "step_length_m", None))
    return height_cm, step_len_m

def _safe_float(x):
    try:
        return float(x)
    except Exception:
        return None

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

        # ───── Plot after program ends ─────
        if AX_ALL:
            plt.figure(figsize=(12, 6))

            plt.plot(AX_ALL, label="ax")
            plt.plot(AY_ALL, label="ay")
            plt.plot(AZ_ALL, label="az")
            plt.plot(STEPS_ALL, label="steps", linewidth=2)

            # ───── Detect step increment points ─────
            step_change_indices = []
            for i in range(1, len(STEPS_ALL)):
                if STEPS_ALL[i] > STEPS_ALL[i - 1]:
                    step_change_indices.append(i)

            # ───── Draw vertical lines for steps ─────
            for idx in step_change_indices:
                plt.axvline(x=idx, linestyle="--", alpha=0.4)

            plt.xlabel("Sample Index")
            plt.ylabel("Value")
            plt.title("Gyroscope (ax, ay, az) and Steps Over Time")
            plt.legend()
            plt.grid(True)

            plt.show()

if __name__ == "__main__":
    main()
