import { MetricCard } from '../dashboard/MetricCard';
import { HealthStatusCard } from '../dashboard/HealthStatusCard';
import { ChartCard } from '../dashboard/ChartCard';
import { SyncPanel } from '../dashboard/SyncPanel';
import { ActivityIndicator } from '../dashboard/ActivityIndicator';
import { Heart, Droplets, Thermometer, Wind, Gauge, Footprints, Flame, Activity } from 'lucide-react';
import { useState, useEffect } from 'react';

interface DashboardPageProps {
  isDarkMode: boolean;
}

export function DashboardPage({ isDarkMode }: DashboardPageProps) {
  const [bpm, setBpm] = useState(75);
  const [spo2, setSpo2] = useState(98);
  const [temperature, setTemperature] = useState(28);
  const [humidity, setHumidity] = useState(65);
  const [speed, setSpeed] = useState(8.5);
  const [steps, setSteps] = useState(8247);
  const [calories, setCalories] = useState(342);
  const [activity, setActivity] = useState<'idle' | 'walking' | 'jogging' | 'running'>('walking');

  // Simulate real-time data updates
  useEffect(() => {
    const interval = setInterval(() => {
      setBpm(prev => Math.max(50, Math.min(110, prev + (Math.random() * 4 - 2))));
      setSpo2(prev => Math.max(90, Math.min(100, prev + (Math.random() * 2 - 1))));
      setTemperature(prev => Math.max(20, Math.min(35, prev + (Math.random() * 1 - 0.5))));
      setHumidity(prev => Math.max(30, Math.min(80, prev + (Math.random() * 4 - 2))));
      setSpeed(prev => Math.max(0, Math.min(15, prev + (Math.random() * 2 - 1))));
      setSteps(prev => prev + Math.floor(Math.random() * 10));
      setCalories(prev => prev + Math.floor(Math.random() * 3));
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  // BPM Status: Normal (60-100), Bradikardi (<60), Takikardi (>100)
  const getBPMStatus = (value: number) => {
    if (value < 60) {
      return { 
        status: 'Bradikardi', 
        color: '#FF9800', 
        range: 'Rentang Normal: 60-100 BPM',
        description: 'Detak jantung lebih lambat dari normal'
      };
    }
    if (value > 100) {
      return { 
        status: 'Takikardi', 
        color: '#E53935', 
        range: 'Rentang Normal: 60-100 BPM',
        description: 'Detak jantung lebih cepat dari normal'
      };
    }
    return { 
      status: 'Normal', 
      color: '#2ECC71', 
      range: 'Rentang Normal: 60-100 BPM',
      description: 'Detak jantung dalam kondisi baik'
    };
  };

  // SpO2 Status: Normal (95-100%), Hipoksemia (<95%)
  const getSpo2Status = (value: number) => {
    if (value < 90) {
      return { 
        status: 'Hipoksemia Berat', 
        color: '#E53935', 
        range: 'Rentang Normal: 95-100%',
        description: 'Kadar oksigen sangat rendah'
      };
    }
    if (value < 95) {
      return { 
        status: 'Hipoksemia Ringan', 
        color: '#FF9800', 
        range: 'Rentang Normal: 95-100%',
        description: 'Kadar oksigen sedikit rendah'
      };
    }
    return { 
      status: 'Normal', 
      color: '#2ECC71', 
      range: 'Rentang Normal: 95-100%',
      description: 'Kadar oksigen optimal'
    };
  };

  // Temperature Status: Normal (22-26°C), Dingin (<22°C), Panas (>26°C)
  const getTemperatureStatus = (value: number) => {
    if (value < 22) return { status: 'Dingin', color: '#2196F3', range: 'Normal: 22-26°C' };
    if (value > 26) return { status: 'Panas', color: '#E53935', range: 'Normal: 22-26°C' };
    return { status: 'Normal', color: '#2ECC71', range: 'Normal: 22-26°C' };
  };

  // Humidity Status: Normal (40-60%), Kering (<40%), Lembap (>60%)
  const getHumidityStatus = (value: number) => {
    if (value < 40) return { status: 'Kering', color: '#FF9800', range: 'Normal: 40-60%' };
    if (value > 60) return { status: 'Lembap', color: '#2196F3', range: 'Normal: 40-60%' };
    return { status: 'Normal', color: '#2ECC71', range: 'Normal: 40-60%' };
  };

  const bpmStatus = getBPMStatus(Math.round(bpm));
  const spo2Status = getSpo2Status(Math.round(spo2));
  const tempStatus = getTemperatureStatus(temperature);
  const humidityStatus = getHumidityStatus(Math.round(humidity));

  const isAbnormal = bpm > 100 || bpm < 60 || spo2 < 95;

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
      {/* Abnormal Alert */}
      {isAbnormal && (
        <div className="mb-6 p-4 bg-[#E53935]/10 border-l-4 border-[#E53935] rounded-lg">
          <p className="text-sm text-[#E53935]">
            ⚠️ Peringatan: Data kesehatan menunjukkan nilai abnormal. Segera konsultasi dengan dokter.
          </p>
        </div>
      )}

      {/* KELOMPOK 1: Monitor Detak Jantung */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#E53935] to-[#C62828] rounded-lg">
            <Heart className="w-5 h-5 text-white" />
          </div>
          <h2 className={`text-xl ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Monitor Detak Jantung
          </h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <HealthStatusCard
            title="Detak Jantung"
            value={Math.round(bpm)}
            unit="BPM"
            isDarkMode={isDarkMode}
            type="bpm"
            mainIcon={Heart}
            mainColor="#E53935"
          />
          
          <HealthStatusCard
            title="Saturasi Oksigen (SpO₂)"
            value={Math.round(spo2)}
            unit="%"
            isDarkMode={isDarkMode}
            type="spo2"
            mainIcon={Droplets}
            mainColor="#0077B6"
          />
        </div>
      </div>

      {/* KELOMPOK 2: Monitor Temperatur */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#FF9800] to-[#F57C00] rounded-lg">
            <Thermometer className="w-5 h-5 text-white" />
          </div>
          <h2 className={`text-xl ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Monitor Temperatur
          </h2>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <HealthStatusCard
            title="Suhu Ruangan"
            value={parseFloat(temperature.toFixed(1))}
            unit="°C"
            isDarkMode={isDarkMode}
            type="temperature"
            mainIcon={Thermometer}
            mainColor="#FF9800"
          />
          
          <HealthStatusCard
            title="Kelembapan Udara"
            value={Math.round(humidity)}
            unit="%"
            isDarkMode={isDarkMode}
            type="humidity"
            mainIcon={Wind}
            mainColor="#2196F3"
          />
        </div>
      </div>

      {/* KELOMPOK 3: Monitoring Aktivitas */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#2ECC71] to-[#27AE60] rounded-lg">
            <Activity className="w-5 h-5 text-white" />
          </div>
          <h2 className={`text-xl ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Monitoring Aktivitas
          </h2>
        </div>
        
        {/* Metric Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <MetricCard
            title="Kecepatan"
            value={speed.toFixed(1)}
            unit="km/jam"
            icon={Gauge}
            color="#2ECC71"
            isDarkMode={isDarkMode}
          />
          
          <MetricCard
            title="Langkah"
            value={steps.toLocaleString()}
            unit="steps"
            icon={Footprints}
            color="#9C27B0"
            isDarkMode={isDarkMode}
          />
          
          <MetricCard
            title="Kalori"
            value={calories}
            unit="kcal"
            icon={Flame}
            color="#FF5722"
            isDarkMode={isDarkMode}
          />
        </div>

        {/* Activity Status Cards */}
        <ActivityIndicator activity={activity} isDarkMode={isDarkMode} />
      </div>

      {/* Charts Section */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-4">
          <div className="p-2 bg-gradient-to-r from-[#0077B6] to-[#005F8C] rounded-lg">
            <Activity className="w-5 h-5 text-white" />
          </div>
          <h2 className={`text-xl ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Grafik & Tren Data
          </h2>
        </div>
        
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <ChartCard 
            title="Grafik Detak Jantung" 
            type="bpm" 
            isDarkMode={isDarkMode}
            currentValue={bpm}
          />
          <ChartCard 
            title="Grafik SpO₂" 
            type="spo2" 
            isDarkMode={isDarkMode}
            currentValue={spo2}
          />
        </div>
      </div>

      {/* Sync Panel */}
      <SyncPanel isDarkMode={isDarkMode} />
    </div>
  );
}
