<?php
require_once(dirname(__FILE__)."/inc.php");
?>

<!DOCTYPE html>
<html>
<head>
    <title>Control.video.fosdem.org - overview of all streams</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        .color-red {
            background-color: red;
            color: white;
        }
        .color-yellow {
            background-color: orange;
            color: white;
        }
        .buildings {
            display: flex;
            flex-flow: row wrap;
            align-items: center;
            justify-content: center;
        }
        .buildings .checkbox-container {
            display: inline-block;
            margin: 15px;
            font-size: large;
        }
        .buildings .checkbox-container input[type=checkbox] {
            margin-left: 15px;
            margin-right: 10px;
            transform: scale(125%);
        }

        .roomlist {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-flow: row wrap;
        }

        .roomcard {
            border: 1px solid black;
        }
        .roomcard-title {
            font-weight: bold;
            font-size: large;
            text-align: center;
            border: 1px solid black;
            padding: .1em;
	}
	.roomcard > a:link, .roomcard > a:visited {
	    color: midnightblue;
            text-decoration: none;
	}
        .roomcard-body {
            display: flex;
            align-items: center;
            flex-flow: column;
        }
        .roomcard-body img {
            max-width: 9rem;
            height: auto;
        }
        .roomcard-body iframe, .roomcard-body canvas {
            max-width: 9rem;
            max-height: 4.5rem;
        }
    </style>
    <script src="chart.js"></script>
    <script src="moment.js"></script>
    <script src="chartjs-adapter-moment.js"></script>
    <script src="chartjs-plugin-annotation.js"></script>
    <script src="graph.js"></script>

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

    <script>
        function updateStatus(chart, room) {
		const data = chart.data.datasets[0].data;
            const title = document.querySelector(`#card-${room} .roomcard-title`);
            if(data == null || data.length == 0) {
                 title.classList.add('color-red');
                 return;
	    }

	    console.log(data);

	    const lastTime = moment(data.findLast(x => x[1] != null));
            const now = moment.utc();
            if(now.diff(lastTime) >= 5000) { // 5 seconds
                 title.classList.add('color-red');
                 return;
            }

            // May cause false alarms if there is no noise in the given hall
            if(data[data.length-3]['S'] <= -48) {
                 title.classList.add('color-yellow');
                 return;
            }

            title.classList.remove('color-red');
            title.classList.remove('color-yellow');
        }
    </script>
</head>
<body>

    <form class="buildings">
        <h3>Buildings:</h3>
        <div class="checkbox-container">
            <a href="?building=all">All</a>
        </div>
        <?php
        $r = $db->prepare("select distinct building from fosdem order by building");
        $r->execute();
        while ($row = $r->fetch()) {
            $checked = array_key_exists('building', $_GET) && ($_GET['building'] == 'all' || (is_array($_GET['building']) && in_array($row[0], $_GET['building']))) ? 'checked' : '';
            echo '<div class="checkbox-container">';
            echo '<input name="building[]" id="building-'.$row[0].'" type="checkbox" value="'.$row[0].'" '.$checked.'/>';
            echo '<label for="building-'.$row[0].'">'.$row[0].'</label>';
            echo '</div>';
        }
        ?>
        <input type="submit" value="Choose"/>
    </form>

    <?php
    if (empty($_GET['building']) ) {
        die(0);
    } else {
        $buildings = $_GET['building'];
        if(!is_array($buildings)) $buildings = array(strtolower($_GET['building']));
    }

    if (in_array('all', $buildings)) {
        $qw = "";
    } else {
        $buildings_str = '(' . join(',', array_map('_e', $buildings)) . ')';
        $qw = " and building IN ".$buildings_str;
    }

    $r = $db->prepare("select roomname, cam, slides, voctop from fosdem where building!='d' ".$qw." order by building, roomname");
    $r->execute();

    if (!$r) {
        die("internal error");
    }
    ?>

    <div class="roomlist">

        <?php
        while ($row = $r->fetch()) {
            echo '<div class="roomcard" id="card-'.$row[0].'">';
            echo '<a href="/vocto.php?room='.$row[0].'"><div class="roomcard-title">'.$row[0].'</div></a>';

    // Camera list
	    echo '<div class="roomcard-body">';
            echo '<a href="tcp://'.$row[1].':8899"><img src="'.$row[0].'/cam.jpg"/></a>';
            echo '<a href="tcp://'.$row[2].':8899"><img src="'.$row[0].'/grab.jpg"/></a>';
	    echo '<a href="tcp://'.$row[3].':8899"><img src="'.$row[0].'/room.jpg"/></a>';
            echo '<canvas id="chart-'.$row[0].'"></canvas>';
	    echo '<p>cam: ' . explode('.', $row[1])[0] . '<br/>';
	    echo 'sld: ' . explode('.', $row[2])[0] . '<br/>';
	    echo 'vtp: ' . explode('.', $row[3])[0] . '<br/>';
            echo '<script>chart("'.$row[0].'", document.getElementById("chart-'.$row[0].'"), 5000, updateStatus);</script>';
            echo '</div>';
    // End camera list

            echo '</div>';
        }
        ?>
    </div>
</body>
</html>
