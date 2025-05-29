<?php
// insert.php
header("Content-Type: application/json");
require_once "dbconnect.php";

// Read POST body
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (!isset($data['temperature']) || !isset($data['humidity'])) {
    echo json_encode([
        "success" => false,
        "message" => "Missing temperature or humidity data."
    ]);
    exit;
}

$temp = floatval($data['temperature']);
$hum = floatval($data['humidity']);

// Insert into database
$stmt = $conn->prepare("INSERT INTO sensor_data (temperature, humidity) VALUES (?, ?)");
$stmt->bind_param("dd", $temp, $hum);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Data inserted successfully."
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Insert failed: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
