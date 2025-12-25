import { Card } from './ui/card';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Footprints, Flame, Gauge, Edit2 } from 'lucide-react';
import { useState } from 'react';

export function ActivityMonitor() {
  const [activityName, setActivityName] = useState('Morning Run');
  const [speed, setSpeed] = useState(8.5);
  const [steps, setSteps] = useState(8247);
  const [calories, setCalories] = useState(342);

  return (
    <Card className="p-6 border-[#2ECC71]/20">
      <div className="flex items-center gap-3 mb-6">
        <div className="p-3 bg-gradient-to-br from-[#2ECC71] to-[#27AE60] rounded-2xl">
          <Footprints className="w-6 h-6 text-white" />
        </div>
        <div>
          <h2 className="text-lg">Activity Monitoring</h2>
          <p className="text-sm text-gray-500">Track your activities</p>
        </div>
      </div>

      {/* Activity Name Input */}
      <div className="mb-6">
        <Label htmlFor="activity-name" className="text-sm text-gray-600 mb-2 block">
          Activity Name
        </Label>
        <div className="relative">
          <Input
            id="activity-name"
            value={activityName}
            onChange={(e) => setActivityName(e.target.value)}
            className="pr-10 border-gray-200 focus:border-[#2ECC71]"
            placeholder="Enter activity name"
          />
          <Edit2 className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        </div>
      </div>

      {/* Activity Stats Grid */}
      <div className="grid grid-cols-2 gap-4">
        {/* Running Speed */}
        <div className="p-4 bg-gradient-to-br from-[#0077B6]/5 to-white rounded-xl border border-[#0077B6]/10">
          <div className="flex items-center gap-2 mb-3">
            <Gauge className="w-4 h-4 text-[#0077B6]" />
            <span className="text-xs text-gray-500">Speed</span>
          </div>
          <div className="flex items-baseline gap-1">
            <span className="text-2xl text-[#0077B6]">{speed}</span>
            <span className="text-sm text-gray-400">km/h</span>
          </div>
        </div>

        {/* Steps */}
        <div className="p-4 bg-gradient-to-br from-[#2ECC71]/5 to-white rounded-xl border border-[#2ECC71]/10">
          <div className="flex items-center gap-2 mb-3">
            <Footprints className="w-4 h-4 text-[#2ECC71]" />
            <span className="text-xs text-gray-500">Steps</span>
          </div>
          <div className="flex items-baseline gap-1">
            <span className="text-2xl text-[#2ECC71]">{steps.toLocaleString()}</span>
            <span className="text-sm text-gray-400">/day</span>
          </div>
        </div>
      </div>

      {/* Calories Burned - Full Width */}
      <div className="mt-4 p-5 bg-gradient-to-r from-[#2ECC71] to-[#0077B6] rounded-xl text-white shadow-lg">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-white/20 rounded-lg backdrop-blur-sm">
              <Flame className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs text-white/80">Calories Burned</p>
              <div className="flex items-baseline gap-2 mt-1">
                <span className="text-3xl">{calories}</span>
                <span className="text-sm text-white/80">kcal</span>
              </div>
            </div>
          </div>
          <div className="text-right">
            <p className="text-xs text-white/80">Goal</p>
            <p className="text-lg">500</p>
          </div>
        </div>
        <div className="mt-3 bg-white/20 rounded-full h-2 overflow-hidden">
          <div 
            className="bg-white h-full rounded-full transition-all duration-500"
            style={{ width: `${(calories / 500) * 100}%` }}
          />
        </div>
      </div>
    </Card>
  );
}
