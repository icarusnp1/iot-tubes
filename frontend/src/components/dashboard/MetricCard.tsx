import { Card } from '../ui/card';
import { LucideIcon } from 'lucide-react';
import { Progress } from '../ui/progress';
import { Badge } from '../ui/badge';
import { useState, useEffect } from 'react';

interface MetricCardProps {
  title: string;
  value: number | string;
  unit: string;
  icon: LucideIcon;
  color: string;
  isDarkMode: boolean;
  isLarge?: boolean;
  animated?: boolean;
  progress?: number;
  status?: string;
  statusColor?: string;
  statusRange?: string;
}

export function MetricCard({ 
  title, 
  value, 
  unit, 
  icon: Icon, 
  color, 
  isDarkMode,
  isLarge = false,
  animated = false,
  progress,
  status,
  statusColor,
  statusRange
}: MetricCardProps) {
  const [isPulsing, setIsPulsing] = useState(false);

  useEffect(() => {
    if (animated) {
      const interval = setInterval(() => {
        setIsPulsing(true);
        setTimeout(() => setIsPulsing(false), 300);
      }, 1000);
      return () => clearInterval(interval);
    }
  }, [animated]);

  return (
    <Card className={`p-6 transition-all ${
      isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
    } ${isLarge ? 'lg:col-span-1' : ''}`}>
      <div className="flex items-start justify-between mb-4">
        <div className="flex-1">
          <p className="text-sm text-gray-500 mb-2">{title}</p>
          <div className="flex items-baseline gap-2">
            <span 
              className={`transition-all duration-300 ${
                isLarge ? 'text-5xl' : 'text-3xl'
              } ${isPulsing ? 'scale-110' : 'scale-100'}`}
              style={{ color }}
            >
              {value}
            </span>
            <span className="text-lg text-gray-400">{unit}</span>
          </div>
        </div>
        
        <div 
          className={`p-3 rounded-xl transition-all ${isPulsing ? 'scale-110' : 'scale-100'}`}
          style={{ backgroundColor: `${color}20` }}
        >
          <Icon className="w-6 h-6" style={{ color }} />
        </div>
      </div>

      {/* Status Information */}
      {status && statusColor && statusRange && (
        <div className={`mt-4 p-3 rounded-lg border ${
          isDarkMode ? 'bg-gray-800/50 border-gray-700' : 'bg-gray-50 border-gray-200'
        }`}>
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-gray-500">Status:</span>
            <Badge 
              className="text-xs px-2 py-0.5"
              style={{ 
                backgroundColor: `${statusColor}20`, 
                color: statusColor,
                border: `1px solid ${statusColor}40`
              }}
            >
              {status}
            </Badge>
          </div>
          <p className="text-xs text-gray-500">
            {statusRange}
          </p>
        </div>
      )}

      {progress !== undefined && (
        <div className="mt-4">
          <Progress 
            value={progress} 
            className="h-2"
            style={{ 
              backgroundColor: isDarkMode ? '#1a202c' : '#f3f4f6'
            }}
          />
        </div>
      )}

      {animated && (
        <div className="mt-4 flex items-center gap-2">
          <div className="relative flex h-2 w-2">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75" style={{ backgroundColor: color }}></span>
            <span className="relative inline-flex rounded-full h-2 w-2" style={{ backgroundColor: color }}></span>
          </div>
          <span className="text-xs text-gray-500">Live</span>
        </div>
      )}
    </Card>
  );
}
