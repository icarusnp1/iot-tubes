<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // supaya bisa diakses dari localhost frontend
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

// Debug (opsional, bisa dihapus nanti)
// file_put_contents("debug.txt", $input . "\n" . print_r($data, true));

if (!$data) {
    http_response_code(400);
    echo json_encode(["message" => "Tidak ada data yang dikirim!"]);
    exit;
}

// Ambil field dari data JSON
$name = trim($data['username'] ?? '');
$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');
$dob = trim($data['birth'] ?? '');

if (!$name || !$email || !$password) {
    http_response_code(400);
    echo json_encode(["message" => "Semua field harus diisi!"]);
    exit;
}

// Cek email sudah terdaftar?
$stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->fetch()) {
    http_response_code(409);
    echo json_encode(["message" => "Email sudah terdaftar!"]);
    exit;
}

// Hash password
$hash = password_hash($password, PASSWORD_DEFAULT);

// Simpan user
$stmt = $pdo->prepare("INSERT INTO users (name, email, password_hash, date_of_birth) VALUES (?, ?, ?, ?)");
$stmt->execute([$name, $email, $hash, $dob]);

// Buat user_health kosong
$userId = $pdo->lastInsertId();
$stmt2 = $pdo->prepare("INSERT INTO user_health (user_id) VALUES (?)");
$stmt2->execute([$userId]);

echo json_encode(["message" => "Registrasi berhasil!"]);