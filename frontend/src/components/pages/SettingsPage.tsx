import { Card } from '../ui/card';
import { Label } from '../ui/label';
import { Switch } from '../ui/switch';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { Separator } from '../ui/separator';
import { Moon, Sun, Wifi, Bell, Database, Shield, Bluetooth, Radio } from 'lucide-react';
import { useState } from 'react';
import { toast } from "sonner";

interface SettingsPageProps {
  isDarkMode: boolean;
  setIsDarkMode: (dark: boolean) => void;
}

export function SettingsPage({ isDarkMode, setIsDarkMode }: SettingsPageProps) {
  const [autoSync, setAutoSync] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [alertSound, setAlertSound] = useState(true);
  const [syncInterval, setSyncInterval] = useState('5');
  const [iotDevice, setIotDevice] = useState({
    deviceName: 'Heart Monitor Pro',
    deviceId: 'ESP32-HM-001',
    wifiSSID: 'IoT_Network',
    wifiPassword: '********',
    bluetoothEnabled: true,
  });

  const handleSaveSettings = () => {
    toast.success('Pengaturan berhasil disimpan!');
  };

  const handleTestConnection = () => {
    toast.info('Menguji koneksi IoT...');
    setTimeout(() => {
      toast.success('Koneksi IoT berhasil!');
    }, 2000);
  };

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
      <div className="max-w-4xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl mb-2">Pengaturan</h1>
          <p className="text-sm text-gray-500">Kelola preferensi dan konfigurasi sistem</p>
        </div>

        {/* Appearance Settings */}
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 flex items-center gap-2 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            {isDarkMode ? <Moon className="w-5 h-5" /> : <Sun className="w-5 h-5" />}
            Tampilan
          </h3>
          
          <div className="flex items-center justify-between">
            <div>
              <p className={`${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Mode Gelap</p>
              <p className="text-sm text-gray-500">Gunakan tema gelap untuk aplikasi</p>
            </div>
            <Switch
              checked={isDarkMode}
              onCheckedChange={setIsDarkMode}
            />
          </div>
        </Card>

        {/* IoT Device Settings */}
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 flex items-center gap-2 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            <Wifi className="w-5 h-5" />
            Koneksi IoT Device
          </h3>
          
          <div className="space-y-4">
            <div>
              <Label htmlFor="deviceName" className="text-sm text-gray-500 mb-2 block">
                Nama Device
              </Label>
              <Input
                id="deviceName"
                value={iotDevice.deviceName}
                onChange={(e) => setIotDevice({ ...iotDevice, deviceName: e.target.value })}
              />
            </div>

            <div>
              <Label htmlFor="deviceId" className="text-sm text-gray-500 mb-2 block">
                Device ID
              </Label>
              <Input
                id="deviceId"
                value={iotDevice.deviceId}
                disabled
                className="bg-gray-100 dark:bg-gray-800"
              />
            </div>

            <Separator />

            <div className="flex items-center justify-between">
              <div>
                <p className={`${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Bluetooth</p>
                <p className="text-sm text-gray-500">Aktifkan koneksi Bluetooth</p>
              </div>
              <Switch
                checked={iotDevice.bluetoothEnabled}
                onCheckedChange={(checked) => setIotDevice({ ...iotDevice, bluetoothEnabled: checked })}
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="wifiSSID" className="text-sm text-gray-500 mb-2 block">
                  WiFi SSID
                </Label>
                <Input
                  id="wifiSSID"
                  value={iotDevice.wifiSSID}
                  onChange={(e) => setIotDevice({ ...iotDevice, wifiSSID: e.target.value })}
                />
              </div>

              <div>
                <Label htmlFor="wifiPassword" className="text-sm text-gray-500 mb-2 block">
                  WiFi Password
                </Label>
                <Input
                  id="wifiPassword"
                  type="password"
                  value={iotDevice.wifiPassword}
                  onChange={(e) => setIotDevice({ ...iotDevice, wifiPassword: e.target.value })}
                />
              </div>
            </div>

            <Button
              onClick={handleTestConnection}
              variant="outline"
              className="w-full border-[#2ECC71] text-[#2ECC71] hover:bg-[#2ECC71]/10"
            >
              <Radio className="w-4 h-4 mr-2" />
              Test Koneksi
            </Button>
          </div>
        </Card>

        {/* Sync Settings */}
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 flex items-center gap-2 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            <Database className="w-5 h-5" />
            Sinkronisasi Data
          </h3>
          
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className={`${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Auto Sync</p>
                <p className="text-sm text-gray-500">Sinkronkan data secara otomatis</p>
              </div>
              <Switch
                checked={autoSync}
                onCheckedChange={setAutoSync}
              />
            </div>

            {autoSync && (
              <div>
                <Label htmlFor="syncInterval" className="text-sm text-gray-500 mb-2 block">
                  Interval Sinkronisasi (menit)
                </Label>
                <Select value={syncInterval} onValueChange={setSyncInterval}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="1">1 menit</SelectItem>
                    <SelectItem value="5">5 menit</SelectItem>
                    <SelectItem value="10">10 menit</SelectItem>
                    <SelectItem value="30">30 menit</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}
          </div>
        </Card>

        {/* Notification Settings */}
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 flex items-center gap-2 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            <Bell className="w-5 h-5" />
            Notifikasi & Alert
          </h3>
          
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className={`${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Push Notifications</p>
                <p className="text-sm text-gray-500">Terima notifikasi data abnormal</p>
              </div>
              <Switch
                checked={notifications}
                onCheckedChange={setNotifications}
              />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <p className={`${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Alert Sound</p>
                <p className="text-sm text-gray-500">Mainkan suara saat alert</p>
              </div>
              <Switch
                checked={alertSound}
                onCheckedChange={setAlertSound}
              />
            </div>
          </div>
        </Card>

        {/* Security Settings */}
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 flex items-center gap-2 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            <Shield className="w-5 h-5" />
            Keamanan
          </h3>
          
          <div className="space-y-3">
            <Button variant="outline" className="w-full justify-start">
              Ubah Password
            </Button>
          </div>
        </Card>

        {/* Save Button */}
        <div className="flex justify-end gap-3">
          <Button variant="outline">
            Batal
          </Button>
          <Button
            onClick={handleSaveSettings}
            className="bg-gradient-to-r from-[#2ECC71] to-[#0077B6] hover:from-[#27AE60] hover:to-[#005F8C] text-white"
          >
            Simpan Pengaturan
          </Button>
        </div>
      </div>
    </div>
  );
}
