<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>


<?php

//step2. read from mysql
$connection = mysqli_connect("localhost","root","root","findPet");
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

<table>
<?php
    while( $row = mysqli_fetch_assoc($result)){
?>
    <tr><td><?php echo $row["breed"] ?>　<?php echo $row["size"] ?>元</td></tr>
<?php
    }
    mysqli_free_result($result);
?>

</table>

<?php
mysqli_close($connection);
?>

</body>
</html>
