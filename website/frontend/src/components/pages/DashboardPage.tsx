import { MetricCard } from '../dashboard/MetricCard';
import { HealthStatusCard } from '../dashboard/HealthStatusCard';
import { ChartCard } from '../dashboard/ChartCard';
import { SyncPanel } from '../dashboard/SyncPanel';
//import { ActivityIndicator } from '../dashboard/ActivityIndicator';
import { Heart, Droplets, Thermometer, Wind, Gauge, Footprints, Flame, Activity } from 'lucide-react';
import { useState, useEffect } from 'react';
import { toast } from 'sonner';

interface DashboardPageProps {
  isDarkMode: boolean;
  userId: number;
}

interface SensorData {
  bpm: number;
  spo2: number;
  temperature: number;
  humidity: number;
  speed?: number;
  steps?: number;
  calories?: number;
  activity?: string;
}

export function DashboardPage({ isDarkMode, userId }: DashboardPageProps) {
  const [data, setData] = useState<SensorData>({
    bpm: 0,
    spo2: 0,
    temperature: 0,
    humidity: 0,
    speed: 0,
    steps: 0,
    calories: 0,
    activity: "idle",
  });

  // Fetch data real dari backend
  const fetchLiveData = async () => {
  try {
    const res = await fetch(
      `http://sem5.test/iot-tubes/website/backend/get_latest_sensor.php?user_id=${userId}`
    );

    const result = await res.json();
    if (!res.ok) throw new Error(result.message || "Gagal mengambil data sensor");

    const d = result.data || {}; // kalau null → object kosong

    setData({
      bpm: Number(d.bpm) || 0,
      spo2: Number(d.spo2) || 0,
      temperature: Number(d.temp_c) || 0,     // ← tabel: temp_c
      humidity: Number(d.humidity) || 0,
      speed: Number(d.speed_mps) || 0,        // ← tabel: speed_mps
      steps: Number(d.steps) || 0,
      calories: 0,                             // database TIDAK punya 'calories'
      activity: d.activity || "idle",
    });

  } catch (err: any) {
    console.error(err);
    toast.error("Gagal memuat data terbaru");
  }
};


  // Update setiap 3 detik
  useEffect(() => {
    fetchLiveData();
    const interval = setInterval(fetchLiveData, 3000);
    return () => clearInterval(interval);
  }, [userId]);

  // STATUS LOGIC
  const getBPMStatus = (v: number) => {
    if (v < 60) return { status: "Bradikardi", color: "#FF9800" };
    if (v > 100) return { status: "Takikardi", color: "#E53935" };
    return { status: "Normal", color: "#2ECC71" };
  };

  const getSpo2Status = (v: number) => {
    if (v < 90) return { status: "Hipoksemia Berat", color: "#E53935" };
    if (v < 95) return { status: "Hipoksemia Ringan", color: "#FF9800" };
    return { status: "Normal", color: "#2ECC71" };
  };

  const getTemperatureStatus = (v: number) => {
    if (v < 22) return { status: "Dingin", color: "#2196F3" };
    if (v > 26) return { status: "Panas", color: "#E53935" };
    return { status: "Normal", color: "#2ECC71" };
  };

  const getHumidityStatus = (v: number) => {
    if (v < 40) return { status: "Kering", color: "#FF9800" };
    if (v > 60) return { status: "Lembap", color: "#2196F3" };
    return { status: "Normal", color: "#2ECC71" };
  };

  const bpmStatus = getBPMStatus(data.bpm);
  const spo2Status = getSpo2Status(data.spo2);
  const tempStatus = getTemperatureStatus(data.temperature);
  const humidityStatus = getHumidityStatus(data.humidity);

  const isAbnormal = data.bpm < 60 || data.bpm > 100 || data.spo2 < 95;

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
      
      {/* ALERT */}  
      {isAbnormal && (
        <div className="mb-6 p-4 bg-[#E53935]/10 border-l-4 border-[#E53935] rounded-lg">
          <p className="text-sm text-[#E53935]">
            ⚠️ Peringatan: Data kesehatan menunjukkan nilai abnormal.
          </p>
        </div>
      )}

      {/* DETAK JANTUNG */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#E53935] to-[#C62828] rounded-lg">
            <Heart className="w-5 h-5 text-white" />
          </div>
          <h2 className="text-xl">Monitor Detak Jantung</h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <HealthStatusCard
            title="Detak Jantung"
            value={data.bpm}
            unit="BPM"
            isDarkMode={isDarkMode}
            type="bpm"
            mainIcon={Heart}
            mainColor={bpmStatus.color}
          />

          <HealthStatusCard
            title="Saturasi Oksigen"
            value={data.spo2}
            unit="%"
            isDarkMode={isDarkMode}
            type="spo2"
            mainIcon={Droplets}
            mainColor={spo2Status.color}
          />
        </div>
      </div>

      {/* TEMPERATUR
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#FF9800] to-[#F57C00] rounded-lg">
            <Thermometer className="w-5 h-5 text-white" />
          </div>
          <h2 className="text-xl">Monitor Temperatur</h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <HealthStatusCard
            title="Suhu Ruangan"
            value={data.temperature}
            unit="°C"
            isDarkMode={isDarkMode}
            type="temperature"
            mainIcon={Thermometer}
            mainColor={tempStatus.color}
          />

          <HealthStatusCard
            title="Kelembapan"
            value={data.humidity}
            unit="%"
            isDarkMode={isDarkMode}
            type="humidity"
            mainIcon={Wind}
            mainColor={humidityStatus.color}
          />
        </div>
      </div> */}

      {/* AKTIVITAS */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#2ECC71] to-[#27AE60] rounded-lg">
            <Activity className="w-5 h-5 text-white" />
          </div>
          <h2 className="text-xl">Monitoring Aktivitas</h2>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <MetricCard
            title="Kecepatan"
            value={data.speed?.toFixed(1) || "0"}
            unit="km/jam"
            icon={Gauge}
            color="#2ECC71"
            isDarkMode={isDarkMode}
          />

          <MetricCard
            title="Langkah"
            value={data.steps || 0}
            unit="steps"
            icon={Footprints}
            color="#9C27B0"
            isDarkMode={isDarkMode}
          />

          <MetricCard
            title="Kalori"
            value={data.calories || 0}
            unit="kcal"
            icon={Flame}
            color="#FF5722"
            isDarkMode={isDarkMode}
          />
        </div>

        {/* <ActivityIndicator activity={data.activity as any} isDarkMode={isDarkMode} /> */}
      </div>

      {/* GRAFIK */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-10">
        <ChartCard
          title="Grafik Detak Jantung"
          type="bpm"
          isDarkMode={isDarkMode}
          currentValue={data.bpm}
          userId={userId}
        />

        <ChartCard
          title="Grafik SpO₂"
          type="spo2"
          isDarkMode={isDarkMode}
          currentValue={data.spo2}
          userId={userId}
        />
      </div>

      <SyncPanel isDarkMode={isDarkMode} />
    </div>
  );
}