import { Card } from './ui/card';
import { Heart, TrendingUp } from 'lucide-react';
import { Badge } from './ui/badge';

export function HeartHealthCard() {
  return (
    <Card className="p-6 bg-gradient-to-br from-[#2ECC71]/10 to-white border-[#2ECC71]/20">
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-[#2ECC71] rounded-2xl">
            <Heart className="w-6 h-6 text-white" />
          </div>
          <div>
            <h2 className="text-lg">Heart Health</h2>
            <p className="text-sm text-gray-500">Overall Status</p>
          </div>
        </div>
        <Badge className="bg-[#2ECC71] hover:bg-[#2ECC71]/90">Excellent</Badge>
      </div>
      
      <div className="grid grid-cols-3 gap-4 mt-6">
        <div className="text-center p-3 bg-white rounded-xl shadow-sm">
          <p className="text-2xl text-[#0077B6]">72</p>
          <p className="text-xs text-gray-500 mt-1">Avg BPM</p>
        </div>
        <div className="text-center p-3 bg-white rounded-xl shadow-sm">
          <p className="text-2xl text-[#0077B6]">98%</p>
          <p className="text-xs text-gray-500 mt-1">Avg O₂</p>
        </div>
        <div className="text-center p-3 bg-white rounded-xl shadow-sm">
          <div className="flex items-center justify-center gap-1">
            <TrendingUp className="w-4 h-4 text-[#2ECC71]" />
            <p className="text-2xl text-[#2ECC71]">+5</p>
          </div>
          <p className="text-xs text-gray-500 mt-1">This Week</p>
        </div>
      </div>
    </Card>
  );
}
