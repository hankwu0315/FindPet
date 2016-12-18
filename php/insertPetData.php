<?php

//step2. read from mysql

//echo $_POST["name"];
//echo $_POST["price"];

$connection = mysqli_connect("localhost","root","root","findPet");
mysqli_query($connection,"set names 'utf8'");
//mysqli_set_charset($connection,"utf8");
if ( mysqli_connect_errno()){
    die("Can't establish connection from database, ".mysqli_connect_error());
}
$stmt = $connection->prepare("insert into find (breed,size,location,appearance,UpdateTime,displayTime,imageUrl) values (?,?,?,?,?,?,?)");
    //可以先用$_GET測試
$stmt->bind_param('sssssss', $_POST["breed"] , $_POST["size"] , $_POST["location"] , $_POST["appearance"], $_POST["UpdateTime"], $_POST["displayTime"], $_POST["imageUrl"]); //first parameter, s :string d:integer
$stmt->execute();
$stmt->close();

mysqli_close($connection);
echo json_encode(array("status"=>"ok"));

?>

