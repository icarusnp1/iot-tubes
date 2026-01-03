# motion_algo.py
# Modul tunggal (single file) untuk:
# - deteksi langkah dari akselerometer (ax/ay/az dalam g)
# - estimasi kecepatan (m/s) dari cadence × panjang langkah
#
# Dirancang untuk input batch ESP32:
# {
#   "user_id": 2,
#   "t0_ms": 1730000000000,
#   "dt_ms": 40,
#   "ax": [...],
#   "ay": [...],
#   "az": [...]
# }

import math
from collections import deque
from typing import Optional, Dict, Any, Tuple


class _UserState:
    def __init__(self):
        self.step_times = deque(maxlen=30)  # time of detected steps (seconds)
        self.total_steps = 0

        # low-pass filtered magnitude
        self.mag_lp = 1.0

        # anti-double-count
        self.last_step_time = -1e9

        # hysteresis state (stuck prevention relies on this)
        self.was_above = False
        self.last_above_time = -1e9  # last time magnitude was above thr_high


class MotionEngine:
    """
    Engine stateful per-user.
    """

    def __init__(
        self,
        # Filtering
        lp_alpha: float = 0.25,

        # Window stats for adaptive threshold
        mag_window: int = 60,

        # Step cadence window
        cadence_window_steps: int = 30,

        # Anti double-count
        refractory_ms: int = 200,

        # Adaptive threshold factor
        thr_k: float = 1.0,

        # Clamp threshold so it doesn't go crazy
        min_thr_g: float = 1.05,
        max_thr_g: float = 1.80,

        # Hysteresis gap controls "reset sensitivity"
        # smaller gap => easier to reset => less stuck
        hysteresis_gap_g: float = 0.08,

        # If stuck above threshold too long, force reset
        above_timeout_s: float = 1.0,
    ):
        self.lp_alpha = float(lp_alpha)
        self.mag_window = int(mag_window)
        self.cadence_window_steps = int(cadence_window_steps)
        self.refractory_s = float(refractory_ms) / 1000.0

        self.thr_k = float(thr_k)
        self.min_thr_g = float(min_thr_g)
        self.max_thr_g = float(max_thr_g)

        self.hysteresis_gap_g = float(hysteresis_gap_g)
        self.above_timeout_s = float(above_timeout_s)

        self.users: Dict[int, _UserState] = {}
        self.mag_hist: Dict[int, deque] = {}

    def _state(self, user_id: int) -> _UserState:
        if user_id not in self.users:
            self.users[user_id] = _UserState()
            self.users[user_id].step_times = deque(maxlen=self.cadence_window_steps)
            self.mag_hist[user_id] = deque(maxlen=self.mag_window)
        return self.users[user_id]

    @staticmethod
    def _mean_std(data: deque) -> Tuple[float, float]:
        n = len(data)
        if n == 0:
            return 1.0, 0.0
        mean = sum(data) / n
        if n < 2:
            return mean, 0.0
        var = sum((x - mean) ** 2 for x in data) / (n - 1)
        return mean, math.sqrt(var)

    @staticmethod
    def _step_length_m(
        height_cm: Optional[float],
        cadence_sps: float,
        calibrated_step_length_m: Optional[float],
    ) -> float:
        """
        Priority:
        1) calibrated_step_length_m (if provided)
        2) height-based estimate
        3) default 0.70 m
        """
        if calibrated_step_length_m is not None:
            try:
                v = float(calibrated_step_length_m)
                if v > 0:
                    return max(0.30, min(v, 1.80))
            except Exception:
                pass

        base = 0.70
        if height_cm is not None:
            try:
                h = float(height_cm)
                if h > 0:
                    base = 0.415 * (h / 100.0)
            except Exception:
                pass

        # mild adjustment by cadence (optional)
        adj = 1.0 + 0.15 * max(0.0, cadence_sps - 2.0)
        step_len = base * adj
        return max(0.30, min(step_len, 1.80))

    def process_batch(
        self,
        batch: Dict[str, Any],
        *,
        height_cm: Optional[float] = None,
        calibrated_step_length_m: Optional[float] = None,
    ) -> Tuple[int, float]:
        """
        Compute cumulative total_steps and instantaneous speed (m/s) from an ESP32 batch.
        """
        user_id = int(batch["user_id"])
        t0_ms = float(batch["t0_ms"])
        dt_ms = float(batch["dt_ms"])

        ax = batch.get("ax", [])
        ay = batch.get("ay", [])
        az = batch.get("az", [])

        n = min(len(ax), len(ay), len(az))
        if n <= 0:
            st = self._state(user_id)
            return int(st.total_steps), 0.0

        st = self._state(user_id)
        hist = self.mag_hist[user_id]

        speed_mps = 0.0

        for i in range(n):
            # timestamp for this sample
            t_s = (t0_ms + i * dt_ms) / 1000.0

            # magnitude (in g)
            try:
                mag = math.sqrt(float(ax[i]) ** 2 + float(ay[i]) ** 2 + float(az[i]) ** 2)
            except Exception:
                continue

            # low-pass filter
            a = self.lp_alpha
            st.mag_lp = (1.0 - a) * st.mag_lp + a * mag
            mf = st.mag_lp

            # update rolling stats
            hist.append(mf)
            mean, std = self._mean_std(hist)

            # adaptive threshold + clamp
            thr = mean + self.thr_k * std
            thr_high = max(self.min_thr_g, min(thr, self.max_thr_g))

            # hysteresis low threshold (closer => easier reset => less stuck)
            thr_low = max(0.95, thr_high - self.hysteresis_gap_g)

            # ---- stuck prevention: force reset if too long above threshold
            if mf > thr_high:
                st.last_above_time = t_s
            if st.was_above and (t_s - st.last_above_time) > self.above_timeout_s:
                st.was_above = False

            # ---- hysteresis step detection (rising-edge)
            step_detected = False
            if (mf > thr_high) and (not st.was_above) and ((t_s - st.last_step_time) >= self.refractory_s):
                step_detected = True
                st.was_above = True
            elif mf < thr_low:
                st.was_above = False

            if step_detected:
                st.last_step_time = t_s
                st.total_steps += 1
                st.step_times.append(t_s)

            # compute speed from cadence window
            if len(st.step_times) >= 2:
                duration = st.step_times[-1] - st.step_times[0]
                if duration > 0:
                    steps_in_window = len(st.step_times) - 1
                    cadence_sps = steps_in_window / duration

                    step_len = self._step_length_m(
                        height_cm=height_cm,
                        cadence_sps=cadence_sps,
                        calibrated_step_length_m=calibrated_step_length_m,
                    )
                    speed_mps = cadence_sps * step_len

        return int(st.total_steps), float(speed_mps)


# ---------------- Public API ----------------

_motion_engine = MotionEngine(
    # TUNING DEFAULTS (good starting point)
    lp_alpha=0.25,
    mag_window=60,
    cadence_window_steps=30,
    refractory_ms=200,
    thr_k=1.0,
    min_thr_g=1.05,
    max_thr_g=1.80,
    hysteresis_gap_g=0.08,   # key for "not stuck"
    above_timeout_s=1.0,     # key for "not stuck"
)


def compute_steps_speed_from_batch(
    batch: Dict[str, Any],
    *,
    height_cm: Optional[float] = None,
    calibrated_step_length_m: Optional[float] = None,
) -> Tuple[int, float]:
    """
    Main function to call from app.py
    Returns: (total_steps, speed_mps)
    """
    return _motion_engine.process_batch(
        batch,
        height_cm=height_cm,
        calibrated_step_length_m=calibrated_step_length_m,
    )


def build_motion_payload(user_id: int, steps: int, speed_mps: float) -> Dict[str, Any]:
    """
    Payload ringkas sesuai kebutuhan publish:
    only steps + speed_mps
    """
    return {
        "user_id": int(user_id),
        "steps": int(steps),
        "speed_mps": float(speed_mps),
    }
