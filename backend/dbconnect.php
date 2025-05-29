<?php
// dbconnect.php

$host = "localhost";
$username = "tensorfl_inas";
$password = " ";
$database = "tensorfl_smartnodex";

// Create connection
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Database connection failed: " . $conn->connect_error
    ]));
}

// Optional: Set character set
$conn->set_charset("utf8mb4");

// Return nothing if used as include
?>
