<?php
$content = file_get_contents("/var/www/html/api/v2/endpoints/new_post.php");

// Fix: ensure $response_data is set on error path
$search = 'if ($id) {';
$replace = 'if ($id) {';
$content = str_replace(
    'else{',
    'else{
    $response_data = array("api_status" => 400, "errors" => array("error_id" => 14, "error_text" => "' . addslashes($error_message) . '"));
    ',
    $content
);

// Fix: the broken syntax at the end where if(empty($id)) is outside the else block
// The file currently has:
// } else {
//     $id = Wo_RegisterPost($post_data);
// if (empty($id)) {
//     global $sqlConnect;
// }
//     }
// This needs to be cleaned up to:
// } else {
//     $id = Wo_RegisterPost($post_data);
// }

$content = preg_replace(
    '/if \(empty\(\$id\)\) \{\s*global \$sqlConnect;\s*\}/s',
    '',
    $content
);

file_put_contents("/var/www/html/api/v2/endpoints/new_post.php", $content);
file_put_contents("/tmp/fix_log.txt", "Fixed new_post.php error handling\n");
echo "Fixed\n";
?>