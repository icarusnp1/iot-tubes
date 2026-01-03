<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once "vendor/autoload.php";

use PhpMqtt\Client\MqttClient;
use PhpMqtt\Client\ConnectionSettings;

// Preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function clearUserFromMQTT() {
    $server   = "2ff07256b4f0416ca838d5d365529cfe.s1.eu.hivemq.cloud";
    $port     = 8883;
    $clientId = "php-logout-backend";
    $username = "Tubes_iot123";
    $password = "Tubes_iot123";

    $mqtt = new MqttClient($server, $port, $clientId);

    $settings = (new ConnectionSettings)
        ->setUsername($username)
        ->setPassword($password)
        ->setUseTls(true);

    $mqtt->connect($settings, true);

    // ⛔ user logout → kirim 0
    $mqtt->publish("esp32_1/session", "0", 1, true);

    $mqtt->disconnect();
}

clearUserFromMQTT();

echo json_encode([
    "message" => "Logout berhasil, user dilepas dari ESP32"
]);