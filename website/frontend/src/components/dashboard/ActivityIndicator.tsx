// import { Card } from '../ui/card';
// import { User, PersonStanding } from 'lucide-react';

// interface ActivityIndicatorProps {
//   activity: 'idle' | 'walking' | 'jogging' | 'running';
//   isDarkMode: boolean;
// }

// export function ActivityIndicator({ activity, isDarkMode }: ActivityIndicatorProps) {
//   const activities = [
//     { id: 'idle', label: 'Diam', icon: '🧍', color: '#9E9E9E' },
//     { id: 'walking', label: 'Jalan', icon: '🚶', color: '#2ECC71' },
//     { id: 'jogging', label: 'Joging', icon: '🏃', color: '#FF9800' },
//     { id: 'running', label: 'Lari', icon: '🏃‍♂️', color: '#E53935' },
//   ];

//   return (
//   <Card className={`p-6 mb-6 ${
//       isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
//     }`}>
//       <h3 className={`mb-4 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
//         Status Aktivitas
//       </h3>
//       <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
//         {activities.map((item) => {
//           const isActive = activity === item.id;
          
//           return (
          
//           <div
//           key={item.id}
//               className={`p-4 rounded-xl text-center transition-all ${
//                 isActive
//                   ? 'bg-gradient-to-br from-[#2ECC71]/20 to-[#0077B6]/20 border-2'
//                   : isDarkMode
//                   ? 'bg-gray-700/50 border border-gray-600'
//                   : 'bg-gray-50 border border-gray-200'
//               }`}
//               style={{ borderColor: isActive ? item.color : undefined }}
//             >
//               <div className="text-4xl mb-2">{item.icon}</div>
//               <p className={`text-sm ${
//                 isActive 
//                   ? isDarkMode ? 'text-white' : 'text-gray-900'
//                   : 'text-gray-500'
//               }`}>
//                 {item.label}
//               </p>
//               {isActive && (
//                 <div className="mt-2 flex items-center justify-center gap-1">
//                   <span className="relative flex h-2 w-2">
//                     <span 
//                       className="animate-ping absolute inline-flex h-full w-full rounded-full opacity-75"
//                       style={{ backgroundColor: item.color }}
//                     ></span>
//                     <span 
//                       className="relative inline-flex rounded-full h-2 w-2"
//                       style={{ backgroundColor: item.color }}
//                     ></span>
//                   </span>
//                   <span className="text-xs text-gray-500">Aktif</span>
//                 </div>
//               )}
//             </div>
//           );
//         })}
//       </div>
//     </Card>
//   );
// }
