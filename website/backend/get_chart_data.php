<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

if (!isset($_GET["user_id"])) {
    echo json_encode(["message" => "user_id wajib"]);
    exit;
}

$user_id = intval($_GET["user_id"]);
$type = $_GET["type"] ?? "bpm";  
$range = $_GET["range"] ?? "hourly"; 

$field = $type === "spo2" ? "spo2" : "bpm";

try {

    // Tentukan query berdasarkan range
    switch ($range) {

        case "hourly":
            // 1 jam terakhir
            $query = "
                SELECT $field AS value,
                DATE_FORMAT(recorded_at, '%Y-%m-%d %H:%i') AS time
                FROM sensor_readings
                WHERE user_id = ?
                AND recorded_at >= NOW() - INTERVAL 1 HOUR
                ORDER BY recorded_at ASC
            ";
            break;

        case "daily":
            // hanya data hari ini (00:00 s/d sekarang)
            $query = "
                SELECT $field AS value,
                DATE_FORMAT(recorded_at, '%H:%i') AS time
                FROM sensor_readings
                WHERE user_id = ?
                AND DATE(recorded_at) = CURDATE()
                ORDER BY recorded_at ASC
            ";
            break;

        case "weekly":
            // 7 hari terakhir
            $query = "
                SELECT $field AS value,
                DATE_FORMAT(recorded_at, '%d/%m') AS time
                FROM sensor_readings
                WHERE user_id = ?
                AND recorded_at >= NOW() - INTERVAL 7 DAY
                ORDER BY recorded_at ASC
            ";
            break;

        case "monthly":
            // 30 hari terakhir
            $query = "
                SELECT $field AS value,
                DATE_FORMAT(recorded_at, '%d/%m') AS time
                FROM sensor_readings
                WHERE user_id = ?
                AND recorded_at >= NOW() - INTERVAL 30 DAY
                ORDER BY recorded_at ASC
            ";
            break;

        default:
            $query = "
                SELECT $field AS value,
                DATE_FORMAT(recorded_at, '%Y-%m-%d %H:%i') AS time
                FROM sensor_readings
                WHERE user_id = ?
                AND recorded_at >= NOW() - INTERVAL 1 HOUR
                ORDER BY recorded_at ASC
            ";
    }

    $stmt = $pdo->prepare($query);
    $stmt->execute([$user_id]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "message" => "Berhasil ambil data grafik",
        "data" => $rows
    ]);

} catch (Exception $e) {
    echo json_encode([
        "message" => "Gagal",
        "error" => $e->getMessage()
    ]);
}