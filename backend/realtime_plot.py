import time
import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine
from config import Config

# ============== KONFIG ==============

DB_URI = Config.SQLALCHEMY_DATABASE_URI

USER_ID = 2      # ganti sesuai user yang mau dimonitor
LIMIT   = 200    # ambil N data terakhir untuk ditampilkan
REFRESH_INTERVAL_SEC = 2   # update grafik tiap 2 detik


# ============== FUNGSI LOAD DATA ==============

def load_data(user_id: int, limit: int = 200) -> pd.DataFrame:
    engine = create_engine(DB_URI)

    query = f"""
    SELECT 
        recorded_at,
        bpm,
        spo2,
        temp_c,
        humidity
    FROM sensor_readings
    WHERE user_id = {user_id}
    ORDER BY recorded_at DESC
    LIMIT {limit}
    """

    df = pd.read_sql(query, engine)

    if df.empty:
        return df

    # urutkan dari lama ke baru
    df = df.sort_values('recorded_at')

    # konversi tipe numeric
    for col in ['bpm', 'spo2', 'temp_c', 'humidity']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    df['recorded_at'] = pd.to_datetime(df['recorded_at'])
    df.set_index('recorded_at', inplace=True)

    return df


# ============== FUNGSI UPDATE PLOT ==============

def realtime_plot(user_id: int, limit: int, interval_sec: int):
    plt.ion()  # mode interaktif
    fig, axes = plt.subplots(4, 1, sharex=True, figsize=(12, 8))
    fig.suptitle(f"Realtime Sensor User ID {user_id}", fontsize=14)

    ax_bpm, ax_spo2, ax_temp, ax_hum = axes

    try:
        while True:
            df = load_data(user_id, limit)

            if df.empty:
                print("Belum ada data di DB, tunggu...")
                time.sleep(interval_sec)
                continue

            # ======== BPM ========
            ax_bpm.cla()
            ax_bpm.plot(df.index, df['bpm'], marker='o')
            ax_bpm.set_ylabel("BPM")
            ax_bpm.grid(True)

            # ======== SpO2 ========
            ax_spo2.cla()
            ax_spo2.plot(df.index, df['spo2'], marker='o')
            ax_spo2.set_ylabel("SpO₂ (%)")
            ax_spo2.grid(True)

            # ======== Suhu ========
            ax_temp.cla()
            ax_temp.plot(df.index, df['temp_c'], marker='o')
            ax_temp.set_ylabel("Suhu (°C)")
            ax_temp.grid(True)

            # ======== Humidity ========
            ax_hum.cla()
            ax_hum.plot(df.index, df['humidity'], marker='o')
            ax_hum.set_ylabel("Humidity (%)")
            ax_hum.set_xlabel("Waktu")
            ax_hum.grid(True)

            plt.tight_layout()
            plt.subplots_adjust(top=0.9)
            plt.pause(0.01)   # beri waktu ke matplotlib untuk refresh

            time.sleep(interval_sec)

    except KeyboardInterrupt:
        print("\nStop realtime plot.")
    finally:
        plt.ioff()
        plt.show()


if __name__ == "__main__":
    realtime_plot(USER_ID, LIMIT, REFRESH_INTERVAL_SEC)
