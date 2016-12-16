<?php

//step2. read from mysql
$connection = mysqli_connect("localhost","root","root","findPet");
mysqli_query($connection,"set names 'utf8'");
//mysqli_set_charset($connection,"utf8");
if ( mysqli_connect_errno()){
    die("Can't establish connection from database, ".mysqli_connect_error());
}

    $query = "SELECT `breed`,`size`,`location`,`appearance` FROM find";
$result = mysqli_query($connection,$query);
if ( !$result){
    die("can't execute query ");
}
?>


<?php
    $pets = array();   //array
    while( $row = mysqli_fetch_assoc($result)){

        $pet = array();    //dictionary
        $pet["breed"] = $row["breed"];
        $pet["size"] = $row["size"];
        $pet["location"] = $row["location"];
        $pet["appearance"] = $row["appearance"];
        
        $pets[] = $pet;   //dictionary加到array
    }
    mysqli_free_result($result);
    
    echo json_encode($menus,JSON_UNESCAPED_SLASHES);
?>

<?php
mysqli_close($connection);
?>
