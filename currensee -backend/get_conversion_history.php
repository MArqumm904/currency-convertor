<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get user ID from request
$user_id = $_GET['user_id'];

// Validate user ID
if (!$user_id) {
    echo json_encode(['error' => 'User ID is missing']);
    exit();
}

// Prepare SQL statement
$sql = "SELECT * FROM conversions WHERE user_id = '$user_id' ORDER BY conversion_date DESC";
$result = $con->query($sql);

if (!$result) {
    echo json_encode(['error' => 'SQL error: ' . $con->error]);
    exit();
}

$conversions = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $conversions[] = $row; // Add each row to the array
    }
} else {
    echo json_encode(['message' => 'No conversions found']);
    exit();
}

// Return conversion history as JSON
echo json_encode($conversions);

// Close connection
$con->close();
?>