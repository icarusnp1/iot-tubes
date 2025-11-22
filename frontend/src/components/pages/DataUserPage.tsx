import { Card } from '../ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '../ui/table';
import { Badge } from '../ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { Input } from '../ui/input';
import { Button } from '../ui/button';
import { Download, Search, Calendar, Heart, Droplets, Thermometer } from 'lucide-react';
import { useState } from 'react';

interface DataUserPageProps {
  isDarkMode: boolean;
}

export function DataUserPage({ isDarkMode }: DataUserPageProps) {
  const [dateFilter, setDateFilter] = useState('today');
  const [searchQuery, setSearchQuery] = useState('');

  // Mock data
  const healthRecords = [
    {
      id: 1,
      timestamp: '2024-10-31 14:30:25',
      bpm: 75,
      spo2: 98,
      temperature: 36.5,
      activity: 'Jalan',
      status: 'normal'
    },
    {
      id: 2,
      timestamp: '2024-10-31 14:15:10',
      bpm: 82,
      spo2: 97,
      temperature: 36.6,
      activity: 'Joging',
      status: 'normal'
    },
    {
      id: 3,
      timestamp: '2024-10-31 14:00:45',
      bpm: 68,
      spo2: 99,
      temperature: 36.4,
      activity: 'Diam',
      status: 'normal'
    },
    {
      id: 4,
      timestamp: '2024-10-31 13:45:30',
      bpm: 105,
      spo2: 96,
      temperature: 37.0,
      activity: 'Lari',
      status: 'warning'
    },
    {
      id: 5,
      timestamp: '2024-10-31 13:30:15',
      bpm: 72,
      spo2: 98,
      temperature: 36.5,
      activity: 'Jalan',
      status: 'normal'
    },
  ];

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'normal':
        return <Badge className="bg-[#2ECC71] hover:bg-[#2ECC71]/90">Normal</Badge>;
      case 'warning':
        return <Badge className="bg-yellow-500 hover:bg-yellow-500/90">Peringatan</Badge>;
      case 'danger':
        return <Badge className="bg-[#E53935] hover:bg-[#E53935]/90">Bahaya</Badge>;
      default:
        return <Badge>-</Badge>;
    }
  };

  const handleExport = () => {
    // Simulate export
    alert('Data akan diexport ke file CSV');
  };

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? 'text-white' : 'text-gray-900'}`}>
      <div className="mb-6">
        <h1 className="text-2xl mb-2">Data Riwayat Pengguna</h1>
        <p className="text-sm text-gray-500">Riwayat monitoring kesehatan dan aktivitas</p>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card className={`p-4 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-500 mb-1">Total Records</p>
              <p className="text-2xl text-[#0077B6]">1,247</p>
            </div>
            <div className="p-3 bg-[#0077B6]/20 rounded-xl">
              <Heart className="w-6 h-6 text-[#0077B6]" />
            </div>
          </div>
        </Card>

        <Card className={`p-4 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-500 mb-1">Rata-rata BPM</p>
              <p className="text-2xl text-[#2ECC71]">75</p>
            </div>
            <div className="p-3 bg-[#2ECC71]/20 rounded-xl">
              <Heart className="w-6 h-6 text-[#2ECC71]" fill="currentColor" />
            </div>
          </div>
        </Card>

        <Card className={`p-4 ${
          isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
        }`}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-500 mb-1">Rata-rata SpO₂</p>
              <p className="text-2xl text-[#FF9800]">98%</p>
            </div>
            <div className="p-3 bg-[#FF9800]/20 rounded-xl">
              <Droplets className="w-6 h-6 text-[#FF9800]" />
            </div>
          </div>
        </Card>
      </div>

      {/* Filters and Search */}
      <Card className={`p-4 mb-6 ${
        isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
      }`}>
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <Input
              placeholder="Cari data..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10"
            />
          </div>

          <Select value={dateFilter} onValueChange={setDateFilter}>
            <SelectTrigger className="w-full md:w-40">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="today">Hari Ini</SelectItem>
              <SelectItem value="week">7 Hari</SelectItem>
              <SelectItem value="month">30 Hari</SelectItem>
              <SelectItem value="all">Semua</SelectItem>
            </SelectContent>
          </Select>

          <Button
            onClick={handleExport}
            className="bg-gradient-to-r from-[#2ECC71] to-[#0077B6] hover:from-[#27AE60] hover:to-[#005F8C] text-white"
          >
            <Download className="w-4 h-4 mr-2" />
            Export CSV
          </Button>
        </div>
      </Card>

      {/* Data Table */}
      <Card className={`${
        isDarkMode ? 'bg-[#2d3748] border-gray-700' : 'bg-white border-gray-200'
      }`}>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow className={isDarkMode ? 'border-gray-700' : 'border-gray-200'}>
                <TableHead className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                  Waktu
                </TableHead>
                <TableHead className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                  BPM
                </TableHead>
                <TableHead className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                  SpO₂
                </TableHead>
                <TableHead className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                  Suhu
                </TableHead>
                <TableHead className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                  Aktivitas
                </TableHead>
                <TableHead className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                  Status
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {healthRecords.map((record) => (
                <TableRow 
                  key={record.id}
                  className={isDarkMode ? 'border-gray-700' : 'border-gray-200'}
                >
                  <TableCell className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                    {record.timestamp}
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Heart className="w-4 h-4 text-[#E53935]" />
                      <span className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                        {record.bpm}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Droplets className="w-4 h-4 text-[#0077B6]" />
                      <span className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                        {record.spo2}%
                      </span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Thermometer className="w-4 h-4 text-[#FF9800]" />
                      <span className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                        {record.temperature}°C
                      </span>
                    </div>
                  </TableCell>
                  <TableCell className={isDarkMode ? 'text-gray-300' : 'text-gray-900'}>
                    {record.activity}
                  </TableCell>
                  <TableCell>
                    {getStatusBadge(record.status)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>
    </div>
  );
}
