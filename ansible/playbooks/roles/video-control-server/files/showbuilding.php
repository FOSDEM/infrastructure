<?php 

require_once(dirname(__FILE__)."/inc.php");

function blist() {
	$out .='<h1><a href="/showbuilding.php?building=all">all</a>&nbsp;';
	$r = pg_query("select distinct building from fosdem order by building");
	while ($row = pg_fetch_row($r)) {
		$out .='<a href="/showbuilding.php?building='.$row[0].'">'.$row[0].'</a>&nbsp;';
	}
	return $out.'</h1>';
}

if (empty($_GET['building']) ) {
	$building = "all";
} else {
	$building = strtolower($_GET['building']);
}

$blist = blist();


if ($building == "all") {
	$qw = "";
} else {	
	$qw = " and building = '"._e($building)."'";
}



$r = pg_query("select roomname, cam, slides, voctop from fosdem where building!='d' ".$qw);

if (!$r) {
	die("internal error");
}

$num = pg_num_rows($r);
?>
<!DOCTYPE html>
<html>
  <head>
    <title>Control.video.fosdem.org - overview of all streams</title>
    <style>
      img { 
        height: 100px;
      }
      td {
        width: 100px;
	align: center;
      }
      .room {
        float: left;
      }
    </style>
    <script>
      setInterval(function(){
        images = document.getElementsByTagName('img');
        for(var i = 0; i < images.length; i++) {
          src = images[i].src + '?';
          src = src.split('?')[0]
          images[i].src = src + '?' + Date.now()
        }

      }, 10000);
    </script>
  </head>

  <body>


<?php

$per_row = 7;
$rownum = 0;
echo "<div>";
while ($row = pg_fetch_row($r)) {
/*
       <td>
          janson<br/>
          <a href='tcp://janson-cam.local:8899'>
            <img src="janson/cam.jpg"/>
          </a>
          <br/>
          <a href='tcp://janson-slides.local:8899'>
            <img src="janson/grab.jpg"/>
          </a>
          <a href='tcp://janson-voctop.local:8899'>
            <img src="janson/room.jpg"/>
          </a>
        </td>

*/
	$rownum ++;
    	echo '<table border="1" class=room>';
	echo '<tr><td><center><a href="//control.video.fosdem.org/vocto.php?room="'.$row[0].'target="_blank">'.$row[0].'</a></center></td></tr>';
	echo '<tr><td><a href="tcp://'.$row[1].':8899"><img src="'.$row[0].'/cam.jpg"/></a></td></tr>';
	echo '<tr><td><a href="tcp://'.$row[2].':8899"><img src="'.$row[0].'/grab.jpg"/></a></td></tr>';
	echo '<tr><td><a href="tcp://'.$row[3].':8899"><img src="'.$row[0].'/room.jpg"/></a></td></tr>';
	echo "</table>\n";

}
echo "</div>";
echo "<br/>";
echo $blist;
