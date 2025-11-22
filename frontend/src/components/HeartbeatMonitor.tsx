import { Card } from './ui/card';
import { Activity, Heart } from 'lucide-react';
import { Progress } from './ui/progress';
import { useState, useEffect } from 'react';

export function HeartbeatMonitor() {
  const [bpm, setBpm] = useState(75);
  const [oxygen, setOxygen] = useState(98);
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    const interval = setInterval(() => {
      // Simulate live heartbeat variation
      setBpm(prev => {
        const variation = Math.random() * 6 - 3; // -3 to +3
        return Math.max(60, Math.min(100, prev + variation));
      });
      setOxygen(prev => {
        const variation = Math.random() * 2 - 1; // -1 to +1
        return Math.max(95, Math.min(100, prev + variation));
      });
      setIsAnimating(true);
      setTimeout(() => setIsAnimating(false), 300);
    }, 2000);

    return () => clearInterval(interval);
  }, []);

  return (
    <Card className="p-6 border-[#0077B6]/20">
      <div className="flex items-center gap-3 mb-6">
        <div className="p-3 bg-[#0077B6] rounded-2xl">
          <Activity className="w-6 h-6 text-white" />
        </div>
        <div>
          <h2 className="text-lg">Heartbeat Monitoring</h2>
          <p className="text-sm text-gray-500">Real-time data</p>
        </div>
      </div>

      {/* BPM Display */}
      <div className="mb-6">
        <div className="flex items-end justify-between mb-3">
          <div>
            <p className="text-sm text-gray-500">Heart Rate</p>
            <div className="flex items-baseline gap-2">
              <span className={`text-4xl text-[#0077B6] transition-all ${isAnimating ? 'scale-110' : 'scale-100'}`}>
                {Math.round(bpm)}
              </span>
              <span className="text-lg text-gray-400">BPM</span>
            </div>
          </div>
          <Heart className={`w-8 h-8 text-red-500 transition-all ${isAnimating ? 'scale-125' : 'scale-100'}`} fill="currentColor" />
        </div>
        <Progress value={(bpm / 100) * 100} className="h-2 bg-gray-200" />
        <div className="flex justify-between text-xs text-gray-400 mt-1">
          <span>60</span>
          <span>Normal Range: 60-100 BPM</span>
          <span>100</span>
        </div>
      </div>

      {/* Oxygen Saturation */}
      <div className="pt-6 border-t border-gray-100">
        <div className="flex items-end justify-between mb-3">
          <div>
            <p className="text-sm text-gray-500">Oxygen Saturation</p>
            <div className="flex items-baseline gap-2">
              <span className="text-4xl text-[#2ECC71]">
                {Math.round(oxygen)}
              </span>
              <span className="text-lg text-gray-400">%</span>
            </div>
          </div>
          <div className="text-right">
            <div className={`inline-block px-3 py-1 rounded-full text-xs ${
              oxygen >= 95 ? 'bg-[#2ECC71]/10 text-[#2ECC71]' : 'bg-red-100 text-red-600'
            }`}>
              {oxygen >= 95 ? 'Normal' : 'Low'}
            </div>
          </div>
        </div>
        <Progress value={oxygen} className="h-2 bg-gray-200" />
        <div className="flex justify-between text-xs text-gray-400 mt-1">
          <span>90</span>
          <span>Normal Range: 95-100%</span>
          <span>100</span>
        </div>
      </div>
    </Card>
  );
}
