<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

require_once "db.php";

// Preflight CORS
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit;
}

// ================================
// Ambil user_id (Header / GET)
// ================================
$user_id = null;

// Dari Authorization: Bearer {user_id}
if (isset($_SERVER["HTTP_AUTHORIZATION"])) {
    $auth = trim($_SERVER["HTTP_AUTHORIZATION"]);
    if (preg_match('/Bearer\s+(\d+)/', $auth, $match)) {
        $user_id = intval($match[1]);
    }
}

// Dari query string ?user_id=
if (isset($_GET["user_id"])) {
    $user_id = intval($_GET["user_id"]);
}

if (!$user_id) {
    http_response_code(400);
    echo json_encode([
        "message" => "user_id tidak ditemukan"
    ]);
    exit;
}

try {
    // ================================
    // Ambil data sensor terbaru
    // ================================
    $stmt = $pdo->prepare("
        SELECT *
        FROM sensor_readings
        WHERE user_id = ?
        ORDER BY recorded_at DESC
        LIMIT 1
    ");
    $stmt->execute([$user_id]);
    $data = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$data) {
        echo json_encode([
            "message" => "Tidak ada data sensor",
            "data" => null
        ]);
        exit;
    }

    // ================================
    // Response JSON (tanpa pengolahan)
    // ================================
    echo json_encode([
        "message" => "Berhasil mengambil data sensor",
        "data" => $data
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "message" => "Gagal mengambil data sensor",
        "error" => $e->getMessage()
    ]);
}