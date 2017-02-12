<?php

//step2. read from mysql

//echo $_POST["name"];
//echo $_POST["price"];

$connection = mysqli_connect("localhost","root","root","Pet");
//$connection = mysqli_connect("sql6.freemysqlhosting.net","sql6154349","mWU9fZ1uuU","sql6154349");

mysqli_query($connection,"set names 'utf8'");
//mysqli_set_charset($connection,"utf8");
if ( mysqli_connect_errno()){
    die("Can't establish connection from database, ".mysqli_connect_error());
}
$stmt = $connection->prepare("insert into find (breed,size,location,lat,lon,appearance,UpdateTime,displayTime,imageUrl,UserName) values (?,?,?,?,?,?,?,?,?,?)");
    //可以先用$_GET測試
$stmt->bind_param('sssddsssss', $_POST["breed"] , $_POST["size"] , $_POST["location"] , $_POST["lat"] , $_POST["lon"] ,  $_POST["appearance"], $_POST["UpdateTime"], $_POST["displayTime"], $_POST["imageUrl"], $_POST["UserName"]); //first parameter, s :string d:integer
$stmt->execute();
$stmt->close();

mysqli_close($connection);
echo json_encode(array("status"=>"ok"));

?>

