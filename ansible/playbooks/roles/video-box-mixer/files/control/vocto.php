<?php 
?>
<!DOCTYPE html>

<?php

$room = gethostname();




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
<script src="reconnecting-websocket.js"></script>
<script src="mixer.js"></script>
</head>
<body>
<div class="container">
<div class="video-control">
<h2> Box <?php echo $room; ?></h2>
<div class="room-status">
</div>
<div class="video-control-grid">
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="ssp-p"><input type="submit" value="side-by-side presenter"></form>
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="ssp-s"><input type="submit" value="side-by-side slides"></form>
<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="fs-p"><input type="submit" value="fullscreen presenter"></form>
<td><form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="fs-s"><input type="submit" value="fullscreen slides"></form>
</div>
<div>

<script>
"use strict";

window.onload = function() {
	const inputsShown = ['IN1', 'IN2', 'IN3'];
const outputsShown = ['OUT1', 'OUT2', 'HP1', 'HP2'];
<?php if (!empty($_SERVER['PHP_AUTH_USER']) && ($_SERVER['PHP_AUTH_USER'][0]=='1'|| $_SERVER['PHP_AUTH_USER'][0]=='2' ) ) { ?>
const inputsControllable = [];
const outputsControllable = ['OUT2'];
const mutesControllable = false;
<?php } else { ?>
const inputsControllable = inputsShown;
const outputsControllable = outputsShown;
const mutesControllable = true;
<?php } ?>
	const audioMixer = new Mixer('mixer/<?php echo $audiobox; ?>', inputsShown, outputsShown, inputsControllable, outputsControllable, mutesControllable);
	audioMixer.setupMixer().then(_ => {});
}
</script>
</div>
<div class="video-monitoring">
<div class="video-monitoring-grid">
<div class="card monitoring-large">
<div>Stream</div>
<a href="tcp://<?php echo $row['voctop'] ?>:8899">
<img id="output" src="/preview.jpg"/>
</a>
</div>
<div class="card monitoring-large">
<div>Audio</div>
<canvas id="chart-<?php echo $room; ?>" height="100"></canvas>
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

$fp=fsockopen("127.0.0.1", 9999, $errno, $errstr, 30);

if (!$fp) {
    echo "$errstr ($errno)<br />\n";
    exit(1);
}

foreach ($cmd as $k => $command)  {
    fwrite($fp, $command."\n");
}
fclose($fp);
