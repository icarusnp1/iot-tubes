import pandas as pd
import matplotlib.pyplot as plt
from sqlalchemy import create_engine
from config import Config

DB_URI = Config.SQLALCHEMY_DATABASE_URI
USER_ID = 2
LIMIT = 200


def load_data(user_id: int, limit: int = 200) -> pd.DataFrame:
    engine = create_engine(DB_URI)

    # Pakai f-string, tanpa :uid
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
        print(f"Tidak ada data untuk user_id = {user_id}")
        return df

    # urutkan dari lama ke baru
    df = df.sort_values('recorded_at')

    # pastikan tipe numeric
    for col in ['bpm', 'spo2', 'temp_c', 'humidity']:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors='coerce')

    df['recorded_at'] = pd.to_datetime(df['recorded_at'])
    df.set_index('recorded_at', inplace=True)

    return df


def plot_sensor_data(df: pd.DataFrame, user_id: int):
    if df.empty:
        return

    plt.rcParams['figure.figsize'] = (12, 8)

    fig, axes = plt.subplots(4, 1, sharex=True)
    fig.suptitle(f"Riwayat Sensor User ID {user_id}", fontsize=14)

    # 1. BPM
    axes[0].plot(df.index, df['bpm'], marker='o')
    axes[0].set_ylabel("BPM")
    axes[0].grid(True)

    # 2. SpO2
    axes[1].plot(df.index, df['spo2'], marker='o')
    axes[1].set_ylabel("SpO₂ (%)")
    axes[1].grid(True)

    # 3. Suhu
    axes[2].plot(df.index, df['temp_c'], marker='o')
    axes[2].set_ylabel("Suhu (°C)")
    axes[2].grid(True)

    # 4. Humidity
    axes[3].plot(df.index, df['humidity'], marker='o')
    axes[3].set_ylabel("Humidity (%)")
    axes[3].set_xlabel("Waktu")
    axes[3].grid(True)

    plt.tight_layout()
    plt.subplots_adjust(top=0.9)
    plt.show()


if __name__ == "__main__":
    df = load_data(USER_ID, LIMIT)
    if not df.empty:
        print(df.tail())
        plot_sensor_data(df, USER_ID)