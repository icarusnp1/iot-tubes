# config.py
import os

class Config:
    # ganti user/pass/host/db sesuai MySQL kamu
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "mysql+pymysql://root:@localhost/heart_monitoring"
    )
    INGEST_API_KEY = os.getenv("INGEST_API_KEY", "dev-ingest-key")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key")
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "super-secret-jwt-key")
