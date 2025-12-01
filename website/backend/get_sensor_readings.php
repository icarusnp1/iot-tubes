<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "db.php";

$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 0;

if ($user_id <= 0) {
    echo json_encode(["message" => "user_id wajib!"]);
    exit;
}

try {
    $sql = "SELECT 
                id,
                recorded_at AS timestamp,
                bpm,
                spo2,
                temp_c AS temperature,
                activity,
                status
            FROM sensor_readings
            WHERE user_id = ?
            ORDER BY recorded_at DESC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$user_id]);
    $records = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($records);

} catch (PDOException $e) {
    echo json_encode(["message" => $e->getMessage()]);
}