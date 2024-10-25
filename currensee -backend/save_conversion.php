<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');
include("db.php");
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if the request is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Collect POST data
    $user_id = $_POST['user_id'];
    $from_currency = $_POST['from_currency'];
    $to_currency = $_POST['to_currency'];
    $amount = $_POST['amount'];
    $total = $_POST['total'];
    $conversion_date = $_POST['conversion_date'];

    // SQL query to insert conversion data
    $sql = "INSERT INTO conversions (user_id, from_currency, to_currency, amount, total, conversion_date)
            VALUES ('$user_id', '$from_currency', '$to_currency', '$amount', '$total', '$conversion_date')";

    if ($con->query($sql) === TRUE) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false, "error" => $con->error]);
    }

    $con->close();
} else {
    echo json_encode(["success" => false, "error" => "Invalid request method"]);
}
?>