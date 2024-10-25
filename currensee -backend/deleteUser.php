<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include('db.php');

// Check if request method is POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get the posted user ID
    $id = $_POST['id'];

    // Validate input
    if (!empty($id)) {
        // Prepare SQL query to delete user
        $query = "DELETE FROM users WHERE id = ?";
        if ($stmt = $con->prepare($query)) {
            $stmt->bind_param("i", $id);

            // Execute the query
            if ($stmt->execute()) {
                echo json_encode(['success' => true, 'message' => 'User deleted successfully.']);
            } else {
                echo json_encode(['success' => false, 'message' => 'Error deleting user: ' . $stmt->error]);
            }
            $stmt->close();
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to prepare statement: ' . $con->error]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid user ID.']);
    }
}

// Close database connection
$con->close();
?>
