<?php

include "inc.php";

if(empty($_REQUEST['voctop'])) {	
	die("who are you (voctop param)");
}
$voct = $_REQUEST['voctop'];

$r = $db->prepare("SELECT roomname, cam, slides FROM fosdem WHERE voctop = :voctop");
$r->execute(['voctop' => $voct]);

if (!$r) {
	die("notfound");
}

$row = $r->fetch();
echo $row[0]." ".$row[1]." ".$row[2];
