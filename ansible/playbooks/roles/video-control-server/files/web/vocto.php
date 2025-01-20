<?php 
require_once(dirname(__FILE__)."/inc.php");
?>
<!DOCTYPE html>

<?php
function roomlist() {
    echo "<h1>room not found.</h1><br>";
    $r = $db->prepare("select roomname from fosdem order by roomname");
    $r->execute();
    while ($row = $r->fetch()) {
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

$r = $db->prepare("select voctop, audio from fosdem where roomname = :room");
$r->execute(['room' => $room]);
if (!$r) {
    roomlist();    
}

$row = $r->fetch();
$host = $row[0];
$audiobox = $row[1];



if (empty($_GET['w']) && empty($argv[1])) {
?>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>room <?php echo $room; ?></title>
<link rel="stylesheet" href="mixer.css"></script>
<link rel="stylesheet" href="vocto.css"></script>
<script src="chart.js"></script>
<script src="moment.js"></script>
<script src="chartjs-adapter-moment.js"></script>
<script src="chartjs-plugin-annotation.js"></script>
<script src="graph.js"></script>
<script src="mixer.js"></script>
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
<div>
<h2>Mixer</h2>
<script src="mixer.js"></script>
<datalist id="volumes">
<option value="1" label="100%"></option>
</datalist>

<div class="errors" id="errors"></div>

<div class="mixer">

<div class="inputs channellist" id="inputs">
<h2>Inputs</h2>
<!-- inserted by js -->
</div>

<div class="outputs channellist" id="outputs">
<h2>Outputs</h2>
<!-- inserted by js -->
</div>
</div>
</div>

<script>
"use strict";

window.onload = function() {
	const mixer = new Mixer('mixer/<?php echo $audiobox; ?>/');
	mixer.setupMixer().then(_ => {});
}
</script>
</div>
<div class="video-monitoring">
<div class="video-monitoring-grid">
<div class="card monitoring-large">
<div>Stream</div>
<img id="output" src="<?php echo $room;?>/room.jpg"/>
</div>
<div class="card">
<div>Camera</div>
<img id="cam" src="<?php echo $room;?>/cam.jpg"/>
</div>
<div class="card">
<div>Slides</div>
<img id="grab" src="<?php echo $room;?>/grab.jpg"/>
</div>
<div class="card monitoring-large">
<div>Audio</div>
<canvas id="chart-<?php echo $room; ?>" height="50"></canvas>
	<script>chart("<?php echo $room; ?>", document.getElementById("chart-<?php echo $room; ?>"), 1000);</script>
</div>
</div>
</div>
</div>

<!--<iframe src="mixer.php?room=<?php echo $room; ?>" title="Audio Mixer" height="0" width="0" style="border: none; height: 100vh; width: 100%;"></iframe>-->
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
