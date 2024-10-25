<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json'); // Set the content type to JSON
include('db.php');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'] ?? null;
    $name = $_POST['name'] ?? null;
    $email = $_POST['email'] ?? null;
    $password = $_POST['password'] ?? null;

    // Validate input
    if ($id && $name && $email) {
        // Optional: Hash the password if it’s not empty
        if (!empty($password)) {
            $hashed_password = password_hash($password, PASSWORD_BCRYPT);
            $sql = "UPDATE users SET name=?, email=?, password=? WHERE id=?";
            $stmt = $con->prepare($sql);
            $stmt->bind_param("sssi", $name, $email, $hashed_password, $id);
        } else {
            $sql = "UPDATE users SET name=?, email=? WHERE id=?";
            $stmt = $con->prepare($sql);
            $stmt->bind_param("ssi", $name, $email, $id);
        }

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'User updated successfully.']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Database update failed.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid input.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}

// Close database connection
$con->close();
