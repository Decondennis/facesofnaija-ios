<?php
$content = file_get_contents("/var/www/html/api/v2/endpoints/get-user-data.php");
$content = str_replace('$wo["user"]["id"]', '$wo["user"]["user_id"]', $content);
file_put_contents("/var/www/html/api/v2/endpoints/get-user-data.php", $content);
echo "Fixed\n";
?>