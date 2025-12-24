# app.py
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import uuid
from functools import wraps

from ppg_processing import ppg_processor  # pastikan file ppg_processing.py ada
from config import Config
from models import db, User, UserHealth, SensorReading
from sqlalchemy import func

from ppg_processing import ppg_processor  # sudah ada
from motion_processing import motion_processor  # TAMBAHAN BARU

import paho.mqtt.client as mqtt

MQTT_BROKER   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"
MQTT_PORT     = 8883
# MQTT_TOPIC    = "esp32_1/raw-data"
# STATUS_TOPIC  = "esp32_1/status"
MQTT_USERNAME = "Tubes_iot123"
MQTT_PASSWORD = "Tubes_iot123"

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)
with app.app_context():
    db.create_all()  # hanya untuk development pertama kali


# ============ Helper Auth (JWT) ============

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None

        if 'Authorization' in request.headers:
            parts = request.headers['Authorization'].split()
            if len(parts) == 2 and parts[0].lower() == 'bearer':
                token = parts[1]

        if not token:
            return jsonify({'message': 'Token is missing!'}), 401

        try:
            data = jwt.decode(token, app.config['JWT_SECRET_KEY'], algorithms=["HS256"])
            current_user = User.query.get(data['user_id'])
            if not current_user:
                return jsonify({'message': 'User tidak ditemukan'}), 401
        except Exception as e:
            return jsonify({'message': 'Token tidak valid', 'error': str(e)}), 401

        return f(current_user, *args, **kwargs)
    return decorated


# ============ AUTH ROUTES ============

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    name  = data.get('name')
    email = data.get('email')
    password = data.get('password')
    date_of_birth = data.get('date_of_birth')

    if not all([name, email, password]):
        return jsonify({'message': 'name, email, password wajib diisi'}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({'message': 'Email sudah terdaftar'}), 400

    password_hash = generate_password_hash(password)

    user = User(
        name=name,
        email=email,
        password_hash=password_hash,
        date_of_birth=datetime.datetime.strptime(date_of_birth, '%Y-%m-%d').date()
        if date_of_birth else None
    )
    db.session.add(user)
    db.session.commit()

    health = UserHealth(user_id=user.id)
    db.session.add(health)
    db.session.commit()

    return jsonify({'message': 'Registrasi berhasil', 'user_id': user.id}), 201


@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    email    = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()
    if not user or not check_password_hash(user.password_hash, password):
        return jsonify({'message': 'Email atau password salah'}), 401

    token = jwt.encode(
        {
            'user_id': user.id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=8)
        },
        app.config['JWT_SECRET_KEY'],
        algorithm="HS256"
    )

    return jsonify({'token': token, 'user_id': user.id})


@app.route('/api/auth/logout', methods=['POST'])
@token_required
def logout(current_user):
    return jsonify({'message': 'Logout sukses (hapus token di client).'})


# ============ API HEALTH INFO (BMI) ============

@app.route('/api/user/health', methods=['GET', 'PUT'])
@token_required
def user_health(current_user):
    health = current_user.health

    if request.method == 'GET':
        if not health:
            return jsonify({'message': 'Data health belum ada'}), 404
        return jsonify({
            'blood_type': health.blood_type,
            'height_cm': float(health.height_cm) if health.height_cm else None,
            'weight_kg': float(health.weight_kg) if health.weight_kg else None,
            'bmi': float(health.bmi) if health.bmi else None
        })

    if request.method == 'PUT':
        data = request.get_json()
        health.blood_type = data.get('blood_type', health.blood_type)
        height_cm = data.get('height_cm')
        weight_kg = data.get('weight_kg')

        if height_cm is not None:
            health.height_cm = height_cm
        if weight_kg is not None:
            health.weight_kg = weight_kg

        if health.height_cm and health.weight_kg:
            h_m = float(health.height_cm) / 100.0
            bmi = float(health.weight_kg) / (h_m * h_m)
            health.bmi = round(bmi, 2)

        db.session.commit()
        return jsonify({'message': 'Data health terupdate'})


# ============ DEBUG PPG ============

@app.route('/api/debug/ppg/<int:user_id>', methods=['GET'])
@token_required
def debug_ppg(current_user, user_id):
    if current_user.id != user_id:
        return jsonify({'message': 'Tidak boleh akses data user lain'}), 403

    limit = int(request.args.get('limit', 20))

    readings = (SensorReading.query
                .filter_by(user_id=user_id)
                .order_by(SensorReading.recorded_at.desc())
                .limit(limit)
                .all())

    if not readings:
        return jsonify({'message': 'Belum ada data sensor untuk user ini'}), 404

    data = []
    for r in readings:
        data.append({
            'recorded_at': r.recorded_at.isoformat(),
            'ir_value': int(r.ir_value) if r.ir_value is not None else None,
            'red_value': int(r.red_value) if r.red_value is not None else None,
            'bpm': float(r.bpm) if r.bpm is not None else None,
            'spo2': float(r.spo2) if r.spo2 is not None else None,
            'status': r.status
        })

    data = list(reversed(data))

    return jsonify({
        'user_id': user_id,
        'count': len(data),
        'records': data
    })


# ============ PPG & INGESTION LOGIC ============

def compute_bpm_spo2_steps_speed(user_id, ir_value, red_value, accel_x, accel_y, accel_z):
    """
    Hitung BPM & SpO2 dari PPG + estimasi langkah & kecepatan dari akselerometer.

    - BPM & SpO2: dari ppg_processor (kalau gagal -> fallback).
    - Steps: total langkah kumulatif (per user) dari MotionProcessor.
    - Speed: estimasi kecepatan (m/s) dari cadence × step_length.
    """
    # -------- PPG (BPM & SpO2) --------
    bpm = None
    spo2 = None

    if ir_value is not None and red_value is not None:
        try:
            bpm, spo2 = ppg_processor.add_sample(user_id, ir_value, red_value)
        except Exception as e:
            print(f"[PPG] Error add_sample user={user_id}: {e}")
            bpm, spo2 = None, None

    # Fallback kalau algoritma PPG belum kasih nilai
    if bpm is None:
        bpm = 75 + (int(ir_value) % 5) if ir_value is not None else 75

    if spo2 is None:
        spo2 = 97.0

    # -------- Motion (steps & speed) --------
    # Untuk sekarang, kita belum tarik height_cm per user (bisa dikembangkan nanti).
    # Jadi height_cm=None -> pakai default step_length 0.7 m.
    total_steps, speed_mps = motion_processor.add_sample(
        user_id,
        accel_x,
        accel_y,
        accel_z,
        height_cm=None
    )

    print(f"[PPG+Motion] user={user_id} ir={ir_value} red={red_value} "
          f"-> bpm={bpm}, spo2={spo2}, steps={total_steps}, speed={speed_mps:.2f} m/s")

    return bpm, spo2, total_steps, speed_mps



def determine_status(bpm, spo2):
    if bpm is None or spo2 is None:
        return 'warning'
    if 60 <= bpm <= 100 and spo2 >= 95:
        return 'normal'
    if (50 <= bpm < 60 or 100 < bpm <= 120) or (93 <= spo2 < 95):
        return 'warning'
    return 'danger'


@app.route('/api/ingest', methods=['POST'])
def ingest():
    data = request.get_json()
    user_id = data.get('user_id') 
    if not user_id:
        return jsonify({'message': 'user_id wajib diisi'}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({'message': 'User tidak ditemukan'}), 404

    ir_value  = data.get('ir_value')
    red_value = data.get('red_value')
    temp_c    = data.get('temp_c')
    humidity  = data.get('humidity')
    accel_x   = data.get('accel_x')
    accel_y   = data.get('accel_y')
    accel_z   = data.get('accel_z')
    activity  = data.get('activity')

    bpm, spo2, steps, speed_mps = compute_bpm_spo2_steps_speed(
        user.id, ir_value, red_value, accel_x, accel_y, accel_z
    )
    status = determine_status(bpm, spo2)

    reading = SensorReading(
        user_id=user.id,
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
        activity=activity,
        status=status
    )
    db.session.add(reading)
    db.session.commit()

    return jsonify({'message': 'Data tersimpan', 'reading_id': reading.id}), 201


# ============ API DASHBOARD ============

@app.route('/api/dashboard/<int:user_id>', methods=['GET'])
@token_required
def dashboard(current_user, user_id):
    if current_user.id != user_id:
        return jsonify({'message': 'Tidak boleh akses data user lain'}), 403

    latest = (SensorReading.query
              .filter_by(user_id=user_id)
              .order_by(SensorReading.recorded_at.desc())
              .first())

    history = (SensorReading.query
               .filter_by(user_id=user_id)
               .order_by(SensorReading.recorded_at.desc())
               .limit(50)
               .all())
    history = list(reversed(history))

    if not latest:
        return jsonify({'message': 'Belum ada data sensor'}), 404

    bpm_array = []
    spo2_array = []
    timestamps = []

    for r in history:
        bpm_array.append(float(r.bpm) if r.bpm is not None else None)
        spo2_array.append(float(r.spo2) if r.spo2 is not None else None)
        timestamps.append(r.recorded_at.isoformat())

    response = {
        'latest': {
            'recorded_at': latest.recorded_at.isoformat(),
            'bpm': float(latest.bpm) if latest.bpm is not None else None,
            'spo2': float(latest.spo2) if latest.spo2 is not None else None,
            'temp_c': float(latest.temp_c) if latest.temp_c is not None else None,
            'humidity': float(latest.humidity) if latest.humidity is not None else None,
            'speed_mps': float(latest.speed_mps) if latest.speed_mps is not None else None,
            'steps': latest.steps,
            'activity': latest.activity,
            'status': latest.status
        },
        'graph': {
            'timestamps': timestamps,
            'bpm': bpm_array,
            'spo2': spo2_array
        }
    }
    return jsonify(response)


# ============ API HISTORY & STATS ============
@app.route('/api/history/<int:user_id>', methods=['GET'])
@token_required
def history(current_user, user_id):
    if current_user.id != user_id:
        return jsonify({'message': 'Tidak boleh akses data user lain'}), 403

    page  = int(request.args.get('page', 1))
    limit = int(request.args.get('limit', 20))

    query = (SensorReading.query
             .filter_by(user_id=user_id)
             .order_by(SensorReading.recorded_at.desc()))

    pagination = query.paginate(page=page, per_page=limit, error_out=False)

    items = []
    for r in pagination.items:
        items.append({
            'time': r.recorded_at.isoformat(),
            'bpm': float(r.bpm) if r.bpm is not None else None,
            'spo2': float(r.spo2) if r.spo2 is not None else None,
            'temp_c': float(r.temp_c) if r.temp_c is not None else None,
            'humidity': float(r.humidity) if r.humidity is not None else None,
            'activity': r.activity,
            'status': r.status
        })

    return jsonify({
        'page': page,
        'limit': limit,
        'total': pagination.total,
        'data': items
    })

@app.route('/api/history/<int:user_id>/stats', methods=['GET'])
@token_required
def history_stats(current_user, user_id):
    if current_user.id != user_id:
        return jsonify({'message': 'Tidak boleh akses data user lain'}), 403

    total = SensorReading.query.filter_by(user_id=user_id).count()

    avg_bpm, avg_spo2 = (
        db.session.query(
            func.avg(SensorReading.bpm),
            func.avg(SensorReading.spo2)
        )
        .filter(SensorReading.user_id == user_id)
        .first()
    )

    return jsonify({
        'total_records': total,
        'avg_bpm': float(avg_bpm) if avg_bpm is not None else None,
        'avg_spo2': float(avg_spo2) if avg_spo2 is not None else None
    })

# ============ MQTT PUBLISHING ============

def mqtt_publish(topic: str, payload: dict, qos: int = 1, retain: bool = False) -> None:
    # 🔑 MUST be unique per client instance
    client_id = f"flask-publisher-{uuid.uuid4()}"

    client = mqtt.Client(
        client_id=client_id,
        protocol=mqtt.MQTTv311
    )

    if MQTT_USERNAME:
        client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    # TLS (HiveMQ Cloud requires TLS on 8883)
    client.tls_set()
    client.tls_insecure_set(False)

    client.connect(MQTT_BROKER, MQTT_PORT, keepalive=30)

    # Start loop
    client.loop_start()

    # json_string = json.dumps(payload)

    # Publish JSON (IMPORTANT: serialize!)
    client.publish(
        topic,
        payload,
        qos=qos,
        retain=retain
    )

    # Give broker time to receive packet
    client.loop_stop()
    client.disconnect()

def is_safe_topic(topic: str) -> bool:
    """
    Prevent topic injection / wildcards / weird control chars.
    Adjust to your own topic naming rules.
    """
    if not isinstance(topic, str):
        return False
    topic = topic.strip()
    if not topic or len(topic) > 256:
        return False
    if "\x00" in topic:
        return False
    # Disallow MQTT wildcards to avoid publishing to broad topics unintentionally
    if "+" in topic or "#" in topic:
        return False
    return True

# ---------- The endpoint you asked for ----------
@app.post("/api/publish-user")
@token_required
def publish_current_user(current_user):
    """
    Body: { "topic": "some/topic/name" }
    esp32_1/session

    Publishes: { "user_id": <current_user.id> } to that topic.
    """
    body = request.get_json(silent=True) or {}
    topic = body.get("topic")
    print("TEST TOPIC - ", topic, current_user.id)

    if not is_safe_topic(topic):
        return jsonify({"message": "Invalid topic"}), 400

    payload = {
        "user_id": current_user.id
    }

    try:
        mqtt_publish(topic, current_user.id)
    except Exception as e:
        return jsonify({"message": "Failed to publish", "error": str(e)}), 502

    return jsonify({"message": "Published", "topic": topic, "payload": payload}), 200

if __name__ == '__main__':
    app.run(debug=True, port=5001)