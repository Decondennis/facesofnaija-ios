<?php
$content = file_get_contents("/var/www/html/api/v2/endpoints/get-user-data.php");
$lines = explode("\n", $content);
for ($i = 125; $i <= 135; $i++) {
    echo ($i + 1) . ": " . ($lines[$i] ?? "N/A") . PHP_EOL;
}
?>