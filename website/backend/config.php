<?php
// config.php
$host = "localhost";
$dbname = "heart_monitoring";
$user = "root"; // sesuaikan
$pass = "";     // sesuaikan

$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
];