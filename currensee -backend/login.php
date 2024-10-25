<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");
error_reporting(E_ALL);
ini_set('display_errors', 1);

function logError($message) {
    error_log(date('[Y-m-d H:i:s] ') . $message . "\n", 3, 'login_errors.log');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    logError("Login attempt for email: $email");

    $stmt = $con->prepare("SELECT * FROM users WHERE email = ?");
    if (!$stmt) {
        logError("Prepare failed: " . $con->error);
        echo json_encode(['success' => false, 'message' => 'Database error']);
        exit;
    }

    $stmt->bind_param("s", $email);
    if (!$stmt->execute()) {
        logError("Execute failed: " . $stmt->error);
        echo json_encode(['success' => false, 'message' => 'Database error']);
        exit;
    }

    $result = $stmt->get_result();
    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        $storedPassword = $user['Password'];

        if (password_verify($password, $storedPassword)) {
            $role = $user['role'];
            $user_id = $user['id'];
            logError("Login successful for email: $email");
            echo json_encode(['success' => true, 'role' => $role, 'user_id' => $user_id]);
        } else {
            logError("Invalid password for email: $email");
            echo json_encode(['success' => false, 'message' => 'Invalid password']);
        }
    } else {
        logError("Invalid email: $email");
        echo json_encode(['success' => false, 'message' => 'Invalid email']);
    }

    $stmt->close();
} else {
    logError("Invalid request method: " . $_SERVER['REQUEST_METHOD']);
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}
?>
