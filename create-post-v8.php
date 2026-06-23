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
    
    function my_save_file($tmp, $name, $type, $uid) {
        $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));
        if (empty($ext)) {
            $ext = ($type == "image") ? "jpg" : (($type == "video") ? "mp4" : "");
        }
        $month = date("Y") . "/" . date("m");
        $dir = __DIR__ . "/../../upload/photos/$month";
        if (!is_dir($dir)) {
            mkdir($dir, 0755, true);
        }
        $filename = $uid . "_" . time() . "_" . rand(1000, 9999) . "." . $ext;
        $dest = "$dir/$filename";
        if (move_uploaded_file($tmp, $dest)) {
            return $filename;
        } elseif (copy($tmp, $dest)) {
            return $filename;
        }
        return "";
    }
    
    $photos = !empty($_FILES["postPhotos"]) ? $_FILES["postPhotos"] : (!empty($_FILES["postPhotos[]"]) ? $_FILES["postPhotos[]"] : null);
    
    if (!empty($photos["tmp_name"])) {
        if (is_array($photos["tmp_name"])) {
            $multi_image = 1;
            $uploaded = array();
            foreach ($photos["tmp_name"] as $i => $tmp) {
                if (!empty($tmp)) {
                    $fname = is_array($photos["name"]) ? ($photos["name"][$i] ?? "image.jpg") : $photos["name"];
                    $saved = my_save_file($tmp, $fname, "image", $uid);
                    if (!empty($saved)) $uploaded[] = $saved;
                }
            }
            $post_photo = implode(",", $uploaded);
            if (!empty($uploaded)) {
                $post_file = $uploaded[0];
                $post_filename = $photos["name"][0] ?? "image.jpg";
            }
        } else {
            $fname = $photos["name"] ?? "image.jpg";
            $saved = my_save_file($photos["tmp_name"], $fname, "image", $uid);
            if (!empty($saved)) {
                $post_photo = $saved;
                $post_file = $saved;
                $post_filename = $fname;
            }
        }
    }
    
    if (!empty($_FILES["postVideo"]["tmp_name"])) {
        $vf = $_FILES["postVideo"];
        $saved = my_save_file($vf["tmp_name"], $vf["name"] ?? "video.mp4", "video", $uid);
        if (!empty($saved)) {
            $post_file = $saved;
            $post_filename = $vf["name"] ?? "video.mp4";
        }
    }
    
    $post_data = array(
        "user_id" => $uid,
        "postText" => $post_text,
        "postPrivacy" => $privacy,
        "time" => time(),
        "active" => 1
    );
    if (!empty($post_photo)) {
        $post_data["postPhoto"] = $post_photo;
        if ($multi_image) $post_data["multi_image"] = $multi_image;
    }
    if (!empty($post_file)) {
        $post_data["postFile"] = $post_file;
        if (!empty($post_filename)) $post_data["postFileName"] = $post_filename;
    }
    
    $id = Wo_RegisterPost($post_data);
    
    if (!empty($id)) {
        $response_data = array(
            "api_status" => "200",
            "post_data" => array("post_id" => strval($id)),
            "post_html" => ""
        );
    } else {
        $time = time();
        $pt = mysqli_real_escape_string($sqlConnect, $post_text);
        $pp = mysqli_real_escape_string($sqlConnect, $post_photo);
        $pf = mysqli_real_escape_string($sqlConnect, $post_file);
        $pfn = mysqli_real_escape_string($sqlConnect, $post_filename);
        $mi = intval($multi_image);
        
        $cols = "`user_id`,`postText`,`postPrivacy`,`time`,`active`,`postType`,`page_id`,`group_id`,`community_id`,`event_id`,`page_event_id`,`postShare`,`postLink`,`postLinkTitle`,`postLinkImage`,`postLinkContent`";
        $vals = "'$uid','$pt','$privacy','$time','1','post','0','0','0','0','0','0','','','',''";
        
        if (!empty($post_photo)) {
            $cols .= ",`postPhoto`,multi_image";
            $vals .= ",'$pp','$mi'";
        }
        if (!empty($post_file)) {
            $cols .= ",`postFile`";
            $vals .= ",'$pf'";
            if (!empty($post_filename)) {
                $cols .= ",`postFileName`";
                $vals .= ",'$pfn'";
            }
        }
        
        $sql = "INSERT INTO " . T_POSTS . " ($cols) VALUES ($vals)";
        $query = mysqli_query($sqlConnect, $sql);
        
        if ($query) {
            $id = mysqli_insert_id($sqlConnect);
            mysqli_query($sqlConnect, "UPDATE " . T_POSTS . " SET `post_id` = {$id} WHERE `id` = {$id}");
            $response_data = array(
                "api_status" => "200",
                "api_text" => "success",
                "post_data" => array("post_id" => $id),
                "post_html" => ""
            );
        } else {
            $err = mysqli_error($sqlConnect);
            $response_data = array(
                "api_status" => "400",
                "errors" => array("error_id" => 99, "error_text" => "SQL Error: $err")
            );
        }
    }
}
?>
