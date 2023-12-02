<?php
require_once(dirname(__FILE__)."/inc.php");
?>

<!DOCTYPE html>
<html>
<head>
    <title>Control.video.fosdem.org - overview of all streams</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
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
        async function loadData(room) {
            const response = await fetch(`query-ebur.php?room=${room}`);
            return response.json();
        }

        async function chart(room) {
            const data = await loadData(room);

            const cfg = {
                data: {
                    datasets: [
                    {
                        type: 'line',
                        label: 'M',
                        pointRadius: 0,
                        backgroundColor: 'darkgoldenrod',
                        borderColor: 'darkgoldenrod',
                        borderWidth: 1,
                        data: data,
                        parsing: { xAxisKey: 'time', yAxisKey: 'M' }
                    },
                    {
                        type: 'line',
                        label: 'S',
                        pointRadius: 0,
                        backgroundColor: 'green',
                        borderColor: 'green',
                        borderWidth: 2,
                        data: data,
                        parsing: { xAxisKey: 'time', yAxisKey: 'S' }
                    },
                    ],
                },
                options: {
                    animation: false,
                    layout: { padding: 0 },
                    plugins: {
                        filler: {},
                        annotation: { annotations: {
                            red: {
                                type: 'box',
                                yMin: -60,
                                yMax: -40,
                                backgroundColor: 'rgba(255,0,0,0.25)',
                                borderWidth: 0,
                            },
                            green: {
                                type: 'box',
                                yMin: -40,
                                yMax: -14,
                                backgroundColor: 'rgba(86, 166, 75, 0.25)',
                                borderWidth: 0,
                            },
                            yellow: {
                                type: 'box',
                                yMin: -14,
                                yMax: -0,
                                backgroundColor: 'rgba(224, 180, 0, 0.25)',
                                borderWidth: 0,
                            },
                        }},
                        legend: { display: false }
                    },
                    parsing: false,
                    scales: {
                        time:  {
                            axis: 'x',
                            type: 'time',
                            display: false,
                        },
                        S:  {
                            axis: 'y',
                            type: 'linear',
                            display: false,
                            min: -60,
                            max: 0,
                        },
                        M:  {
                            axis: 'y',
                            type: 'linear',
                            display: false,
                            min: -60,
                            max: 0,
                        },
                    },
                }
            }

            const element = document.getElementById(`chart-${room}`);

            Chart.register({id: 'annotation'});
            let chart = new Chart(element, cfg);

            setInterval(function() {
                tick(chart, room);
            }, 5000);

            return chart;
        }


        async function tick(roomChart, room) {
            let data = await loadData(room);

            roomChart.data.datasets[0].data = data;
            roomChart.data.datasets[1].data = data;

            roomChart.update();
        }
    </script>
</head>
<body>

    <form class="buildings">
        <h2>Buildings:</h2>
        <div class="checkbox-container">
            <a href="?building=all">All</a>
        </div>
        <?php
        $r = pg_query("select distinct building from fosdem order by building");
        while ($row = pg_fetch_row($r)) {
            $checked = $_GET['building'] == 'all' || (is_array($_GET['building']) && in_array($row[0], $_GET['building'])) ? 'checked' : '';
            echo '<div class="checkbox-container">';
            echo '<input name="building[]" id="building-'.$row[0].'" type="checkbox" value="'.$row[0].'" '.$checked.'/>';
            echo '<label for="building-'.$row[0].'">'.$row[0].'</label>';
            echo '</div>';
        }
        ?>
        <input type="submit" value="Choose"/>
    </form>
    <br/><br/><br/>

    <?php
    if (empty($_GET['building']) ) {
        die(0);
    } else {
        $buildings = $_GET['building'];
        if(!is_array($buildings)) $buildings = array(strtolower($_GET['building']));
    }

    function pgstr($x) {
        return "'" . _e($x) . "'";
    }

    if (in_array('all', $buildings)) {
        $qw = "";
    } else {
        $buildings_str = '(' . join(',', array_map('pgstr', $buildings)) . ')';
        $qw = " and building IN ".$buildings_str;
    }

    $r = pg_query("select roomname, cam, slides, voctop from fosdem where building!='d' ".$qw);

    if (!$r) {
        die("internal error");
    }
    ?>

    <div class="roomlist">

        <?php
        while ($row = pg_fetch_row($r)) {
            echo '<div class="roomcard">';
            echo '<div class="roomcard-title">'.$row[0].'</div>';

    // Camera list
            echo '<div class="roomcard-body">';
            echo '<a href="tcp://'.$row[1].':8899"><img src="'.$row[0].'/cam.jpg"/></a>';
            echo '<a href="tcp://'.$row[2].':8899"><img src="'.$row[0].'/grab.jpg"/></a>';
            echo '<a href="tcp://'.$row[3].':8899"><img src="'.$row[0].'/room.jpg"/></a>';
            echo '<canvas id="chart-'.$row[0].'"></canvas>';
            echo '<script>chart("'.$row[0].'")</script>';
            echo '</div>';
    // End camera list

            echo '</div>';
        }
        ?>
    </div>
</body>
</html>
