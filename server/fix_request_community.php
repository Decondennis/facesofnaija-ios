<?php
$content = file_get_contents("/var/www/html/api/v2/endpoints/request-community.php");

// Fix: add error details to response_data for all error codes
$search = 'if (empty($_POST[$value]) && empty($error_code)) {
        $error_code = 3; $error_message = $value . " (POST) is missing";
    }';
$replace = 'if (empty($_POST[$value]) && empty($error_code)) {
        $error_code = 3; $error_message = $value . " (POST) is missing";
        $response_data = array("api_status" => 400, "errors" => array("error_id" => 3, "error_text" => $error_message));
    }';
$content = str_replace($search, $replace, $content);

// Fix error 4
$search2 = '$error_code = 4; $error_message = "Community name already exists.";';
$replace2 = '$error_code = 4; $error_message = "Community name already exists.";
        $response_data = array("api_status" => 400, "errors" => array("error_id" => 4, "error_text" => $error_message));';
$content = str_replace($search2, $replace2, $content);

file_put_contents("/var/www/html/api/v2/endpoints/request-community.php", $content);
echo "Fixed\n";
?>