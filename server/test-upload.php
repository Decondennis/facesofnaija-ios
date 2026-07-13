<?php
// Simple test to check if file upload is working
$response_data = array();

$response_data['post_received'] = $_POST;
$response_data['files_received'] = $_FILES;
$response_data['files_count'] = count($_FILES);

if (!empty($_FILES['postPhotos'])) {
    $response_data['postPhotos_details'] = array(
        'name' => $_FILES['postPhotos']['name'],
        'type' => $_FILES['postPhotos']['type'],
        'tmp_name' => $_FILES['postPhotos']['tmp_name'],
        'error' => $_FILES['postPhotos']['error'],
        'size' => $_FILES['postPhotos']['size']
    );
    
    if ($_FILES['postPhotos']['error'] === UPLOAD_ERR_OK) {
        $response_data['upload_status'] = 'File uploaded successfully to temp location';
        
        // Try to move the file
        $upload_dir = '/var/www/html/upload/photos/test/';
        if (!is_dir($upload_dir)) {
            mkdir($upload_dir, 0755, true);
        }
        
        $dest = $upload_dir . 'test_' . time() . '.jpg';
        
        if (move_uploaded_file($_FILES['postPhotos']['tmp_name'], $dest)) {
            $response_data['move_status'] = 'File moved successfully to: ' . $dest;
        } else {
            $response_data['move_status'] = 'Failed to move file';
            $response_data['move_error'] = error_get_last();
        }
    } else {
        $response_data['upload_status'] = 'Upload error: ' . $_FILES['postPhotos']['error'];
    }
} else {
    $response_data['upload_status'] = 'No postPhotos file received';
}

header('Content-Type: application/json');
echo json_encode($response_data, JSON_PRETTY_PRINT);
?>
