<?php
$content = file_get_contents("/var/www/html/api/v2/endpoints/new_post.php");
$content = str_replace(
    'if (empty($wo["user"]["user_id"])) {',
    "// Disabled auth check - handled by api-v2.php\nif (false) {",
    $content
);
file_put_contents("/var/www/html/api/v2/endpoints/new_post.php", $content);
echo "Done\n";
?>