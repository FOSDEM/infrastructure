<?php

include "inc.php";

if(empty($_REQUEST['voctop'])) {	
	die("who are you (voctop param)");
}
$voct = $_REQUEST['voctop'];

$r = pg_query("SELECT roomname, cam, slides FROM fosdem WHERE voctop='"._e($voct)."'");

if (!$r) {
	die("not found");
}

$row = pg_fetch_row($r);
echo $row[0]." ".$row[1]." ".$row[2];
