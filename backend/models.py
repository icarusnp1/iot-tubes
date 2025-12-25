from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    id              = db.Column(db.Integer, primary_key=True)
    name            = db.Column(db.String(100), nullable=False)
    email           = db.Column(db.String(100), unique=True, nullable=False)
    password_hash   = db.Column(db.String(255), nullable=False)
    date_of_birth   = db.Column(db.Date, nullable=True)
    created_at      = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at      = db.Column(db.DateTime, default=datetime.utcnow,
                                onupdate=datetime.utcnow)

    health          = db.relationship("UserHealth", backref="user", uselist=False)
    readings        = db.relationship("SensorReading", backref="user", lazy=True)


class UserHealth(db.Model):
    __tablename__ = 'user_health'
    id          = db.Column(db.Integer, primary_key=True)
    user_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    blood_type  = db.Column(db.String(3))
    height_cm   = db.Column(db.Numeric(5,2))
    weight_kg   = db.Column(db.Numeric(5,2))
    bmi         = db.Column(db.Numeric(5,2))

    # NEW: hasil kalibrasi panjang langkah (meter)
    step_length_m = db.Column(db.Numeric(5,3))

    created_at  = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at  = db.Column(db.DateTime, default=datetime.utcnow,
                            onupdate=datetime.utcnow)


class SensorReading(db.Model):
    __tablename__ = 'sensor_readings'
    id          = db.Column(db.BigInteger, primary_key=True)
    user_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    recorded_at = db.Column(db.DateTime, default=datetime.utcnow)

    ir_value    = db.Column(db.BigInteger)
    red_value   = db.Column(db.BigInteger)
    temp_c      = db.Column(db.Numeric(5,2))
    humidity    = db.Column(db.Numeric(5,2))
    accel_x     = db.Column(db.Numeric(8,4))
    accel_y     = db.Column(db.Numeric(8,4))
    accel_z     = db.Column(db.Numeric(8,4))

    bpm         = db.Column(db.Numeric(6,2))
    spo2        = db.Column(db.Numeric(5,2))
    steps       = db.Column(db.Integer)
    speed_mps   = db.Column(db.Numeric(6,3))

    activity    = db.Column(db.Enum('idle','walking','jogging','running',
                                    name='activity_enum'))
    status      = db.Column(db.Enum('normal','warning','danger',
                                    name='status_enum'))

    created_at  = db.Column(db.DateTime, default=datetime.utcnow)
