<?php
include_once('apikeys.php');
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
$endpoint = "https://api.fosdem.org/roomstatus/v1/";
$url = $endpoint . "listrooms"; 
$response = file_get_contents($url);
//print($response);
$room_list = json_decode($response);
// print_r($room_list);
//
$room_name = $_GET['room'];
$room_id = $room_ids[$room_name];
foreach($room_list as $room){
    if ($room->id == $room_id)
       $result = $room;
}
print(json_encode($result));
?>
