<?php 
require_once(dirname(__FILE__)."/inc.php");
?>
<!DOCTYPE html>

<?php
function roomlist() {
    echo "<h1>room not found.</h1><br>";
    $r = pg_query("select roomname from fosdem order by roomname");
    while ($row = pg_fetch_row($r)) {
        echo '<a style="font-size: larger;" href="/vocto.php?room='.$row[0].'">'.$row[0].'</a><br>';
    }
    exit();
}

if (empty($_GET['room']) ) {
    if (!empty($_SERVER['PHP_AUTH_USER']) && ($_SERVER['PHP_AUTH_USER'][0]=='1'|| $_SERVER['PHP_AUTH_USER'][0]=='2' ) ) {
        $spl = explode('-', $_SERVER['PHP_AUTH_USER']);
        $room = strtolower($spl[1]);
    } else {
        roomlist();
    }
} else {
    $room = strtolower($_GET['room']);
}

$r = pg_query("select voctop from fosdem where roomname='"._e($room)."'");
if (!$r) {
    roomlist();    
}

$row = pg_fetch_row($r);
$host = $row[0];



if (empty($_GET['w']) && empty($argv[1])) {
?>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>room <?php echo $room; ?></title>
<style>
.room-status {
    font-size: x-large;
    margin: 10px;
    display: flex;
    flex-direction: row;
}

.room-status label {
    display: block;
    flex: 1;
}
.room-status select {
    display: block;
    font-size: large;
    min-width: 50%;
}

.card > div {
    text-transform: capitalize;
    font-weight: bold;
}

/*
.container {
   display: flex;
   flex-direction: row;
   flex-wrap: wrap;
   align-items: center;
   justify-content: space-evenly;
}
*/

.container {
   display: grid;
}
.container > div {
   padding-left: 10px;
   padding-right: 10px;
}

.video-control-grid, .video-monitoring-grid {
    display: grid;
}

.video-control-grid {
    grid-template-columns: repeat(2, 1fr);
}

.video-monitoring img {
    width: 80%;
    max-width: 100%;
}

.video-control input[type=submit] {
    display: block;
    width: 100%;
    min-height: 50px;
    font-size: large;
    white-space: normal;
}

@media screen and (min-width: 576px) {
.container {
   grid-template-columns: repeat(2, 1fr);
}
.video-control-grid, .video-monitoring-grid {
    grid-template-columns: repeat(2, 1fr);
}
.monitoring-large {
    grid-column: span 2;
}
.video-control input[type=submit] {
    font-size: x-large;
}
}

.video-control form {
    display: flex;
    width: 100%;
    height: 100%;
}
</style>
<script src="chart.js"></script>
<script src="moment.js"></script>
<script src="chartjs-adapter-moment.js"></script>
<script src="chartjs-plugin-annotation.js"></script>
<script src="graph.js"></script>
</head>
<body>
<div class="container">
<div class="video-control">
<h2>Room <?php echo $room; ?></h2>
<div class="room-status">
<form>
<label for="room_status">Room Status: </label>
    <select id="room_status">
        <option value="" disabled selected></option>
        <option value="0">open</option>
        <option value="1">full</option>
    </select>
</form>
</div>
<div class="video-control-grid">
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="ssp-p"><input type="submit" value="side-by-side presenter"></form>
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="ssp-s"><input type="submit" value="side-by-side slides"></form>
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="fs-p"><input type="submit" value="fullscreen presenter"></form>
<td><form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="fs-s"><input type="submit" value="fullscreen slides"></form>
<!--
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="nostream"><input type="submit" value="nostream"></form>
<td><form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="live"><input type="submit" value="live"></form>
-->
</div>
</div>
<div class="video-monitoring">
<div class="video-monitoring-grid">
<div class="card monitoring-large">
<div>Stream</div>
<img id="output" src="/<?php echo $room;?>/room.jpg"/>
</div>
<div class="card">
<div>Camera</div>
<img id="cam" src="/<?php echo $room;?>/cam.jpg"/>
</div>
<div class="card">
<div>Slides</div>
<img id="grab" src="/<?php echo $room;?>/grab.jpg"/>
</div>
<div class="card monitoring-large">
<div>Audio</div>
<canvas id="chart-<?php echo $room; ?>" height="50"></canvas>
	<script>chart("<?php echo $room; ?>", document.getElementById("chart-<?php echo $room; ?>"), 1000);</script>
</div>
</div>
</div>
<script>
        const images = document.getElementsByTagName('img');
        for(let i = 0; i < images.length; i++) {
            const img = images[i];
            const src = img.src;
            img.addEventListener('load', function() {
                setTimeout(function() { img.src = src+'?'+Date.now() }, 2000); 
            });
        }
</script>
<script>
(function() {
    const room_status = document.getElementById('room_status');
    room_status.onchange = function(){
        room_status.value;
        const http = new XMLHttpRequest();
        const status_url = "room_status.php?state="+room_status.value;
        http.open("GET", status_url);
        http.send();

        http.onreadystatechange=(e)=>{
            console.log(http.responseText);
        }
    }
})();    

</script>
<iframe name="tgt" id="target" width="0" height="0"></iframe>
</body>
<?php
    exit();
}


if (empty($_GET['w'])) {
    $param = $argv[1];
} else {
    $param = $_GET['w'];
}

if ($param === 'ssp-p') $cmd = array('set_video_a cam1', 'set_video_b grabber', 'set_composite_mode side_by_side_preview');
if ($param === 'ssp-s') $cmd = array('set_video_b cam1', 'set_video_a grabber', 'set_composite_mode side_by_side_preview');
if ($param === 'fs-p') $cmd = array('set_video_a cam1', 'set_composite_mode fullscreen');
if ($param === 'fs-s') $cmd = array('set_video_a grabber', 'set_composite_mode fullscreen');
if ($param === 'nostream') $cmd = array('set_stream_blank pause');
if ($param === 'live') $cmd = array('set_stream_live');

$fp=fsockopen($host, 9999, $errno, $errstr, 30);

if (!$fp) {
    echo "$errstr ($errno)<br />\n";
    exit(1);
}

foreach ($cmd as $k => $command)  {
    fwrite($fp, $command."\n");
}
fclose($fp);
