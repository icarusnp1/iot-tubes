<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // biar bisa diakses dari localhost/frontend
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once "db.php";

// Cek preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Ambil data JSON dari request body
$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (!$data) {
    http_response_code(400);
    echo json_encode(["message" => "Tidak ada data yang dikirim!"]);
    exit;
}

// Ambil field
$user_id = isset($data['user_id']) ? (int)$data['user_id'] : 0;
$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$date_of_birth = trim($data['date_of_birth'] ?? '');
$blood_type = trim($data['blood_type'] ?? null);
$height_cm = isset($data['height_cm']) ? (float)$data['height_cm'] : null;
$weight_kg = isset($data['weight_kg']) ? (float)$data['weight_kg'] : null;

if ($user_id <= 0 || !$name || !$email) {
    http_response_code(400);
    echo json_encode(["message" => "User ID, nama, dan email harus diisi!"]);
    exit;
}

try {
    // Cek user ada tidak
    $stmt = $pdo->prepare("SELECT id FROM users WHERE id = ?");
    $stmt->execute([$user_id]);
    if (!$stmt->fetch()) {
        http_response_code(404);
        echo json_encode(["message" => "User tidak ditemukan"]);
        exit;
    }

    // Update data users
    $stmt = $pdo->prepare("UPDATE users SET name = ?, email = ?, date_of_birth = ? WHERE id = ?");
    $stmt->execute([$name, $email, $date_of_birth, $user_id]);

    // Cek data user_health sudah ada atau belum
    $stmt2 = $pdo->prepare("SELECT id FROM user_health WHERE user_id = ?");
    $stmt2->execute([$user_id]);
    $healthExists = $stmt2->fetch();

    // Hitung BMI jika height & weight ada
    $bmi = ($height_cm && $weight_kg) ? round($weight_kg / pow($height_cm / 100, 2), 2) : null;

    if ($healthExists) {
        // Update user_health
        $stmt3 = $pdo->prepare("UPDATE user_health SET blood_type = ?, height_cm = ?, weight_kg = ?, bmi = ? WHERE user_id = ?");
        $stmt3->execute([$blood_type, $height_cm, $weight_kg, $bmi, $user_id]);
    } else {
        // Insert baru ke user_health
        $stmt3 = $pdo->prepare("INSERT INTO user_health (user_id, blood_type, height_cm, weight_kg, bmi) VALUES (?, ?, ?, ?, ?)");
        $stmt3->execute([$user_id, $blood_type, $height_cm, $weight_kg, $bmi]);
    }

    echo json_encode(["message" => "Profil berhasil diperbarui!"]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["message" => "Terjadi kesalahan server: " . $e->getMessage()]);
}