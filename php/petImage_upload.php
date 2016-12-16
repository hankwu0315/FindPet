<?php
//請自行參考 : http://www.w3schools.com/php/php_file_upload.asp
$target_dir = "uploads/";
$target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]);

$imageFileType = pathinfo($target_file,PATHINFO_EXTENSION);

if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
        echo "uploads/". basename( $_FILES["fileToUpload"]["name"]);
} else {
        echo "Sorry, there was an error uploading your file.";
}
    
// Check if image file is a actual image or fake image
/*
if(isset($_POST["submit"])) {
    $check = getimagesize($_FILES["fileToUpload"]["tmp_name"]);
    if($check !== false) {
        echo "File is an image - " . $check["mime"] . ".";
        $uploadOk = 1;
    } else {
        echo "File is not an image.";
        $uploadOk = 0;
    }
}
*/
?>