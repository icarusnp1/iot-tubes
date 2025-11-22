import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Moon, Sun, Menu, Wifi, WifiOff, Clock } from 'lucide-react';
import { useState, useEffect } from 'react';
import { Badge } from './ui/badge';

interface HeaderProps {
  isDarkMode: boolean;
  setIsDarkMode: (dark: boolean) => void;
  onMenuClick: () => void;
}

export function Header({ isDarkMode, setIsDarkMode, onMenuClick }: HeaderProps) {
  const [isConnected, setIsConnected] = useState(true);
  const [lastSync, setLastSync] = useState('Baru saja');

  useEffect(() => {
    // Simulate connection status
    const interval = setInterval(() => {
      if (Math.random() < 0.1) {
        setIsConnected(prev => !prev);
      }
    }, 15000);

    // Update last sync time
    const syncInterval = setInterval(() => {
      const now = new Date();
      setLastSync(now.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }));
    }, 60000);

    return () => {
      clearInterval(interval);
      clearInterval(syncInterval);
    };
  }, []);

  return (
    <header className={`sticky top-0 z-30 border-b transition-colors ${
      isDarkMode 
        ? 'bg-[#2d3748] border-gray-700' 
        : 'bg-white border-gray-200'
    }`}>
      <div className="flex items-center justify-between px-4 lg:px-6 py-4">
        {/* Left: Mobile Menu + Logo */}
        <div className="flex items-center gap-4">
          <button
            onClick={onMenuClick}
            className="lg:hidden p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <Menu className={`w-5 h-5 ${isDarkMode ? 'text-white' : 'text-gray-900'}`} />
          </button>
          
          <div className="hidden lg:block">
            <h1 className={`${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
              Sistem Monitoring Detak Jantung IoT
            </h1>
          </div>
        </div>

        {/* Center: IoT Connection Status */}
        <div className="flex items-center gap-3">
          <div className={`flex items-center gap-2 px-4 py-2 rounded-full ${
            isConnected 
              ? 'bg-[#2ECC71]/10' 
              : 'bg-[#E53935]/10'
          }`}>
            {isConnected ? (
              <>
                <div className="relative flex items-center">
                  <span className="relative flex h-2 w-2">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#2ECC71] opacity-75"></span>
                    <span className="relative inline-flex rounded-full h-2 w-2 bg-[#2ECC71]"></span>
                  </span>
                </div>
                <Wifi className="w-4 h-4 text-[#2ECC71]" />
                <span className={`text-sm ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
                  Connected
                </span>
              </>
            ) : (
              <>
                <WifiOff className="w-4 h-4 text-[#E53935]" />
                <span className={`text-sm ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
                  Disconnected
                </span>
              </>
            )}
          </div>
        </div>

        {/* Right: User Profile + Theme Toggle */}
        <div className="flex items-center gap-3">
          {/* Last Sync Time */}
          <div className="hidden md:flex items-center gap-2 text-sm text-gray-500">
            <Clock className="w-4 h-4" />
            <span>Sync: {lastSync}</span>
          </div>

          {/* Theme Toggle */}
          <button
            onClick={() => setIsDarkMode(!isDarkMode)}
            className={`p-2 rounded-lg transition-colors ${
              isDarkMode ? 'bg-gray-700 text-yellow-400' : 'bg-gray-100 text-gray-700'
            }`}
          >
            {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
          </button>

          {/* User Profile */}
          <div className="flex items-center gap-3">
            <div className="hidden md:block text-right">
              <p className={`text-sm ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
                John Doe
              </p>
              <p className="text-xs text-gray-500">Administrator</p>
            </div>
            <Avatar className="w-10 h-10 border-2 border-[#2ECC71]">
              <AvatarImage src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop" />
              <AvatarFallback className="bg-[#2ECC71] text-white">JD</AvatarFallback>
            </Avatar>
          </div>
        </div>
      </div>
    </header>
  );
}
