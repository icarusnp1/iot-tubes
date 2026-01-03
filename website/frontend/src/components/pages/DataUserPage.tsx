import { Card } from "../ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "../ui/table";
import { Badge } from "../ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../ui/select";
import { Input } from "../ui/input";
import { Button } from "../ui/button";
import { Download, Search, Heart, Droplets, Thermometer } from "lucide-react";
import { useState, useEffect } from "react";
import { toast } from "sonner";
import * as XLSX from "xlsx";

interface DataUserPageProps {
  isDarkMode: boolean;
  userId: number;
}

interface SensorRecord {
  id: number;
  timestamp: string;
  bpm: number | string | null;
  spo2: number | string | null;
  temperature: number | string | null;
  activity: string | null;
  status: string | null;
}

export function DataUserPage({ isDarkMode, userId }: DataUserPageProps) {
  const [dateFilter, setDateFilter] = useState("today");
  const [searchQuery, setSearchQuery] = useState("");
  const [healthRecords, setHealthRecords] = useState<SensorRecord[]>([]);

  useEffect(() => {
  console.log("UserID in useEffect:", userId);

  if (!userId) {
    console.warn("UserId tidak valid, fetch dibatalkan");
    return;
  }

    const fetchData = async () => {
      try {
        const res = await fetch(
          `http://sem5.test/iot-tubes/website/backend/get_sensor_readings.php?user_id=${userId}`
        );

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || "Gagal mengambil data sensor");

        setHealthRecords(data);
      } catch (err: any) {
        toast.error(err.message);
        console.error("Fetch error:", err);
      }
    };

    fetchData();
  }, [userId]);

  const getStatusBadge = (status: string | null) => {
    switch (status) {
      case "normal":
        return <Badge className="bg-[#2ECC71]">Normal</Badge>;
      case "warning":
        return <Badge className="bg-yellow-500">Peringatan</Badge>;
      case "danger":
        return <Badge className="bg-[#E53935]">Bahaya</Badge>;
      default:
        return <Badge>-</Badge>;
    }
  };

const handleExport = () => {
  if (filteredRecords.length === 0) {
    toast.error("Tidak ada data untuk diexport!");
    return;
  }

  // Format data untuk XLSX
  const exportData = filteredRecords.map((r) => ({
    Waktu: r.timestamp,
    BPM: r.bpm ?? "-",
    SpO2: r.spo2 ?? "-",
    //Suhu: r.temperature ?? "-",
    //Aktivitas: r.activity ?? "-",
    Status: r.status ?? "-",
  }));

  // Buat worksheet
  const worksheet = XLSX.utils.json_to_sheet(exportData);

  // Buat workbook
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Sensor Data");

  // Download file XLSX
  XLSX.writeFile(workbook, "sensor_records.xlsx");
};

  // Filter pencarian
  const applyDateFilter = (records: SensorRecord[]) => {
  const now = new Date();

  return records.filter((record) => {
    const recordDate = new Date(record.timestamp);

    switch (dateFilter) {
      case "today":
        return (
          recordDate.toDateString() === now.toDateString()
        );

      case "week":
        const weekAgo = new Date();
        weekAgo.setDate(now.getDate() - 7);
        return recordDate >= weekAgo;

      case "month":
        const monthAgo = new Date();
        monthAgo.setDate(now.getDate() - 30);
        return recordDate >= monthAgo;

      case "all":
      default:
        return true;
    }
  });
};

  const filteredRecords = applyDateFilter(healthRecords).filter((r) => {
  const text = `${r.timestamp} ${r.bpm} ${r.spo2} ${r.temperature} ${r.activity}`.toLowerCase();
  return text.includes(searchQuery.toLowerCase());
});


  // Hitung rata-rata BPM dari data yang sudah difilter
const avgBpm =
  filteredRecords.length > 0
    ? Math.round(
        filteredRecords.reduce((sum, r) => sum + Number(r.bpm || 0), 0) /
          filteredRecords.length
      )
    : "-";

// Hitung rata-rata SpO2 dari data yang sudah difilter
const avgSpo2 =
  filteredRecords.length > 0
    ? Math.round(
        filteredRecords.reduce((sum, r) => sum + Number(r.spo2 || 0), 0) /
          filteredRecords.length
      )
    : "-";

  return (
    <div className={`p-4 lg:p-6 ${isDarkMode ? "text-white" : "text-gray-900"}`}>
      <div className="mb-6">
        <h1 className="text-2xl mb-2">Data Riwayat Pengguna</h1>
        <p className="text-sm text-gray-500">Riwayat monitoring kesehatan dan aktivitas</p>
      </div>

      {/* Statistik */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        {/* Total Records */}
        <Card
          className={`p-4 ${isDarkMode ? "bg-[#2d3748]" : "bg-white"}`}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-500 mb-1">Total Records</p>
              <p className="text-2xl text-[#0077B6]">{filteredRecords.length}</p>
            </div>
            <div className="p-3 bg-[#0077B6]/20 rounded-xl">
              <Heart className="w-6 h-6 text-[#0077B6]" />
            </div>
          </div>
        </Card>

        {/* Average BPM */}
        <Card className={`p-4 ${isDarkMode ? "bg-[#2d3748]" : "bg-white"}`}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-500 mb-1">Rata-rata BPM</p>
              <p className="text-2xl text-[#2ECC71]">{avgBpm}</p>
            </div>
            <div className="p-3 bg-[#2ECC71]/20 rounded-xl">
              <Heart className="w-6 h-6 text-[#2ECC71]" fill="currentColor" />
            </div>
          </div>
        </Card>

        {/* Average SpO2 */}
        <Card className={`p-4 ${isDarkMode ? "bg-[#2d3748]" : "bg-white"}`}>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-500 mb-1">Rata-rata SpO₂</p>
              <p className="text-2xl text-[#FF9800]">{avgSpo2}%</p>
            </div>
            <div className="p-3 bg-[#FF9800]/20 rounded-xl">
              <Droplets className="w-6 h-6 text-[#FF9800]" />
            </div>
          </div>
        </Card>
      </div>

      {/* Filter dan Pencarian */}
      <Card className={`p-4 mb-6 ${isDarkMode ? "bg-[#2d3748]" : "bg-white"}`}>
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
            className="bg-gradient-to-r from-[#2ECC71] to-[#0077B6] text-white"
          >
            <Download className="w-4 h-4 mr-2" />
            Export XLSX
          </Button>
        </div>
      </Card>

      {/* Tabel Data */}
      <Card className={`${isDarkMode ? "bg-[#2d3748]" : "bg-white"}`}>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Waktu</TableHead>
                <TableHead>BPM</TableHead>
                <TableHead>SpO₂</TableHead>
                {/* <TableHead>Suhu</TableHead>
                <TableHead>Aktivitas</TableHead> */}
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              {filteredRecords.map((record) => (
                <TableRow key={record.id}>
                  <TableCell>{record.timestamp}</TableCell>

                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Heart className="w-4 h-4 text-[#E53935]" />
                      {record.bpm ?? "-"}
                    </div>
                  </TableCell>

                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Droplets className="w-4 h-4 text-[#0077B6]" />
                      {record.spo2 ?? "-"}%
                    </div>
                  </TableCell>

                  {/* <TableCell>
                    <div className="flex items-center gap-2">
                      <Thermometer className="w-4 h-4 text-[#FF9800]" />
                      {record.temperature ?? "-"}°C
                    </div>
                  </TableCell> */}

                  {/* <TableCell>{record.activity ?? "-"}</TableCell> */}
                  <TableCell>{getStatusBadge(record.status)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>
    </div>
  );
}