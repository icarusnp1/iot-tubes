import { Bluetooth, Battery, Signal, WifiOff } from 'lucide-react';
import { Badge } from './ui/badge';
import { useState, useEffect } from 'react';

export function IoTConnectionStatus() {
  const [isConnected, setIsConnected] = useState(true);
  const [batteryLevel, setBatteryLevel] = useState(85);
  const [signalStrength, setSignalStrength] = useState(4);

  // Simulate connection status changes
  useEffect(() => {
    const interval = setInterval(() => {
      // Randomly simulate disconnection (10% chance every 10 seconds)
      if (Math.random() < 0.1) {
        setIsConnected(prev => !prev);
      }
      
      // Simulate battery drain
      setBatteryLevel(prev => Math.max(20, prev - Math.random() * 0.5));
      
      // Simulate signal strength variation
      setSignalStrength(Math.floor(Math.random() * 5));
    }, 10000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="mx-4 -mt-6 mb-4 relative z-10">
      <div className={`bg-white rounded-2xl shadow-lg p-4 border-2 transition-all ${
        isConnected ? 'border-[#2ECC71]' : 'border-red-400'
      }`}>
        <div className="flex items-center justify-between">
          {/* Device Info */}
          <div className="flex items-center gap-3">
            <div className={`p-2 rounded-xl transition-all ${
              isConnected ? 'bg-[#2ECC71]' : 'bg-red-500'
            }`}>
              {isConnected ? (
                <Bluetooth className="w-5 h-5 text-white" />
              ) : (
                <WifiOff className="w-5 h-5 text-white" />
              )}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <p className="text-sm">Heart Monitor Pro</p>
                <Badge 
                  variant="outline" 
                  className={`text-xs ${
                    isConnected 
                      ? 'border-[#2ECC71] text-[#2ECC71]' 
                      : 'border-red-500 text-red-500'
                  }`}
                >
                  {isConnected ? 'Connected' : 'Disconnected'}
                </Badge>
              </div>
              <p className="text-xs text-gray-400">IoT Device • Model HM-2024</p>
            </div>
          </div>

          {/* Device Stats */}
          {isConnected && (
            <div className="flex items-center gap-3">
              {/* Battery */}
              <div className="flex items-center gap-1">
                <Battery 
                  className={`w-4 h-4 ${
                    batteryLevel > 50 ? 'text-[#2ECC71]' : 
                    batteryLevel > 20 ? 'text-yellow-500' : 'text-red-500'
                  }`} 
                />
                <span className="text-xs text-gray-600">{Math.round(batteryLevel)}%</span>
              </div>

              {/* Signal Strength */}
              <div className="flex items-center gap-1">
                <Signal className="w-4 h-4 text-[#0077B6]" />
                <div className="flex gap-0.5">
                  {[1, 2, 3, 4].map((bar) => (
                    <div
                      key={bar}
                      className={`w-1 rounded-full transition-all ${
                        bar <= signalStrength ? 'bg-[#0077B6]' : 'bg-gray-300'
                      }`}
                      style={{ height: `${bar * 3 + 4}px` }}
                    />
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Connection Pulse Indicator */}
        {isConnected && (
          <div className="flex items-center gap-2 mt-3 pt-3 border-t border-gray-100">
            <div className="relative flex items-center">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#2ECC71] opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-[#2ECC71]"></span>
              </span>
            </div>
            <p className="text-xs text-gray-500">Receiving live data</p>
            <div className="ml-auto text-xs text-gray-400">
              Last sync: Just now
            </div>
          </div>
        )}

        {/* Disconnected Message */}
        {!isConnected && (
          <div className="mt-3 pt-3 border-t border-gray-100">
            <p className="text-xs text-red-600">
              ⚠️ Device disconnected. Please check your Bluetooth connection.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
