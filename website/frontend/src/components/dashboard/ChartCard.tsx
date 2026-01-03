import { Card } from '../ui/card';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { useState, useEffect } from 'react';

interface ChartCardProps {
  title: string;
  type: 'bpm' | 'spo2';
  isDarkMode: boolean;
  currentValue: number;
  userId: number;
}

export function ChartCard({ title, type, isDarkMode, currentValue, userId }: ChartCardProps) {
  const [timeRange, setTimeRange] = useState("hourly");
  const [data, setData] = useState<any[]>([]);
  // optional: buat dinamis kalau perlu

  // Fetch REAL data dari backend
  const fetchChart = async () => {
    try {
      const res = await fetch(
        `http://localhost/sem5.test/iot-tubes/website/backend/get_chart_data.php?user_id=${userId}&type=${type}&range=${timeRange}`
      );

      const result = await res.json();

      if (result.data) {
        const mapped = result.data.map((row: any) => ({
          time: row.time.substring(8, 10) + "/" + row.time.substring(5, 7),
          value: Number(row.value),
        }));



        setData(mapped);
      }
    } catch (e) {
      console.error("Gagal load chart:", e);
    }
  };

  // Load awal + saat timeRange berubah
  useEffect(() => {
    fetchChart();
  }, [timeRange, type]);

  // Tambahkan current value sebagai titik terbaru (real-time)
  useEffect(() => {
    if (data.length > 0) {
      setData(prev => {
        const copy = [...prev];
        copy[copy.length - 1] = {
          ...copy[copy.length - 1],
          value: currentValue
        };
        return copy;
      });
    }
  }, [currentValue]);

  const chartColor = type === "bpm" ? "#E53935" : "#0077B6";
  const unit = type === "bpm" ? "BPM" : "%";

  return (
    <Card
      className={`p-6 ${
        isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
      }`}
    >
      <div className="flex items-center justify-between mb-6">
        <h3 className={`text-lg ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
          {title}
        </h3>

        <Select value={timeRange} onValueChange={setTimeRange}>
          <SelectTrigger className="w-32">
            <SelectValue placeholder="Range" />
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
            style={{ fontSize: '11px' }}
          />
          <YAxis
            stroke={isDarkMode ? '#9ca3af' : '#6b7280'}
            domain={type === 'spo2' ? [90, 100] : ["auto", "auto"]}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: isDarkMode ? '#2d3748' : '#ffffff',
              border: `1px solid ${isDarkMode ? '#374151' : '#e5e7eb'}`,
              borderRadius: '8px',
              color: isDarkMode ? '#ffffff' : '#000000',
            }}
            formatter={(v: number) => [`${v} ${unit}`, "Nilai"]}
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