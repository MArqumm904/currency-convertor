<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include("db.php");

error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get the request body
$data = json_decode(file_get_contents("php://input"));

// Check if data is received
if (isset($data->email) && isset($data->name)) {
    $email = mysqli_real_escape_string($con, $data->email);
    $name = mysqli_real_escape_string($con, $data->name);

    // Check if email exists
    $checkQuery = "SELECT * FROM users WHERE email='$email'";
    $result = mysqli_query($con, $checkQuery);

    if (mysqli_num_rows($result) > 0) {
        // Email found, update user details
        $updateQuery = "UPDATE users SET name='$name' WHERE email='$email'";
        if (mysqli_query($con, $updateQuery)) {
            echo json_encode(['success' => true]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Update failed.']);
        }
    } else {
        // Email not found
        echo json_encode(['success' => false, 'message' => 'Email not found.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid input.']);
}

mysqli_close($con);
?>
