<?php

include "inc.php";

if(empty($_REQUEST['room'])) {	
	die("who are you (room param)");
}
$room = $_REQUEST['room'];

$r = $db->prepare("SELECT voctop FROM fosdem WHERE roomname = :room");
$r->execute(['room' => $room]);

if (!$r) {
	die("notfound");
}

$row = $r->fetch();
echo 'tcp://'.$row[0].':8899/?timeout=3000000';
