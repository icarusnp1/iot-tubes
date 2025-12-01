import { useState } from "react";
import { Card } from "../ui/card";
import { Input } from "../ui/input";
import { Label } from "../ui/label";
import { Button } from "../ui/button";
import { Mail, User, Calendar, Lock, Activity } from "lucide-react";
import { toast } from "sonner";

interface RegisterProps {
  onGoLogin: () => void;
  isDarkMode: boolean;
  setIsDarkMode: React.Dispatch<React.SetStateAction<boolean>>;
}

export default function RegisterPage({ onGoLogin, isDarkMode, setIsDarkMode }: RegisterProps) {
  const [email, setEmail] = useState("");
  const [username, setUsername] = useState("");
  const [birth, setBirth] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);

const handleRegister = async (e: React.FormEvent) => {
  e.preventDefault();
  setIsLoading(true);

  console.log({ username, email, password, birth }); // cek state sebelum fetch

  try {
    const res = await fetch("http://sem5.test/iot-tubes/website/backend/register.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, email, password, birth })
    });

    const data = await res.json();

    if (!res.ok) throw new Error(data.message || "Registrasi gagal");

    toast.success(data.message);
    onGoLogin(); // pindah ke login page
  } catch (err: any) {
    toast.error(err.message);
  } finally {
    setIsLoading(false);
  }
};

  return (
    <div className="min-h-screen flex items-center justify-center p-6 bg-gradient-to-br from-[#C3FFE1] to-[#E8F9FF]">
      <Card className="w-full max-w-md p-8 rounded-3xl shadow-xl bg-white">

        {/* Logo */}
        <div className="text-center mb-6">
          <div className="w-16 h-16 mx-auto bg-gradient-to-br from-[#2ECC71] to-[#0077B6] rounded-2xl flex items-center justify-center">
            <Activity className="text-white w-8 h-8" />
          </div>

          <h1 className="text-2xl font-semibold mt-4">Sistem Monitoring</h1>
          <p className="text-gray-500 text-sm">Detak Jantung Berbasis IoT</p>
        </div>

        {/* FORM */}
        <form className="space-y-4" onSubmit={handleRegister}>
          
          {/* EMAIL */}
          <div>
            <Label className="text-gray-700">Email</Label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              <Input
                type="email"
                placeholder="Masukkan email"
                className="pl-10 bg-gray-100"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
          </div>

          {/* USERNAME */}
          <div>
            <Label className="text-gray-700">Username</Label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              <Input
                type="text"
                placeholder="Masukkan username"
                className="pl-10 bg-gray-100"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
              />
            </div>
          </div>

          {/* TANGGAL LAHIR */}
          <div>
            <Label className="text-gray-700">Tanggal Lahir</Label>
            <div className="relative">
              <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              <Input
                type="date"
                className="pl-10 bg-gray-100 text-gray-600"
                value={birth}
                onChange={(e) => setBirth(e.target.value)}
              />
            </div>
          </div>

          {/* PASSWORD */}
          <div>
            <Label className="text-gray-700">Password</Label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
              <Input
                type="password"
                placeholder="Masukkan password"
                className="pl-10 bg-gray-100"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          </div>

          {/* BUTTON REGISTER */}
          <Button
            disabled={isLoading}
            className="w-full bg-gradient-to-r from-[#2ECC71] to-[#0077B6] text-white hover:opacity-90"
            type="submit"
          >
            {isLoading ? "Memproses..." : "Register"}
          </Button>
        </form>

        {/* LINK LOGIN */}
        <p className="text-center mt-6 text-gray-500 text-sm">
          Sudah punya akun?{" "}
          <span
            onClick={onGoLogin}
            className="text-[#0077B6] font-semibold cursor-pointer"
          >
            Login
          </span>
        </p>

        <p className="text-center mt-6 text-gray-400 text-xs">
          © 2024 IoT Heart Monitoring System
        </p>
      </Card>
    </div>
  );
}
