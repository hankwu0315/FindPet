<?php

//step2. read from mysql
$connection = mysqli_connect("localhost","root","root","Pet");
//$connection = mysqli_connect("sql6.freemysqlhosting.net","sql6154349","mWU9fZ1uuU","sql6154349");
mysqli_query($connection,"set names 'utf8'");
//mysqli_set_charset($connection,"utf8");
if ( mysqli_connect_errno()){
    die("Can't establish connection from database, ".mysqli_connect_error());
}

$query = "select * from find ";
$result = mysqli_query($connection,$query);
if ( !$result){
    die("can't execute query ");
}
?>

<?php
    $pets = array();
    while( $row = mysqli_fetch_assoc($result)){
        $pet = array();
        $pet["breed"] = $row["breed"];
        $pet["size"] = $row["size"];
        $pet["location"] = $row["location"];
        $pet["lat"] = $row["lat"];
        $pet["lon"] = $row["lon"];
        $pet["appearance"] = $row["appearance"];
        $pet["UpdateTime"] = $row["UpdateTime"];
        $pet["displayTime"] = $row["displayTime"];
        $pet["imageUrl"] = $row["imageUrl"];
        $pets[] = $pet;
        
    }
    mysqli_free_result($result);
    
    echo json_encode($pets,JSON_UNESCAPED_SLASHES);

?>


<?php
mysqli_close($connection);
?>

