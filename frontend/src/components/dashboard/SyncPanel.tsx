import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { RefreshCw, CheckCircle, AlertCircle, Database } from 'lucide-react';
import { useState } from 'react';
import { toast } from "sonner";

interface SyncPanelProps {
  isDarkMode: boolean;
}

export function SyncPanel({ isDarkMode }: SyncPanelProps) {
  const [isSyncing, setIsSyncing] = useState(false);
  const [lastSync, setLastSync] = useState(new Date());
  const [syncStatus, setSyncStatus] = useState<'synced' | 'pending'>('synced');

  const handleSync = () => {
    setIsSyncing(true);
    setSyncStatus('pending');
    
    // Simulate sync process
    setTimeout(() => {
      setIsSyncing(false);
      setSyncStatus('synced');
      setLastSync(new Date());
      toast.success('Data berhasil disinkronkan ke database lokal');
    }, 2000);
  };

  return (
    <Card className={`p-6 ${
      isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
    }`}>
      <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4">
        {/* Status Section */}
        <div className="flex items-start gap-4 flex-1">
          <div className={`p-3 rounded-xl ${
            syncStatus === 'synced' ? 'bg-[#2ECC71]/20' : 'bg-yellow-500/20'
          }`}>
            {syncStatus === 'synced' ? (
              <CheckCircle className="w-6 h-6 text-[#2ECC71]" />
            ) : (
              <AlertCircle className="w-6 h-6 text-yellow-500" />
            )}
          </div>
          
          <div className="flex-1">
            <h3 className={`mb-1 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
              Status Sinkronisasi IoT
            </h3>
            <p className="text-sm text-gray-500 mb-2">
              {syncStatus === 'synced' 
                ? 'Semua data telah tersinkronisasi dengan database lokal' 
                : 'Data menunggu untuk disinkronkan'}
            </p>
            <div className="flex items-center gap-2 text-xs text-gray-400">
              <Database className="w-4 h-4" />
              <span>
                Terakhir sync: {lastSync.toLocaleTimeString('id-ID', { 
                  hour: '2-digit', 
                  minute: '2-digit',
                  second: '2-digit'
                })}
              </span>
            </div>
          </div>
        </div>

        {/* Sync Button */}
        <Button
          onClick={handleSync}
          disabled={isSyncing}
          className="bg-gradient-to-r from-[#2ECC71] to-[#0077B6] hover:from-[#27AE60] hover:to-[#005F8C] text-white"
        >
          <RefreshCw className={`w-4 h-4 mr-2 ${isSyncing ? 'animate-spin' : ''}`} />
          {isSyncing ? 'Menyinkronkan...' : 'Sinkronkan Sekarang'}
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
        <div className="text-center">
          <p className="text-2xl text-[#0077B6]">1,247</p>
          <p className="text-xs text-gray-500 mt-1">Total Records</p>
        </div>
        <div className="text-center">
          <p className="text-2xl text-[#2ECC71]">100%</p>
          <p className="text-xs text-gray-500 mt-1">Sync Rate</p>
        </div>
        <div className="text-center">
          <p className="text-2xl text-[#FF9800]">24h</p>
          <p className="text-xs text-gray-500 mt-1">Uptime</p>
        </div>
      </div>
    </Card>
  );
}
