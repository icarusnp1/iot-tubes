# motion_processing.py
#
# Modul sederhana untuk:
# - deteksi langkah dari data akselerometer (MPU6500)
# - estimasi kecepatan (m/s) dari cadence × panjang langkah
#
# Catatan:
# - Ini pendekatan kira-kira untuk keperluan akademik / demo,
#   bukan algoritma klinis yang presisi.

import math
import time
from collections import deque


class MotionProcessor:
    def __init__(self):
        # state per user_id
        # tiap user punya:
        # - step_times: waktu-waktu deteksi langkah
        # - total_steps: jumlah langkah kumulatif
        # - was_above: status crossing threshold sebelumnya
        self.users = {}

    def _get_state(self, user_id):
        state = self.users.get(user_id)
        if state is None:
            state = {
                "step_times": deque(maxlen=50),  # simpan waktu langkah terakhir
                "total_steps": 0,
                "was_above": False,
            }
            self.users[user_id] = state
        return state

    def add_sample(self, user_id, accel_x, accel_y, accel_z, height_cm=None):
        """
        Tambahkan satu sampel akselerometer.
        accel_x, accel_y, accel_z dalam satuan 'g' (kira-kira, sesuai output mpu.getGValues()).

        Return:
            total_steps (int), speed_mps (float)
        """
        # kalau data accel tidak lengkap, jangan paksa hitung
        if accel_x is None or accel_y is None or accel_z is None:
            return 0, 0.0

        try:
            ax = float(accel_x)
            ay = float(accel_y)
            az = float(accel_z)
        except (TypeError, ValueError):
            return 0, 0.0

        # Magnitudo akselerasi total
        mag = math.sqrt(ax * ax + ay * ay + az * az)

        state = self._get_state(user_id)

        # Threshold sederhana:
        # - diasumsikan ketika berjalan/berlari,
        #   magnitudo akan "naik" melampaui ~1.1 g lalu turun lagi,
        #   kita pakai rising edge sebagai 1 langkah.
        threshold_high = 1.1  # g
        threshold_low  = 0.9  # reset di bawah hampir 1g

        step_detected = False

        if mag > threshold_high and not state["was_above"]:
            # crossing naik -> deteksi langkah
            step_detected = True
            state["was_above"] = True
        elif mag < threshold_low:
            # turun cukup jauh -> siap deteksi langkah berikutnya
            state["was_above"] = False

        if step_detected:
            t_now = time.time()
            state["step_times"].append(t_now)
            state["total_steps"] += 1

        # Hitung cadence dari window waktu langkah-langkah terakhir
        speed_mps = 0.0

        if len(state["step_times"]) >= 2:
            t_last = state["step_times"][-1]
            t_first = state["step_times"][0]
            duration = t_last - t_first

            if duration > 0:
                # langkah per detik (steps/s)
                steps_in_window = len(state["step_times"]) - 1
                cadence = steps_in_window / duration

                # Estimasi panjang langkah
                # Kalau height_cm diketahui, bisa pakai rumus kira-kira:
                #   step_length ≈ 0.415 × tinggi (m) -> walking
                # Kalau tidak diketahui, pakai default misal 0.7 m.
                if height_cm:
                    try:
                        h_m = float(height_cm) / 100.0
                        step_length_m = 0.415 * h_m
                    except Exception:
                        step_length_m = 0.7
                else:
                    step_length_m = 0.7  # default 70cm

                speed_mps = cadence * step_length_m

        return state["total_steps"], speed_mps


# instance global yang bisa diimport
motion_processor = MotionProcessor()
