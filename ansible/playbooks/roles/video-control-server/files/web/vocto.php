<?php 
require_once(dirname(__FILE__)."/inc.php");
?>
<!DOCTYPE html>

<?php
function roomlist($db) {
    echo "<h1>Room List</h1><br>";
    $r = $db->prepare("select roomname from fosdem order by roomname");
    $r->execute();
    foreach ($r as $row) {
        echo '<a style="font-size: larger;" href="/vocto.php?room='.$row[0].'">'.$row[0].'</a><br>';
    }
    exit();
}

if (empty($_GET['room']) ) {
    if (!empty($_SERVER['PHP_AUTH_USER']) && ($_SERVER['PHP_AUTH_USER'][0]=='1'|| $_SERVER['PHP_AUTH_USER'][0]=='2' ) ) {
        $spl = explode('-', $_SERVER['PHP_AUTH_USER']);
        $room = strtolower($spl[1]);
    } else {
        roomlist($db);
    }
} else {
    $room = strtolower($_GET['room']);
}

$r = $db->prepare("select voctop, audio, cam, slides from fosdem where roomname = :room");
$r->execute(['room' => $room]);
if (!$r) {
    roomlist();    
}

$row = $r->fetch();
$host = $row['voctop'];
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
<script src="reconnecting-websocket.js"></script>
<script src="mixer.js"></script>
</head>
<body>
<div class="container">
<div class="video-control">
<h2><a href="/vocto.php">home</a> | Room <?php echo $room; ?></h2>
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
<h2>Mixer on <?php echo $audiobox; ?>; <a href="https://control.video.fosdem.org/grafana/d/aeacoqvn453b4a/mixer-levels?orgId=1&from=now-5m&to=now&timezone=browser&var-Box=<?php echo $room; ?>&refresh=5s">Grafana</a></h2>
<datalist id="volumes">
<option value="1" label="100%"></option>
</datalist>

<div class="errors" id="errors"></div>

<div class="mixer">

<div class="mixer">
<h2>Inputs (pre-fader)</h2>
<div class="inputs channellist" id="inputs">
<!-- inserted by js -->
</div>
</div>
<div class="mixer">
<h2>Outputs (post-fader)</h2>
<div class="outputs channellist" id="outputs">
<!-- inserted by js -->
</div>
</div>
</div>
</div>

<div id="kur"></div>

<script>
"use strict";

window.onload = function() {
	const inputsShown = ['IN1', 'IN2', 'IN3', 'PC'];
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
                        <a class="mpv-m3u" href="tcp://<?php echo $row['voctop'] ?>:8899">
<img id="output" src="<?php echo $room;?>/room.jpg"/>
</a>
</div>
<div class="card">
<div>Camera</div>
                        <a class="mpv-m3u" href="tcp://<?php echo $row['cam'] ?>:8899">
<img id="cam" src="<?php echo $room;?>/cam.jpg"/>
</a>
</div>
<div class="card">
<div>Slides</div>
                        <a class="mpv-m3u" href="tcp://<?php echo $row['slides'] ?>:8899">
<img id="grab" src="<?php echo $room;?>/grab.jpg"/>
</a>
</div>
<div class="card monitoring-large">
<div>Audio</div>
<canvas id="chart-<?php echo $room; ?>" height="100"></canvas>
	<script>chart("<?php echo $room; ?>", document.getElementById("chart-<?php echo $room; ?>"), 1000);</script>
</div>
<h3>Cambox <?php echo $row['cam']; ?></h3>
<h3>Slidesbox <?php echo $row['slides']; ?></h3>
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


        <script>
            // When clinking on a previews make a m3u with the link so it open in the default video player  
            (function() {
                function sanitizeFileName(name) {
                    return String(name)
                        .trim()
                        .replace(/[<>:"/\\|?*\u0000-\u001F]+/g, "-")
                        .replace(/\s+/g, " ")
                        .slice(0, 120);
                }

                function makeM3U(title, url) {
                    return ["#EXTM3U", `#EXTINF:-1,${title}`, url, ""].join("\n");
                }

                document.addEventListener("click", (e) => {
                    const a = e.target.closest("a.mpv-m3u");
                    if (!a) return;

                    const streamUrl = a.getAttribute("href"); // keep original, not resolved
                    if (!streamUrl) return;

                    e.preventDefault();

                    const title = a.dataset.title || a.textContent.trim() || "stream";

                    const m3uText = makeM3U(title, streamUrl);

                    const blob = new Blob([m3uText], {
                        type: "audio/x-mpegurl;charset=utf-8",
                    });
                    const blobUrl = URL.createObjectURL(blob);

                    const dl = document.createElement("a");
                    dl.href = blobUrl;
                    dl.download = `${sanitizeFileName(title)}.m3u`;
                    document.body.appendChild(dl);
                    dl.click();
                    dl.remove();

                    setTimeout(() => URL.revokeObjectURL(blobUrl), 10_000);
                });
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
