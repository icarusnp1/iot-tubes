<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once "db.php";

// Preflight
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit;
}

// Ambil user_id dari query atau token
$user_id = null;

// Jika pakai token Authorization → "Bearer xxx"
if (isset($_SERVER["HTTP_AUTHORIZATION"])) {
    $auth = trim($_SERVER["HTTP_AUTHORIZATION"]);
    // Jika format "Bearer USERID"
    if (preg_match('/Bearer\s+(\d+)/', $auth, $match)) {
        $user_id = intval($match[1]);
    }
}

// Jika user_id dikirim melalui URL: get_latest_sensor.php?user_id=5
if (isset($_GET["user_id"])) {
    $user_id = intval($_GET["user_id"]);
}

if (!$user_id) {
    http_response_code(400);
    echo json_encode(["message" => "user_id tidak ditemukan!"]);
    exit;
}

try {
    // Ambil 1 data sensor terbaru
    $stmt = $pdo->prepare("
        SELECT 
            id,
            recorded_at,
            ir_value,
            red_value,
            temp_c,
            humidity,
            accel_x,
            accel_y,
            accel_z,
            bpm,
            spo2,
            steps,
            speed_mps,
            activity,
            status,
            created_at
        FROM sensor_readings
        WHERE user_id = ?
        ORDER BY recorded_at DESC
        LIMIT 1
    ");

    $stmt->execute([$user_id]);
    $data = $stmt->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "message" => "Berhasil mengambil data sensor terbaru",
        "data" => $data ?: null
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "message" => "Gagal mengambil data sensor!",
        "error" => $e->getMessage()
    ]);
}