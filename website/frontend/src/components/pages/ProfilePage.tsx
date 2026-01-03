import { Card } from '../ui/card';
import { Avatar, AvatarFallback } from '../ui/avatar';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { User, Mail, Calendar, Edit, Save } from 'lucide-react';
import { useState, useEffect } from 'react';
import { toast } from "sonner";

interface ProfilePageProps {
  isDarkMode: boolean;
  userId: number; // ID user yang login
}

interface UserProfile {
  name: string;
  email: string;
  date_of_birth: string;
  blood_type: string | null;
  height_cm: string | null;
  weight_kg: string | null;
}

export function ProfilePage({ isDarkMode, userId }: ProfilePageProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [profile, setProfile] = useState<UserProfile>({
    name: '',
    email: '',
    date_of_birth: '',
    blood_type: null,
    height_cm: null,
    weight_kg: null
  });

  // Fetch profile dari backend
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await fetch(`http://localhost/sem5.test/iot-tubes/website/backend/get_profile.php?user_id=${userId}`);
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || "Gagal mengambil data profile");

        // Set data ke state, biarkan null kalau belum ada
        setProfile({
          name: data.name ?? '',
          email: data.email ?? '',
          date_of_birth: data.date_of_birth ?? '',
          blood_type: data.blood_type ?? null,
          height_cm: data.height_cm ?? null,
          weight_kg: data.weight_kg ?? null
        });
      } catch (err: any) {
        toast.error(err.message);
      }
    };
    fetchProfile();
  }, [userId]);

  const handleSave = async () => {
    try {
      const res = await fetch(`http://localhost/sem5.test/iot-tubes/website/backend/update_profile.php`, {
        method: 'POST',
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user_id: userId, ...profile })
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.message || "Update gagal");
      toast.success('Profil berhasil diperbarui!');
      setIsEditing(false);
    } catch (err: any) {
      toast.error(err.message);
    }
  };

  // Perhitungan BMI hanya jika height dan weight ada
  const height = parseFloat(profile.height_cm ?? '0');
  const weight = parseFloat(profile.weight_kg ?? '0');
  const bmi = height > 0 && weight > 0 ? (weight / Math.pow(height / 100, 2)).toFixed(1) : '';

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl">Profil Pengguna</h1>
          <Button
            onClick={() => isEditing ? handleSave() : setIsEditing(true)}
            className="bg-gradient-to-r from-[#2ECC71] to-[#0077B6] hover:from-[#27AE60] hover:to-[#005F8C] text-white"
          >
            {isEditing ? (
              <>
                <Save className="w-4 h-4 mr-2" />
                Simpan
              </>
            ) : (
              <>
                <Edit className="w-4 h-4 mr-2" />
                Edit Profil
              </>
            )}
          </Button>
        </div>

        {/* Profile Header */}
        <Card className={`p-6 mb-6 ${isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'}`}>
          <div className="flex flex-col md:flex-row items-center gap-6">
            <Avatar className="w-24 h-24 border-4 border-[#2ECC71]">
              <AvatarFallback className="bg-[#2ECC71] text-white text-2xl">
                {profile.name ? profile.name[0] : 'U'}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 text-center md:text-left">
              <h2 className={`text-xl mb-1 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
                {profile.name || 'Nama User'}
              </h2>
              <p className="text-sm text-gray-500 mb-2">{profile.email || 'email@example.com'}</p>
            </div>
          </div>
        </Card>

        {/* Personal Information */}
        <Card className={`p-6 mb-6 ${isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'}`}>
          <h3 className={`mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Informasi Pribadi</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="name" className="text-sm text-gray-500 mb-2 block">Nama Lengkap</Label>
              <Input
                id="name"
                value={profile.name}
                onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                disabled={!isEditing}
              />
            </div>
            <div>
              <Label htmlFor="email" className="text-sm text-gray-500 mb-2 block">Email</Label>
              <Input
                id="email"
                type="email"
                value={profile.email}
                onChange={(e) => setProfile({ ...profile, email: e.target.value })}
                disabled={!isEditing}
              />
            </div>
            <div>
              <Label htmlFor="date_of_birth" className="text-sm text-gray-500 mb-2 block">Tanggal Lahir</Label>
              <Input
                id="date_of_birth"
                type="date"
                value={profile.date_of_birth}
                onChange={(e) => setProfile({ ...profile, date_of_birth: e.target.value })}
                disabled={!isEditing}
              />
            </div>
          </div>
        </Card>

        {/* Health Information */}
        <Card className={`p-6 ${isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'}`}>
          <h3 className={`mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>Informasi Kesehatan</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <Label htmlFor="blood_type" className="text-sm text-gray-500 mb-2 block">Golongan Darah</Label>
              <Input
                id="blood_type"
                value={profile.blood_type ?? ''}
                onChange={(e) => setProfile({ ...profile, blood_type: e.target.value })}
                disabled={!isEditing}
              />
            </div>
            <div>
              <Label htmlFor="height_cm" className="text-sm text-gray-500 mb-2 block">Tinggi Badan (cm)</Label>
              <Input
                id="height_cm"
                type="number"
                value={profile.height_cm ?? ''}
                onChange={(e) => setProfile({ ...profile, height_cm: e.target.value })}
                disabled={!isEditing}
              />
            </div>
            <div>
              <Label htmlFor="weight_kg" className="text-sm text-gray-500 mb-2 block">Berat Badan (kg)</Label>
              <Input
                id="weight_kg"
                type="number"
                value={profile.weight_kg ?? ''}
                onChange={(e) => setProfile({ ...profile, weight_kg: e.target.value })}
                disabled={!isEditing}
              />
            </div>
          </div>

          {/* BMI */}
          {bmi && (
            <div className="mt-6 p-4 bg-[#0077B6]/10 rounded-xl">
              <p className="text-sm text-gray-500 mb-1">Body Mass Index (BMI)</p>
              <p className="text-2xl text-[#0077B6]">{bmi}</p>
              <p className="text-xs text-gray-500 mt-1">Normal (18.5 - 24.9)</p>
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}