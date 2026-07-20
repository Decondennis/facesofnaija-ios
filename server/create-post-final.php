<?php
$response_data = array("api_status" => "400");

if (!empty($_POST["user_id"])) {
    $uid = intval($_POST["user_id"]);
    global $sqlConnect;
    
    $post_text = Wo_Secure($_POST["postText"] ?? "");
    $privacy = intval($_POST["postPrivacy"] ?? 0);
    
    if (empty($wo["user"]["user_id"])) {
        $ud = Wo_UserData($uid);
        if (!empty($ud)) {
            $wo["loggedin"] = true;
            $wo["user"] = $ud;
        }
    }
    
    $post_photo = "";
    $post_file = "";
    $post_filename = "";
    $multi_image = 0;
    
    function save_uploaded_file($file_field, $uid) {
        if (empty($_FILES[$file_field]["tmp_name"])) return "";
        $tmp = $_FILES[$file_field]["tmp_name"];
        $name = $_FILES[$file_field]["name"] ?? "file";
        $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));
        if (empty($ext)) $ext = "jpg";
        $month = date("Y") . "/" . date("m");
        $dir = "/var/www/html/upload/photos/$month";
        if (!is_dir($dir)) mkdir($dir, 0755, true);
        $filename = $uid . "_" . time() . "_" . rand(1000, 9999) . "." . $ext;
        $dest = "$dir/$filename";
        $rel = "upload/photos/$month/$filename";
        if (move_uploaded_file($tmp, $dest)) return $rel;
        if (copy($tmp, $dest)) return $rel;
        // Try reading raw data and writing
        $raw = file_get_contents($tmp);
        if ($raw !== false && file_put_contents($dest, $raw) !== false) return $rel;
        return "";
    }
    
    if (!empty($_FILES["postPhotos"]["tmp_name"])) {
        $saved = save_uploaded_file("postPhotos", $uid);
        if (!empty($saved)) {
            $post_photo = $saved;
            $post_file = $saved;
            $post_filename = $_FILES["postPhotos"]["name"] ?? "image.jpg";
        }
    }
    if (!empty($_FILES["postVideo"]["tmp_name"])) {
        $saved = save_uploaded_file("postVideo", $uid);
        if (!empty($saved)) { $post_file = $saved; $post_filename = $_FILES["postVideo"]["name"] ?? "video.mp4"; }
    }
    if (!empty($_FILES["postMusic"]["tmp_name"])) {
        $saved = save_uploaded_file("postMusic", $uid);
        if (!empty($saved)) { $post_file = $saved; $post_filename = $_FILES["postMusic"]["name"] ?? "audio.mp3"; }
    }
    if (!empty($_FILES["postFile"]["tmp_name"])) {
        $saved = save_uploaded_file("postFile", $uid);
        if (!empty($saved)) { $post_file = $saved; $post_filename = $_FILES["postFile"]["name"] ?? "file"; }
    }
    
    $post_data = array(
        "user_id" => $uid,
        "postText" => $post_text,
        "postPrivacy" => $privacy,
        "time" => time(),
        "active" => 1
    );
    if (!empty($post_photo)) { $post_data["postPhoto"] = $post_photo; }
    if (!empty($post_file)) { $post_data["postFile"] = $post_file; }
    if (!empty($post_filename)) { $post_data["postFileName"] = $post_filename; }
    
    $id = Wo_RegisterPost($post_data);
    
    if (!empty($id)) {
        $response_data = array("api_status" => "200", "post_data" => array("post_id" => strval($id)), "post_html" => "");
    } else {
        $time = time();
        $pt = mysqli_real_escape_string($sqlConnect, $post_text);
        $pp = mysqli_real_escape_string($sqlConnect, $post_photo);
        $pf = mysqli_real_escape_string($sqlConnect, $post_file);
        $pfn = mysqli_real_escape_string($sqlConnect, $post_filename);
        
        $cols = "`user_id`,`postText`,`postPrivacy`,`time`,`active`,`community_id`";
        $vals = "'$uid','$pt','$privacy','$time','1','0'";
        if (!empty($post_photo)) { $cols .= ",`postPhoto`"; $vals .= ",'$pp'"; }
        if (!empty($post_file)) { $cols .= ",`postFile`"; $vals .= ",'$pf'"; }
        if (!empty($post_filename)) { $cols .= ",`postFileName`"; $vals .= ",'$pfn'"; }
        
        $sql = "INSERT INTO " . T_POSTS . " ($cols) VALUES ($vals)";
        $query = mysqli_query($sqlConnect, $sql);
        
        if ($query) {
            $id = mysqli_insert_id($sqlConnect);
            mysqli_query($sqlConnect, "UPDATE " . T_POSTS . " SET `post_id` = {$id} WHERE `id` = {$id}");
            $response_data = array("api_status" => "200", "api_text" => "success", "post_data" => array("post_id" => $id), "post_html" => "");
        } else {
            $response_data = array("api_status" => "400", "errors" => array("error_id" => 99, "error_text" => "SQL Error: " . mysqli_error($sqlConnect)));
        }
    }
}
?>
