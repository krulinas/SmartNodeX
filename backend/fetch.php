<?php
// fetch.php
header("Content-Type: application/json");
require_once "dbconnect.php";

// Optional: limit number of results via ?limit=50
$limit = isset($_GET['limit']) ? intval($_GET['limit']) : 100;

// Validate limit
if ($limit <= 0 || $limit > 1000) {
    $limit = 100;
}

// Query from database
$sql = "SELECT temperature, humidity, timestamp FROM sensor_data ORDER BY timestamp DESC LIMIT ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $limit);
$stmt->execute();

$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => array_reverse($data) // reverse to make it oldest → newest
]);

$stmt->close();
$conn->close();
?>
