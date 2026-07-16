<?php
require_once "/var/www/html/assets/init.php";
$q = mysqli_query($sqlConnect, "SELECT id, text, active FROM " . T_ANNOUNCEMENT . " ORDER BY id DESC LIMIT 5");
while ($r = mysqli_fetch_assoc($q)) {
    echo "ID:" . $r["id"] . " active:" . $r["active"] . " text:" . substr($r["text"], 0, 80) . PHP_EOL;
}
?>