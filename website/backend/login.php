<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *"); // supaya bisa diakses dari frontend
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once "db.php";
require_once "vendor/autoload.php";

use PhpMqtt\Client\MqttClient;
use PhpMqtt\Client\ConnectionSettings;

function publishUserToMQTT($user_id) {
    $server   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud"; // ganti sesuai HiveMQ
    $port     = 8883;
    $clientId = "php-login-backend";
    $username = "Tubes_iot123";
    $password = "Tubes_iot123";

    $mqtt = new MqttClient($server, $port, $clientId);

    $settings = (new ConnectionSettings)
        ->setUsername($username)
        ->setPassword($password)
        ->setUseTls(true); // pakai TLS

    $mqtt->connect($settings, true);

    $payload = $user_id;
    $mqtt->publish("esp32_1/session", $payload, 1, true); // QoS=1, retained=true

    $mqtt->disconnect();
}

// Preflight OPTIONS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Ambil data JSON
$input = file_get_contents("php://input");
$data = json_decode($input, true);

$email = trim($data['username'] ?? '');
$password = trim($data['password'] ?? '');

if (!$email || !$password) {
    http_response_code(400);
    echo json_encode(["message" => "Email dan password harus diisi!"]);
    exit;
}

// Cari user di database
$stmt = $pdo->prepare("SELECT id, password_hash FROM users WHERE email = ?");
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    http_response_code(401);
    echo json_encode(["message" => "Email atau password salah!"]);
    exit;
}

// 👉 kirim user_id ke ESP32 lewat MQTT
publishUserToMQTT($user['id']);

// Login berhasil
echo json_encode([
    "message" => "Login berhasil!",
    "user_id" => $user['id']
]);