# ppg_processing.py
from collections import deque, defaultdict
import time
import math
from statistics import mean, pstdev

class PPGProcessor:
    """
    Processor sederhana untuk menghitung BPM & SpO2 dari raw IR/RED.
    Menyimpan buffer per user.

    Catatan:
    - Asumsi data datang periodik (idealnya 25-50 Hz).
    - Masih algoritma sederhana, cocok untuk demo / tugas, bukan alat medis.
    """
    def __init__(self, window_sec=8.0, min_bpm=40, max_bpm=180):
        self.window_sec = window_sec
        self.min_bpm = min_bpm
        self.max_bpm = max_bpm

        # buffers[user_id] = deque of (timestamp, ir, red)
        self.buffers = defaultdict(lambda: deque())

    def add_sample(self, user_id, ir_value, red_value, timestamp=None):
        """
        Tambah 1 sampel PPG untuk user tertentu.
        Return (bpm, spo2) -> bisa None kalau data belum cukup.
        """
        if timestamp is None:
            timestamp = time.time()

        buf = self.buffers[user_id]
        buf.append((timestamp, ir_value, red_value))

        # buang data yang lebih tua dari window_sec
        cutoff = timestamp - self.window_sec
        while buf and buf[0][0] < cutoff:
            buf.popleft()

        # butuh minimal beberapa detik data
        if len(buf) < 10:
            return None, None

        return self._compute_from_buffer(list(buf))

    def _compute_from_buffer(self, samples):
        """
        samples: list of (t, ir, red) dalam window.
        """
        times = [s[0] for s in samples]
        ir_values = [float(s[1]) for s in samples]
        red_values = [float(s[2]) for s in samples]

        # --- BPM dari IR ---
        bpm = self._compute_bpm(times, ir_values)

        # --- SpO2 dari IR & RED ---
        spo2 = self._compute_spo2(ir_values, red_values)

        return bpm, spo2

    def _compute_bpm(self, times, ir_values):
        if len(ir_values) < 5:
            return None

        dc_ir = mean(ir_values)
        ac_ir = [v - dc_ir for v in ir_values]

        # hitung std dev AC
        std_ir = pstdev(ac_ir) if len(ac_ir) > 1 else 0.0
        if std_ir == 0:
            return None

        # threshold untuk peak
        threshold = min(dc_ir * 0.01, std_ir * 0.5)  # heuristik
        # tapi karena kita kerja di AC (center di 0), pakai std saja
        threshold = std_ir * 0.5

        # cari local maxima
        peaks = []
        for i in range(1, len(ac_ir) - 1):
            if ac_ir[i] > ac_ir[i-1] and ac_ir[i] > ac_ir[i+1] and ac_ir[i] > threshold:
                peaks.append((times[i], ac_ir[i]))

        if len(peaks) < 2:
            return None

        # filter peaks berdasarkan jarak (min/max BPM)
        min_interval = 60.0 / self.max_bpm  # detik
        max_interval = 60.0 / self.min_bpm

        filtered_peaks = []
        last_peak_time = None
        for t, amp in peaks:
            if last_peak_time is None:
                filtered_peaks.append((t, amp))
                last_peak_time = t
            else:
                dt = t - last_peak_time
                if min_interval <= dt <= max_interval:
                    filtered_peaks.append((t, amp))
                    last_peak_time = t
                elif dt > max_interval:
                    # kalau terlalu jauh, anggap ini peak baru dan reset
                    filtered_peaks.append((t, amp))
                    last_peak_time = t
                # kalau terlalu dekat (< min_interval) di-skip

        if len(filtered_peaks) < 2:
            return None

        intervals = []
        for i in range(1, len(filtered_peaks)):
            dt = filtered_peaks[i][0] - filtered_peaks[i-1][0]
            if min_interval <= dt <= max_interval:
                intervals.append(dt)

        if not intervals:
            return None

        mean_rr = sum(intervals) / len(intervals)  # detik
        bpm = 60.0 / mean_rr

        # filter lagi biar nggak terlalu liar
        if bpm < self.min_bpm or bpm > self.max_bpm:
            return None

        return round(bpm, 2)

    def _compute_spo2(self, ir_values, red_values):
        if len(ir_values) < 5 or len(red_values) < 5:
            return None

        dc_ir = mean(ir_values)
        dc_red = mean(red_values)
        if dc_ir == 0 or dc_red == 0:
            return None

        ac_ir = [v - dc_ir for v in ir_values]
        ac_red = [v - dc_red for v in red_values]

        # gunakan std dev sebagai AC amplitude
        ac_ir_std = pstdev(ac_ir) if len(ac_ir) > 1 else 0.0
        ac_red_std = pstdev(ac_red) if len(ac_red) > 1 else 0.0

        if ac_ir_std == 0 or ac_red_std == 0:
            return None

        # Ratio of Ratios
        R = (ac_red_std / dc_red) / (ac_ir_std / dc_ir)

        # Rumus empiris (approx) : SpO2 = 110 - 25*R
        spo2 = 110.0 - 25.0 * R

        # clamp ke range masuk akal
        spo2 = max(70.0, min(100.0, spo2))

        return round(spo2, 2)


# buat instance global yang bisa dipakai di mana-mana
ppg_processor = PPGProcessor(window_sec=8.0, min_bpm=40, max_bpm=180)
