from sqlalchemy import Column, Integer, BigInteger, String, Float, DateTime, JSON, func
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import text

Base = declarative_base()

class PpgBatch(Base):
    __tablename__ = "ppg_batch"
    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(64), index=True)
    ts = Column(DateTime, server_default=func.now())
    sample_count = Column(Integer)
    bpm = Column(Float, nullable=True)
    raw = Column(JSON)  # simpan array IR/RED (json)

class MotionBatch(Base):
    __tablename__ = "motion_batch"
    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(64), index=True)
    ts = Column(DateTime, server_default=func.now())
    sample_count = Column(Integer)
    raw = Column(JSON)

class EnvData(Base):
    __tablename__ = "env_data"
    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(64), index=True)
    ts = Column(DateTime, server_default=func.now())
    temp = Column(Float)
    hum = Column(Float)
