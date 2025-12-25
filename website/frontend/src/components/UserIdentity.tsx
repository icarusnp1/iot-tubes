import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Settings } from 'lucide-react';

export function UserIdentity() {
  return (
    <div className="bg-[#0077B6] text-white px-4 py-6 rounded-b-3xl shadow-lg">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Avatar className="w-16 h-16 border-2 border-white">
            <AvatarImage src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop" alt="User" />
            <AvatarFallback className="bg-[#2ECC71]">JD</AvatarFallback>
          </Avatar>
          <div>
            <h1 className="text-xl">John Doe</h1>
            <p className="text-white/80 text-sm">28 years old • Male</p>
          </div>
        </div>
        <button className="p-2 hover:bg-white/10 rounded-full transition-colors">
          <Settings className="w-6 h-6" />
        </button>
      </div>
    </div>
  );
}
