import { Card } from '../ui/card';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { useState, useEffect } from 'react';

interface ChartCardProps {
  title: string;
  type: 'bpm' | 'spo2' | 'temperature';
  isDarkMode: boolean;
  currentValue: number;
}

export function ChartCard({ title, type, isDarkMode, currentValue }: ChartCardProps) {
  const [timeRange, setTimeRange] = useState('hourly');
  const [data, setData] = useState<any[]>([]);

  useEffect(() => {
    // Generate mock data based on time range
    const generateData = () => {
      let dataPoints: number;
      let baseValue: number;
      let variance: number;
      let unit: string;

      // Set base values based on type
      if (type === 'bpm') {
        baseValue = 75;
        variance = 10;
        unit = 'BPM';
      } else if (type === 'spo2') {
        baseValue = 97;
        variance = 2;
        unit = '%';
      } else {
        baseValue = 36.5;
        variance = 0.5;
        unit = '°C';
      }

      // Set data points based on time range
      if (timeRange === 'hourly') {
        dataPoints = 12; // 12 data points for hourly view (5 min intervals)
      } else if (timeRange === 'daily') {
        dataPoints = 24; // 24 hours
      } else if (timeRange === 'weekly') {
        dataPoints = 7; // 7 days
      } else {
        dataPoints = 30; // 30 days
      }
      
      return Array.from({ length: dataPoints }, (_, i) => {
        let label = '';
        
        if (timeRange === 'hourly') {
          // Show time in minutes (every 5 minutes for last hour)
          const minutes = i * 5;
          label = `${minutes}m`;
        } else if (timeRange === 'daily') {
          label = `${i}:00`;
        } else if (timeRange === 'weekly') {
          const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
          label = days[i % 7];
        } else {
          label = `${i + 1}`;
        }
        
        return {
          time: label,
          value: baseValue + (Math.random() * variance * 2 - variance),
        };
      });
    };

    setData(generateData());
  }, [timeRange, type]);

  // Add current value to the end of data
  useEffect(() => {
    if (data.length > 0) {
      setData(prev => {
        const newData = [...prev];
        newData[newData.length - 1] = {
          ...newData[newData.length - 1],
          value: currentValue
        };
        return newData;
      });
    }
  }, [currentValue]);

  // Set chart color based on type
  const getChartColor = () => {
    if (type === 'bpm') return '#E53935';
    if (type === 'spo2') return '#0077B6';
    return '#FF9800';
  };

  // Get unit based on type
  const getUnit = () => {
    if (type === 'bpm') return 'BPM';
    if (type === 'spo2') return '%';
    return '°C';
  };

  const chartColor = getChartColor();
  const unit = getUnit();

  return (
    <Card className={`p-6 ${
      isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
    }`}>
      <div className="flex items-center justify-between mb-6">
        <h3 className={`text-lg ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
          {title}
        </h3>
        <Select value={timeRange} onValueChange={setTimeRange}>
          <SelectTrigger className="w-32">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="hourly">Per Jam</SelectItem>
            <SelectItem value="daily">Harian</SelectItem>
            <SelectItem value="weekly">Mingguan</SelectItem>
            <SelectItem value="monthly">Bulanan</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <ResponsiveContainer width="100%" height={250}>
        <LineChart data={data}>
          <CartesianGrid 
            strokeDasharray="3 3" 
            stroke={isDarkMode ? '#374151' : '#e5e7eb'} 
          />
          <XAxis 
            dataKey="time" 
            stroke={isDarkMode ? '#9ca3af' : '#6b7280'}
            style={{ fontSize: '12px' }}
          />
          <YAxis
          stroke={isDarkMode ? '#9ca3af' : '#6b7280'}
          style={{ fontSize: '12px' }}
          domain={type === 'spo2' ? [90, 100] : ["auto", "auto"]}
/>
          <Tooltip
            contentStyle={{
              backgroundColor: isDarkMode ? '#2d3748' : '#ffffff',
              border: `1px solid ${isDarkMode ? '#374151' : '#e5e7eb'}`,
              borderRadius: '8px',
              color: isDarkMode ? '#ffffff' : '#000000'
            }}
            formatter={(value: number) => [
              `${value.toFixed(1)} ${unit}`,
              'Nilai'
            ]}
          />
          <Line 
            type="monotone" 
            dataKey="value" 
            stroke={chartColor}
            strokeWidth={3}
            dot={{ fill: chartColor, r: 4 }}
            activeDot={{ r: 6 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </Card>
  );
}
