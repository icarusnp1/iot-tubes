# app.py
from flask import Flask, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
import jwt
import datetime
import uuid
import json
from functools import wraps
from sqlalchemy import func, text

import paho.mqtt.client as mqtt
from sqlalchemy import func

from config import Config
from models import db, User, UserHealth, SensorReading
from sqlalchemy import func

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)

# Development only:
with app.app_context():
    db.create_all()  # :contentReference[oaicite:5]{index=5}


# ================= AUTH =================
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


# ================= MQTT PUBLISH HELPERS =================
def mqtt_publish(topic: str, payload, qos: int = 1, retain: bool = False, *, is_json: bool = True) -> None:
    """
    Publish ke MQTT. Bisa JSON (dict) atau plain string/int.

    - is_json=True:
        payload dict/list -> json.dumps
        payload str -> publish as-is (anggap sudah JSON)
    - is_json=False:
        payload -> str(payload) (untuk SESSION_TOPIC yang butuh integer plain)
    """
    client_id = f"flask-publisher-{uuid.uuid4()}"
    c = mqtt.Client(client_id=client_id, protocol=mqtt.MQTTv311)

    if MQTT_USERNAME:
        c.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    c.tls_set()
    c.tls_insecure_set(app.config.get("MQTT_TLS_INSECURE", True))

    c.connect(MQTT_BROKER, MQTT_PORT, keepalive=30)
    c.loop_start()

    if is_json:
        if isinstance(payload, (dict, list)):
            msg = json.dumps(payload, separators=(",", ":"))
        else:
            msg = payload  # assume already JSON string
    else:
        msg = str(payload)

    c.publish(topic, msg, qos=qos, retain=retain)

    c.loop_stop()
    c.disconnect()


def determine_status(bpm, spo2):
    if bpm is None or spo2 is None:
        return 'warning'
    if 60 <= bpm <= 100 and spo2 >= 95:
        return 'normal'
    if (50 <= bpm < 60 or 100 < bpm <= 120) or (93 <= spo2 < 95):
        return 'warning'
    return 'danger'


def _safe_float(x):
    try:
        return float(x)
    except Exception:
        return None


def _validate_esp32_batch(payload: dict) -> bool:
    # minimal schema: user_id + samples + t0_ms/dt_ms + ax/ay/az arrays
    if not isinstance(payload, dict):
        return False
    if "user_id" not in payload or "samples" not in payload:
        return False
    for k in ("t0_ms", "dt_ms", "ax", "ay", "az"):
        if k not in payload:
            return False
    if not isinstance(payload["ax"], list) or not isinstance(payload["ay"], list) or not isinstance(payload["az"], list):
        return False
    if min(len(payload["ax"]), len(payload["ay"]), len(payload["az"])) == 0:
        return False
    if not isinstance(payload["samples"], list) or len(payload["samples"]) == 0:
        return False
    return True


def _get_motion_params(user: User):
    height_cm = None
    step_len_m = None
    if user.health:
        height_cm = _safe_float(user.health.height_cm)
        step_len_m = _safe_float(getattr(user.health, "step_length_m", None))
    return height_cm, step_len_m


# ================= AUTH ROUTES =================
@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json(silent=True) or {}
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

    # create empty health row
    health = UserHealth(user_id=user.id)
    db.session.add(health)
    db.session.commit()

    return jsonify({'message': 'Registrasi berhasil', 'user_id': user.id}), 201


@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json(silent=True) or {}
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


# ================= HEALTH ROUTES =================
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
            'bmi': float(health.bmi) if health.bmi else None,
            'step_length_m': float(health.step_length_m) if getattr(health, "step_length_m", None) else None,
        })

    data = request.get_json(silent=True) or {}
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


@app.route('/api/health/step-length', methods=['POST'])
@token_required
def set_step_length(current_user):
    data = request.get_json(silent=True) or {}
    step_length_m = data.get('step_length_m')

    try:
        step_length_m = float(step_length_m)
    except Exception:
        return jsonify({'message': 'step_length_m harus angka (meter)'}), 400

    if step_length_m <= 0.2 or step_length_m >= 2.5:
        return jsonify({'message': 'step_length_m tidak masuk akal (range 0.2 - 2.5 m)'}), 400

    health = current_user.health
    if not health:
        health = UserHealth(user_id=current_user.id)
        db.session.add(health)

    health.step_length_m = step_length_m
    db.session.commit()

    return jsonify({
        'message': 'step_length_m tersimpan',
        'user_id': current_user.id,
        'step_length_m': float(step_length_m)
    }), 200


# ================= INTERNAL INGEST (FROM MQTT SUBSCRIBER) =================
def ingest_api_key_required():
    key = request.headers.get("X-API-KEY")
    return key and key == app.config["INGEST_API_KEY"]


@app.post("/api/ingest-esp32-batch")
def ingest_esp32_batch():
    # internal endpoint, protected by shared key
    if not ingest_api_key_required():
        return jsonify({"message": "Unauthorized"}), 401

    payload = request.get_json(silent=True) or {}
    if not _validate_esp32_batch(payload):
        return jsonify({"message": "Invalid ESP32 batch payload"}), 400

    user_id = int(payload["user_id"])
    user = User.query.get(user_id)
    if not user:
        return jsonify({"message": "User tidak ditemukan"}), 404

    # 1) PPG processing over samples[]
    samples = payload["samples"]
    last_ir = None
    last_red = None
    bpm = None
    spo2 = None

    for s in samples:
        ir = s.get("ir")
        red = s.get("red")
        last_ir = ir
        last_red = red
        if ir is None or red is None:
            continue

        try:
            bpm, spo2 = ppg_processor.add_sample(user_id, ir, red)
        except Exception:
            bpm, spo2 = None, None

        # fallback (same spirit as your existing logic) :contentReference[oaicite:6]{index=6}
        if bpm is None:
            try:
                bpm = 75 + (int(ir) % 5)
            except Exception:
                bpm = 75
        if spo2 is None:
            spo2 = 97.0

    # 2) Motion from accel time-series
    height_cm, step_len_m = _get_motion_params(user)
    steps, speed_mps = compute_steps_speed_from_batch(
        payload,
        height_cm=height_cm,
        calibrated_step_length_m=step_len_m,
    )

    status = determine_status(bpm, spo2)

    # Save reading (store last accel sample for accel_x/y/z columns)
    ax = payload.get("ax", [])
    ay = payload.get("ay", [])
    az = payload.get("az", [])
    accel_x = float(ax[-1]) if ax else None
    accel_y = float(ay[-1]) if ay else None
    accel_z = float(az[-1]) if az else None

    reading = SensorReading(
        user_id=user_id,
        ir_value=last_ir,
        red_value=last_red,
        temp_c=_safe_float(payload.get("temp_c")),
        humidity=_safe_float(payload.get("humidity")),
        accel_x=accel_x,
        accel_y=accel_y,
        accel_z=accel_z,
        bpm=bpm,
        spo2=spo2,
        steps=int(steps),
        speed_mps=float(speed_mps),
        status=status,
        activity=None,  # keep NULL (as you requested)
    )
    db.session.add(reading)
    db.session.commit()

    # Publish status to ESP32
    mqtt_publish(
        STATUS_TOPIC,
        {"user_id": user_id, "bpm": bpm, "spo2": spo2, "status": status},
        qos=0,
        retain=False,
        is_json=True,
    )

    # Publish motion summary (only steps + speed_mps)
    motion_payload = build_motion_payload(user_id, steps, speed_mps)
    mqtt_publish(
        MOTION_TOPIC,
        motion_payload,
        qos=0,
        retain=False,
        is_json=True,
    )

    speed_kmh = float(speed_mps) * 3.6

    return jsonify({
        "message": "OK",
        "reading_id": reading.id,
        "user_id": user_id,
        "steps": int(steps),
        "speed_kmh": round(speed_kmh, 2),
        "status": status,
    }), 200

# ================= DASHBOARD / HISTORY (unchanged core) =================
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
            'speed_mps': float(r.speed_mps) if r.speed_mps is not None else None,
            'steps': r.steps,
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


if __name__ == '__main__':
    app.run(debug=True)
