import { useState } from 'react';
import { Card } from '../ui/card';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Button } from '../ui/button';
import { Activity, Lock, User, Moon, Sun, Fingerprint } from 'lucide-react';
import { toast } from "sonner";

interface LoginPageProps {
  onLogin: (id: number) => void; // ✅ sekarang menerima userId
  isDarkMode: boolean;
  setIsDarkMode: (dark: boolean) => void;
  onGoRegister: () => void;
}
export function LoginPage({ onLogin, isDarkMode, setIsDarkMode, onGoRegister }: LoginPageProps) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
  e.preventDefault();
  setIsLoading(true);

  try {
    const res = await fetch("http://sem5.test/iot-tubes/website/backend/login.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password })
    });

    const data = await res.json();

    if (!res.ok) throw new Error(data.message || "Login gagal");

    toast.success(data.message);
    onLogin(data.user_id); // kirim userId ke App
  } catch (err: any) {
    toast.error(err.message);
  } finally {
    setIsLoading(false);
  }
};

  return (
    <div className={`min-h-screen flex items-center justify-center p-4 ${
      isDarkMode ? 'bg-[#222831]' : 'bg-gradient-to-br from-[#2ECC71]/20 via-[#E6F4F1] to-[#0077B6]/20'
    }`}>
      {/* Theme Toggle */}
      <button
        onClick={() => setIsDarkMode(!isDarkMode)}
        className={`fixed top-4 right-4 p-3 rounded-full transition-colors ${
          isDarkMode ? 'bg-gray-700 text-yellow-400' : 'bg-white text-gray-700 shadow-lg'
        }`}
      >
        {isDarkMode ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
      </button>

      <Card className={`w-full max-w-md p-8 ${
        isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white'
      }`}>
        {/* Logo & Title */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-[#2ECC71] to-[#0077B6] rounded-2xl mb-4">
            <Activity className="w-8 h-8 text-white" />
          </div>
          <h1 className={`text-2xl mb-2 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Sistem Monitoring
          </h1>
          <p className="text-sm text-gray-500">Detak Jantung Berbasis IoT</p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleLogin} className="space-y-4 mb-6">
          <div>
            <Label htmlFor="username" className="text-sm text-gray-600 mb-2 block">
              Username
            </Label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <Input
                id="username"
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Masukkan username"
                className="pl-10"
              />
            </div>
          </div>

          <div>
            <Label htmlFor="password" className="text-sm text-gray-600 mb-2 block">
              Password
            </Label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Masukkan password"
                className="pl-10"
              />
            </div>
          </div>

          <Button
            type="submit"
            disabled={isLoading}
            className="w-full bg-gradient-to-r from-[#2ECC71] to-[#0077B6] hover:from-[#27AE60] hover:to-[#005F8C] text-white"
          >
            {isLoading ? 'Loading...' : 'Login'}
          </Button>
        </form>

        <p className="text-center text-sm mt-4">
Belum punya akun?{' '}
<button
type="button"
onClick={onGoRegister}
className="text-[#0077B6] hover:underline"
>
Register
</button>
</p>

        {/* Divider */}
        {/* <div className="relative mb-6">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-300"></div>
          </div>
          <div className="relative flex justify-center text-sm">
            <span className={`px-2 ${isDarkMode ? 'bg-[#2d3748]' : 'bg-white'} text-gray-500`}>
              atau
            </span>
          </div>
        </div> */}

        {/* IR Login */}
        {/* <Button
          type="button"
          onClick={handleIRLogin}
          disabled={isLoading}
          variant="outline"
          className="w-full border-[#2ECC71] text-[#2ECC71] hover:bg-[#2ECC71]/10"
        >
          <Fingerprint className="w-5 h-5 mr-2" />
          Login dengan Sidik Jari
        </Button> */}

        {/* Footer */}
        <p className="text-center text-xs text-gray-500 mt-6">
          © 2024 IoT Heart Monitoring System
        </p>
      </Card>
    </div>
  );
}
