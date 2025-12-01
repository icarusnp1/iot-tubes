<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // biar bisa diakses dari localhost/frontend
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once "db.php"; // pastikan db.php sudah terhubung ke MySQL

// Cek preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Ambil user_id dari query parameter
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;
if ($user_id <= 0) {
    http_response_code(400);
    echo json_encode(["message" => "User ID tidak valid!"]);
    exit;
}

try {
    // Ambil data user
    $stmt = $pdo->prepare("SELECT id, name, email, date_of_birth FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        http_response_code(404);
        echo json_encode(["message" => "User tidak ditemukan"]);
        exit;
    }

    // Ambil data kesehatan user (user_health)
    $stmt2 = $pdo->prepare("SELECT blood_type, height_cm, weight_kg FROM user_health WHERE user_id = ?");
    $stmt2->execute([$user_id]);
    $health = $stmt2->fetch(PDO::FETCH_ASSOC);

    // Gabungkan data, biarkan null kalau belum ada
    $response = [
        "id" => $user['id'],
        "name" => $user['name'],
        "email" => $user['email'],
        "date_of_birth" => $user['date_of_birth'],
        "blood_type" => $health['blood_type'] ?? null,
        "height_cm" => $health['height_cm'] ?? null,
        "weight_kg" => $health['weight_kg'] ?? null
    ];

    echo json_encode($response);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Terjadi kesalahan server: " . $e->getMessage()]);
}