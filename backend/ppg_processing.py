import numpy as np
from collections import deque
from scipy.signal import butter, filtfilt

class PPGProcessor:
    def __init__(self, window_sec=10, fs=11):
        self.fs = fs  # frekuensi sampling dari ESP32
        self.window_size = window_sec * fs

        self.ir_buffer = {}
        self.red_buffer = {}

        self.prev_bpm = {}

        # Butterworth bandpass filter untuk PPG (0.5–4 Hz)
        self.b, self.a = butter(
            N=3,
            Wn=[0.5 / (fs/2), 4 / (fs/2)],
            btype='band'
        )

    def add_sample(self, user_id, ir, red, accel_z=None):
        """Input 1 sampel RAW, output (bpm, spo2) jika window cukup."""

        if user_id not in self.ir_buffer:
            self.ir_buffer[user_id] = deque(maxlen=self.window_size)
            self.red_buffer[user_id] = deque(maxlen=self.window_size)
            self.prev_bpm[user_id] = None

        # ---- 1. Motion artifact detection ----
        if accel_z is not None and abs(accel_z - 1.0) > 0.15:
            # Gerakan besar, skip hitung
            return self.prev_bpm[user_id], None

        self.ir_buffer[user_id].append(ir)
        self.red_buffer[user_id].append(red)

        # window belum cukup → return None
        if len(self.ir_buffer[user_id]) < self.window_size:
            return None, None

        ir_arr = np.array(self.ir_buffer[user_id], dtype=float)

        # ---- 2. Bandpass filter ----
        ir_f = filtfilt(self.b, self.a, ir_arr)

        # ---- 3. DC removal ----
        ir_ac = ir_f - np.mean(ir_f)

        # ---- 4. Peak detection ----
        peaks = self.detect_peaks(ir_ac)

        if len(peaks) < 2:
            return None, None

        # Hitung BPM
        peak_intervals = np.diff(peaks) / self.fs
        avg_interval = np.mean(peak_intervals)

        bpm = 60.0 / avg_interval

        # ---- 5. BPM smoothing ----
        if self.prev_bpm[user_id] is None:
            self.prev_bpm[user_id] = bpm
        else:
            self.prev_bpm[user_id] = self.prev_bpm[user_id] * 0.7 + bpm * 0.3

        bpm_final = round(self.prev_bpm[user_id], 1)

        # ======================
        # SPO2 (versi basic saja)
        # ======================
        spo2 = self.compute_spo2(np.array(self.ir_buffer[user_id]),
                                 np.array(self.red_buffer[user_id]))

        return bpm_final, spo2

    # -----------------------------
    # Peak Detection (PPG improved)
    # -----------------------------
    def detect_peaks(self, data):
        peaks = []
        threshold = np.mean(data) + 0.5 * np.std(data)

        for i in range(1, len(data)-1):
            if data[i] > data[i-1] and data[i] > data[i+1]:
                if data[i] > threshold:
                    peaks.append(i)

        return peaks

    # ---------------------
    # SpO2 naive estimation
    # ---------------------
    def compute_spo2(self, ir, red):
        # Basic ratio-of-ratios model
        ac_ir = ir - np.mean(ir)
        ac_red = red - np.mean(red)

        if np.std(ac_ir) == 0:
            return None

        R = (np.std(ac_red) / np.std(ac_ir))

        spo2 = 110 - 25 * R
        spo2 = np.clip(spo2, 70, 100)

        return round(float(spo2), 1)

# Global instance
ppg_processor = PPGProcessor(window_sec=12, fs=11)
