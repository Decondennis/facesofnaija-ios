<?php
$content = file_get_contents("/var/www/html/api/v2/endpoints/get_announcements.php");
$content = str_replace('if (empty($wo["user"]["user_id"])) {', "// Disabled\nif (false) {", $content);
file_put_contents("/var/www/html/api/v2/endpoints/get_announcements.php", $content);
echo "Done\n";
?>