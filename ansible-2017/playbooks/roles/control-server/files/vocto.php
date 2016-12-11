<?php 

require_once(dirname(__FILE__)."/config.php");

if (empty($_GET['room']) ) {
	echo "<h1>Get a room.</h1><br>";
	foreach ($config as $r => $h ) {
		echo '<a href="/vocto.php?room='.$r.'">'.$r.'</a><br>';
	}
	exit();
}


$room = strtolower($_GET['room']);

if (empty($config[$room])) {
	echo "<h1>room not found.</h1><br>";
	foreach ($config as $r => $h ) {
		echo '<a href="/vocto.php?room='.$r.'">'.$r.'</a><br>';
	}
	exit();
}

$host = $config[$room];


if (empty($_GET['w']) && empty($argv[1])) {
?>
<head><title>room <?php echo $room; ?></title>
</head>
<body>

<table>
<tr>
<td>	<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="ssp-p"><input type="submit" style="height:50px" value="side-by-side presenter"></form></td>
<td>	<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="ssp-s"><input type="submit" style="height:50px;" value="side-by-side slides"></form></td>
</tr>
<tr>
<td>	<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="fs-p"><input type="submit" style="height:50px" value="fullscreen presenter"></form></td>
<td>	<form method=GET target="tgt" action="/vocto.php" style="float: left;"><input hidden name="room" value="<?php echo $room;?>"><input hidden name="w" value="fs-s"><input type="submit" style="height:50px" value="fullscreen slides"></form></td>
</tr>
<tr><td colspan=2><img id="output" src="/<?php echo $room;?>/room.jpg" width=480 height=270></td></tr>
<tr>
<td>
	<img id="cam" src="/<?php echo $room;?>/cam.jpg" width==240 height=135>
</td>
<td>
	<img id="grab" src="/<?php echo $room;?>/grab.jpg" width==240 height=135>
</td>
</tr>
<table>
<script>var img1 = document.getElementsByTagName('img')[0];var src1=img1.src;img1.addEventListener('load', function() {setTimeout(function() {img1.src=src1+'?'+Date.now()}, 1000)})</script>
<script>var img2 = document.getElementsByTagName('img')[1];var src2=img2.src;img2.addEventListener('load', function() {setTimeout(function() {img2.src=src2+'?'+Date.now()}, 1000)})</script>
<script>var img3 = document.getElementsByTagName('img')[2];var src3=img3.src;img3.addEventListener('load', function() {setTimeout(function() {img3.src=src3+'?'+Date.now()}, 1000)})</script>
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

$fp=fsockopen($host, 9999, $errno, $errstr, 30);

if (!$fp) {
	echo "$errstr ($errno)<br />\n";
	exit(1);
}

foreach ($cmd as $k => $command)  {
	fwrite($fp, $command."\n");
}
fclose($fp);
