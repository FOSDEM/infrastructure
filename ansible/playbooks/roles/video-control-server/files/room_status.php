<?php
require_once(dirname(__FILE__)."/apikeys.php");

$endpoint = "https://api.fosdem.org/roomstatus/v1/";

if (!empty($_SERVER['PHP_AUTH_USER']) && ($_SERVER['PHP_AUTH_USER'][0]=='1'|| $_SERVER['PHP_AUTH_USER'][0]=='2' ) ) {
         $spl = explode('-', $_SERVER['PHP_AUTH_USER']);
         $room = strtolower($spl[1]);
         if (!array_key_exists($room, $api_keys)){
             print('room not found in api keys');
             die();
         }

        if (isset($_GET["state"]))
        {
            $state = $_GET["state"];
            if (!in_array($state, array('0','1','2'))){
                print('invalid status');
                die();
            }
            $url = $endpoint . "updateroom?key=".$api_keys[$room]."&state=".$state;
            $response = file_get_contents($url);
            print($response);            
        }
}
?>
