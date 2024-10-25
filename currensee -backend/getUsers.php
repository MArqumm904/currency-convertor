<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include("db.php");


// SQL query to get users
$sql = "SELECT id, name, email FROM users WHERE role = 0";
$result = $con->query($sql);

$users = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'email' => $row['email']
        ];
    }
    echo json_encode(['success' => true, 'users' => $users]);
} else {
    echo json_encode(['success' => false, 'message' => 'No users found']);
}

$con->close();
?>
