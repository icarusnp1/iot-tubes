from sqlalchemy.ext.asyncio import AsyncSession
from . import models, utils
from typing import List, Dict
from datetime import datetime

async def save_ppg_batch(session: AsyncSession, device_id: str, ts: datetime, ppg_array: List[Dict]):
    # ppg_array items: {"ts": float, "ir": int, "red": int}
    # prepare lists for BPM calculation
    ir_values = [int(x.get("ir", 0)) for x in ppg_array]
    # timestamps absolute or relative: if values < 1000 assume seconds relative; here use provided ts base if relative
    # Convert to absolute timestamps in seconds (we can add batch ts + relative ts)
    base = ts.timestamp()
    timestamps = []
    for x in ppg_array:
        rel = x.get("ts", 0.0)
        timestamps.append(base + float(rel))

    # convert timestamps to relative seconds for BPM function
    rel_times = [t - timestamps[0] for t in timestamps]

    bpm = utils.calculate_bpm_from_ir(ir_values, rel_times)

    obj = models.PpgBatch(device_id=device_id, ts=ts, sample_count=len(ppg_array), bpm=bpm, raw=ppg_array)
    session.add(obj)
    await session.commit()
    await session.refresh(obj)
    return obj

async def save_motion_batch(session: AsyncSession, device_id: str, ts: datetime, motion_array: List[Dict]):
    obj = models.MotionBatch(device_id=device_id, ts=ts, sample_count=len(motion_array), raw=motion_array)
    session.add(obj)
    await session.commit()
    await session.refresh(obj)
    return obj

async def save_env(session: AsyncSession, device_id: str, ts: datetime, temp: float, hum: float):
    obj = models.EnvData(device_id=device_id, ts=ts, temp=temp, hum=hum)
    session.add(obj)
    await session.commit()
    await session.refresh(obj)
    return obj
