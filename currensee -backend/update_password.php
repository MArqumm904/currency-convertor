<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if both email and new password are provided
if (isset($_POST['email']) && isset($_POST['new_password'])) {
    $email = $_POST['email'];
    $new_password = password_hash($_POST['new_password'], PASSWORD_DEFAULT);  // Hash the password

    // Update the password for the given email
    $sql = "UPDATE users SET password = ? WHERE email = ?";
    $stmt = $con->prepare($sql);
    $stmt->bind_param("ss", $new_password, $email);

    if ($stmt->execute()) {
        // Password update successful
        echo json_encode("password_updated");
    } else {
        // Password update failed
        echo json_encode("update_failed");
    }
    $stmt->close();
} else {
    // Missing email or password
    echo json_encode("missing_data");
}

$con->close();


?>