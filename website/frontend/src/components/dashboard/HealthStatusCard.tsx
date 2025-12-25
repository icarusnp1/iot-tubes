import { Card } from '../ui/card';
import { Badge } from '../ui/badge';
import { AlertCircle, CheckCircle, AlertTriangle, Heart, Droplets, Thermometer, Wind, LucideIcon } from 'lucide-react';

interface HealthStatusCardProps {
  title: string;
  value: number;
  unit: string;
  isDarkMode: boolean;
  type: 'bpm' | 'spo2' | 'temperature' | 'humidity';
  mainIcon?: LucideIcon;
  mainColor?: string;
}

export function HealthStatusCard({ title, value, unit, isDarkMode, type, mainIcon, mainColor }: HealthStatusCardProps) {
  // Get main icon based on type
  const getMainIcon = () => {
    if (mainIcon) return mainIcon;
    if (type === 'bpm') return Heart;
    if (type === 'spo2') return Droplets;
    if (type === 'temperature') return Thermometer;
    if (type === 'humidity') return Wind;
    return Heart;
  };

  // Get main color based on type
  const getMainColor = () => {
    if (mainColor) return mainColor;
    if (type === 'bpm') return '#E53935';
    if (type === 'spo2') return '#0077B6';
    if (type === 'temperature') return '#FF9800';
    if (type === 'humidity') return '#2196F3';
    return '#2ECC71';
  };

  const MainIcon = getMainIcon();
  const iconColor = getMainColor();

  // Get status based on type and value
  const getStatus = () => {
    if (type === 'bpm') {
      if (value < 60) {
        return {
          label: 'Bradikardi',
          color: '#FF9800',
          icon: AlertTriangle,
          description: 'Detak jantung lebih lambat dari normal',
          range: 'Normal: 60-100 BPM',
          severity: 'warning'
        };
      }
      if (value > 100) {
        return {
          label: 'Takikardi',
          color: '#E53935',
          icon: AlertCircle,
          description: 'Detak jantung lebih cepat dari normal',
          range: 'Normal: 60-100 BPM',
          severity: 'danger'
        };
      }
      return {
        label: 'Normal',
        color: '#2ECC71',
        icon: CheckCircle,
        description: 'Detak jantung dalam kondisi baik',
        range: 'Normal: 60-100 BPM',
        severity: 'normal'
      };
    } else if (type === 'spo2') {
      // SpO2
      if (value < 90) {
        return {
          label: 'Hipoksemia Berat',
          color: '#E53935',
          icon: AlertCircle,
          description: 'Kadar oksigen sangat rendah - segera hubungi dokter',
          range: 'Normal: 95-100%',
          severity: 'danger'
        };
      }
      if (value < 95) {
        return {
          label: 'Hipoksemia Ringan',
          color: '#FF9800',
          icon: AlertTriangle,
          description: 'Kadar oksigen sedikit rendah',
          range: 'Normal: 95-100%',
          severity: 'warning'
        };
      }
      return {
        label: 'Normal',
        color: '#2ECC71',
        icon: CheckCircle,
        description: 'Kadar oksigen optimal',
        range: 'Normal: 95-100%',
        severity: 'normal'
      };
    } else if (type === 'temperature') {
      // Temperature
      if (value < 22) {
        return {
          label: 'Dingin',
          color: '#2196F3',
          icon: AlertTriangle,
          description: 'Suhu ruangan terlalu dingin',
          range: 'Normal: 22-26°C',
          severity: 'warning'
        };
      }
      if (value > 26) {
        return {
          label: 'Panas',
          color: '#E53935',
          icon: AlertCircle,
          description: 'Suhu ruangan terlalu panas',
          range: 'Normal: 22-26°C',
          severity: 'danger'
        };
      }
      return {
        label: 'Normal',
        color: '#2ECC71',
        icon: CheckCircle,
        description: 'Suhu ruangan nyaman',
        range: 'Normal: 22-26°C',
        severity: 'normal'
      };
    } else {
      // Humidity
      if (value < 40) {
        return {
          label: 'Kering',
          color: '#FF9800',
          icon: AlertTriangle,
          description: 'Kelembapan terlalu rendah',
          range: 'Normal: 40-60%',
          severity: 'warning'
        };
      }
      if (value > 60) {
        return {
          label: 'Lembap',
          color: '#2196F3',
          icon: AlertCircle,
          description: 'Kelembapan terlalu tinggi',
          range: 'Normal: 40-60%',
          severity: 'warning'
        };
      }
      return {
        label: 'Normal',
        color: '#2ECC71',
        icon: CheckCircle,
        description: 'Kelembapan ideal',
        range: 'Normal: 40-60%',
        severity: 'normal'
      };
    }
  };

  const status = getStatus();
  const StatusIcon = status.icon;

  // Calculate position on scale
  const getScalePosition = () => {
    if (type === 'bpm') {
      // Scale from 40 to 120 BPM
      const min = 40;
      const max = 120;
      return Math.min(100, Math.max(0, ((value - min) / (max - min)) * 100));
    } else if (type === 'spo2') {
      // Scale from 85 to 100%
      const min = 85;
      const max = 100;
      return Math.min(100, Math.max(0, ((value - min) / (max - min)) * 100));
    } else if (type === 'temperature') {
      // Scale from 18 to 32°C
      const min = 18;
      const max = 32;
      return Math.min(100, Math.max(0, ((value - min) / (max - min)) * 100));
    } else {
      // Humidity: Scale from 20 to 80%
      const min = 20;
      const max = 80;
      return Math.min(100, Math.max(0, ((value - min) / (max - min)) * 100));
    }
  };

  // Get gradient based on type
  const getGradient = () => {
    if (type === 'bpm') {
      return 'linear-gradient(to right, #FF9800 0%, #2ECC71 30%, #2ECC71 70%, #E53935 100%)';
    } else if (type === 'spo2') {
      return 'linear-gradient(to right, #E53935 0%, #FF9800 40%, #2ECC71 70%, #2ECC71 100%)';
    } else if (type === 'temperature') {
      return 'linear-gradient(to right, #2196F3 0%, #2ECC71 30%, #2ECC71 60%, #E53935 100%)';
    } else {
      return 'linear-gradient(to right, #FF9800 0%, #2ECC71 30%, #2ECC71 70%, #2196F3 100%)';
    }
  };

  // Get scale labels
  const getScaleLabels = () => {
    if (type === 'bpm') {
      return ['40', '60', '100', '120'];
    } else if (type === 'spo2') {
      return ['85%', '90%', '95%', '100%'];
    } else if (type === 'temperature') {
      return ['18°C', '22°C', '26°C', '32°C'];
    } else {
      return ['20%', '40%', '60%', '80%'];
    }
  };

  const position = getScalePosition();
  const gradient = getGradient();
  const scaleLabels = getScaleLabels();

  return (
    <Card className={`p-6 ${
      isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
    }`}>
      {/* Header with Icon */}
      <div className="mb-4">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <h3 className={`text-sm mb-2 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
              {title}
            </h3>
            <div className="flex items-baseline gap-2">
              <span className="text-4xl" style={{ color: status.color }}>
                {value}
              </span>
              <span className="text-xl text-gray-400">{unit}</span>
            </div>
          </div>
          
          {/* Main Icon */}
          <div 
            className="p-3 rounded-xl"
            style={{ backgroundColor: `${iconColor}20` }}
          >
            <MainIcon className="w-6 h-6" style={{ color: iconColor }} />
          </div>
        </div>
        
        <Badge 
          className="text-xs px-2 py-0.5"
          style={{ 
            backgroundColor: `${status.color}20`, 
            color: status.color,
            border: `1px solid ${status.color}40`
          }}
        >
          {status.label}
        </Badge>
      </div>

      {/* Visual Scale */}
      <div className="mb-4">
        <div className="relative h-8 rounded-full overflow-hidden" style={{
          background: gradient
        }}>
          {/* Indicator */}
          <div 
            className="absolute top-1/2 -translate-y-1/2 w-1 h-full bg-white shadow-lg transition-all duration-500"
            style={{ left: `${position}%` }}
          />
        </div>
        
        {/* Scale Labels */}
        <div className="flex justify-between mt-2 text-xs text-gray-500">
          {scaleLabels.map((label, index) => (
            <span key={index}>{label}</span>
          ))}
        </div>
      </div>

      {/* Status Information */}
      <div className={`p-3 rounded-lg ${
        isDarkMode ? 'bg-gray-800/50' : 'bg-gray-50'
      }`}>
        <div className="flex items-start gap-2 mb-2">
          <StatusIcon className="w-4 h-4 mt-0.5 flex-shrink-0" style={{ color: status.color }} />
          <div className="flex-1">
            <p className={`text-xs ${isDarkMode ? 'text-gray-300' : 'text-gray-700'}`}>
              {status.description}
            </p>
          </div>
        </div>
        <p className="text-xs text-gray-500 ml-6">
          {status.range}
        </p>
      </div>
    </Card>
  );
}
