<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");
error_reporting(E_ALL);
ini_set('display_errors', 1);

$input = json_decode(file_get_contents("php://input"), true);

// Check if 'user_id' is set in the request
if (isset($input['user_id'])) {
    $userId = $input['user_id'];
    // Prepare the SQL statement to prevent SQL injection
    $stmt = $con->prepare("SELECT name, email FROM users WHERE id = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();

    // Check if user was found
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $response = [
            "status" => "success",  // Changed from 'success' => true
            "data" => [
                "name" => $row['name'],
                "email" => $row['email']
            ]
        ];
    } else {
        $response = [
            "status" => "error",    // Changed from 'success' => false
            "message" => "User not found"
        ];
    }
    $stmt->close();
} else {
    $response = [
        "status" => "error",        // Changed from 'success' => false
        "message" => "User ID not provided"
    ];
}

// Close the database connection
$con->close();

// Return the response as JSON
echo json_encode($response);
?>