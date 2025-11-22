import { Card } from '../ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { User, Mail, Phone, Calendar, MapPin, Edit, Save } from 'lucide-react';
import { useState } from 'react';
import { toast } from "sonner";

interface ProfilePageProps {
  isDarkMode: boolean;
}

export function ProfilePage({ isDarkMode }: ProfilePageProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [profile, setProfile] = useState({
    name: 'Ragis Rahmatulloh',
    email: 'Ragis.Rahmatulloh@example.com',
    phone: '+62 812-3456-7890',
    birthDate: '2005-05-15',
    address: 'Bandung, Indonesia',
    bloodType: 'O+',
    height: '175',
    weight: '70',
  });

  const handleSave = () => {
    setIsEditing(false);
    toast.success('Profil berhasil diperbarui!');
  };

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
      <div className="max-w-4xl mx-auto">
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
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <div className="flex flex-col md:flex-row items-center gap-6">
            <Avatar className="w-24 h-24 border-4 border-[#2ECC71]">
              <AvatarImage src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop" />
              <AvatarFallback className="bg-[#2ECC71] text-white text-2xl">JD</AvatarFallback>
            </Avatar>
            
            <div className="flex-1 text-center md:text-left">
              <h2 className={`text-xl mb-1 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
                {profile.name}
              </h2>
              <p className="text-sm text-gray-500 mb-2">{profile.email}</p>
              <div className="flex flex-wrap gap-2 justify-center md:justify-start">
                <span className="px-3 py-1 bg-[#2ECC71]/10 text-[#2ECC71] rounded-full text-xs">
                  Administrator
                </span>
                <span className="px-3 py-1 bg-[#0077B6]/10 text-[#0077B6] rounded-full text-xs">
                  Aktif
                </span>
              </div>
            </div>
          </div>
        </Card>

        {/* Personal Information */}
        <Card className={`p-6 mb-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Informasi Pribadi
          </h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label htmlFor="name" className="text-sm text-gray-500 mb-2 block">
                Nama Lengkap
              </Label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <Input
                  id="name"
                  value={profile.name}
                  onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                  disabled={!isEditing}
                  className="pl-10"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="email" className="text-sm text-gray-500 mb-2 block">
                Email
              </Label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <Input
                  id="email"
                  type="email"
                  value={profile.email}
                  onChange={(e) => setProfile({ ...profile, email: e.target.value })}
                  disabled={!isEditing}
                  className="pl-10"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="phone" className="text-sm text-gray-500 mb-2 block">
                Nomor Telepon
              </Label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <Input
                  id="phone"
                  value={profile.phone}
                  onChange={(e) => setProfile({ ...profile, phone: e.target.value })}
                  disabled={!isEditing}
                  className="pl-10"
                />
              </div>
            </div>

            <div>
              <Label htmlFor="birthDate" className="text-sm text-gray-500 mb-2 block">
                Tanggal Lahir
              </Label>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <Input
                  id="birthDate"
                  type="date"
                  value={profile.birthDate}
                  onChange={(e) => setProfile({ ...profile, birthDate: e.target.value })}
                  disabled={!isEditing}
                  className="pl-10"
                />
              </div>
            </div>

            <div className="md:col-span-2">
              <Label htmlFor="address" className="text-sm text-gray-500 mb-2 block">
                Alamat
              </Label>
              <div className="relative">
                <MapPin className="absolute left-3 top-3 w-4 h-4 text-gray-400" />
                <Input
                  id="address"
                  value={profile.address}
                  onChange={(e) => setProfile({ ...profile, address: e.target.value })}
                  disabled={!isEditing}
                  className="pl-10"
                />
              </div>
            </div>
          </div>
        </Card>

        {/* Health Information */}
        <Card className={`p-6 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <h3 className={`mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
            Informasi Kesehatan
          </h3>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <Label htmlFor="bloodType" className="text-sm text-gray-500 mb-2 block">
                Golongan Darah
              </Label>
              <Input
                id="bloodType"
                value={profile.bloodType}
                onChange={(e) => setProfile({ ...profile, bloodType: e.target.value })}
                disabled={!isEditing}
              />
            </div>

            <div>
              <Label htmlFor="height" className="text-sm text-gray-500 mb-2 block">
                Tinggi Badan (cm)
              </Label>
              <Input
                id="height"
                type="number"
                value={profile.height}
                onChange={(e) => setProfile({ ...profile, height: e.target.value })}
                disabled={!isEditing}
              />
            </div>

            <div>
              <Label htmlFor="weight" className="text-sm text-gray-500 mb-2 block">
                Berat Badan (kg)
              </Label>
              <Input
                id="weight"
                type="number"
                value={profile.weight}
                onChange={(e) => setProfile({ ...profile, weight: e.target.value })}
                disabled={!isEditing}
              />
            </div>
          </div>

          {/* BMI Calculation */}
          <div className="mt-6 p-4 bg-[#0077B6]/10 rounded-xl">
            <p className="text-sm text-gray-500 mb-1">Body Mass Index (BMI)</p>
            <p className="text-2xl text-[#0077B6]">
              {(parseFloat(profile.weight) / Math.pow(parseFloat(profile.height) / 100, 2)).toFixed(1)}
            </p>
            <p className="text-xs text-gray-500 mt-1">Normal (18.5 - 24.9)</p>
          </div>
        </Card>
      </div>
    </div>
  );
}
