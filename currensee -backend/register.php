<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");
error_reporting(E_ALL); // This suppresses errors and warnings

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Perform validation (e.g., check if email already exists, password length, etc.)
    
    // Check if email already exists in the database
    $checkEmailQuery = "SELECT * FROM users WHERE email='$email'";
    $checkResult = mysqli_query($con, $checkEmailQuery);

    if (mysqli_num_rows($checkResult) > 0) {
        // Email already exists
        echo json_encode(["success" => false, "message" => "Email already exists."]);
    } else {
        // Insert the user into the database
        $hashed_password = password_hash($password, PASSWORD_DEFAULT); // Use password hashing
        $query = "INSERT INTO users (name, email, password) VALUES ('$name', '$email', '$hashed_password')";

        if (mysqli_query($con, $query)) {
            echo json_encode(["success" => true, "message" => "User registered successfully"]);
        } else {
            echo json_encode(["success" => false, "message" => "Error registering user: " . mysqli_error($con)]);
        }
    }
} else {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
}
?>
