import math
from typing import List, Optional

def moving_average(signal: List[float], window: int = 5) -> List[float]:
    if window <= 1:
        return signal[:]
    out = []
    s = 0.0
    for i, v in enumerate(signal):
        s += v
        if i >= window:
            s -= signal[i-window]
            out.append(s / window)
        else:
            out.append(s / (i+1))
    return out

def detect_peaks(signal: List[float], threshold: float):
    peaks = []
    for i in range(1, len(signal)-1):
        if signal[i] > signal[i-1] and signal[i] > signal[i+1] and signal[i] > threshold:
            peaks.append(i)
    return peaks

def calculate_bpm_from_ir(ir_values: List[int], timestamps: List[float]) -> Optional[float]:
    """
    ir_values: list of IR integers
    timestamps: list of float (seconds) same length as ir_values
    returns BPM (float) or None if cannot compute
    """
    if len(ir_values) < 20 or len(ir_values) != len(timestamps):
        return None

    # smoothing
    smooth = moving_average(ir_values, window=4)

    mean_val = sum(smooth) / len(smooth)
    # threshold adaptif
    threshold = mean_val * 1.02  # naik 2% dari rata-rata

    peaks = detect_peaks(smooth, threshold)

    if len(peaks) < 2:
        return None

    # convert peak indices to timestamps
    peak_times = [timestamps[p] for p in peaks]
    intervals = [peak_times[i+1] - peak_times[i] for i in range(len(peak_times)-1) if peak_times[i+1] - peak_times[i] > 0.25]
    if not intervals:
        return None
    avg_interval = sum(intervals) / len(intervals)
    bpm = 60.0 / avg_interval
    # sanity range
    if bpm < 30 or bpm > 220:
        return None
    return round(bpm, 2)
