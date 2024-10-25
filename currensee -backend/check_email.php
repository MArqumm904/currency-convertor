<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");
error_reporting(E_ALL);
ini_set('display_errors', 1);


if (isset($_POST['email'])) {
    $email = $_POST['email'];

    // Check if email exists in the database
    $sql = "SELECT * FROM users WHERE email = ?";
    $stmt = $con->prepare($sql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Email exists, send a success response
        echo json_encode(['status' => 'valid']);
    } else {
        // Email doesn't exist
        echo json_encode(['status' => 'invalid']);
    }
    $stmt->close();
} else {
    // No email provided
    echo json_encode(['status' => 'no_email']);
}

$con->close();
