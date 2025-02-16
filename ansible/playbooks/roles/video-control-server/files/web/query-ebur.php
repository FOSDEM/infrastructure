<?php


function cap($val) {
	return max($val, -50);
}

$room = $_GET['room'] or die('room required');
$lastts = isset($_GET['time']) ? $_GET['time'] * 1000 * 1000: 'now() - 5m';

$data = http_build_query(array(
    'db' => 'ebur',
    'q' => 'SELECT mean(S) as S, mean(M) as M FROM "ebur2" WHERE time >= ' . $lastts . ' and time <= now() and stream =~ /^'.$room.'$/ GROUP BY time(1s), chan fill(null)',
    'epoch' => 'ms'
));

$ch = curl_init('http://185.175.218.112:8086/query?'.$data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$curl_result = curl_exec($ch);

curl_close($ch);

$results = json_decode($curl_result, true)['results'][0];

//actual serises here.
$series = ['l' => [], 'r' => []];

if (!isset($results['series'])) {
	echo json_encode([]);
	die();
}

foreach($results['series'] as $k => $data) {
	foreach (array_slice($data['values'], 0, -1) as $dataVal) {
		[$t, $s, $m] = $dataVal;
		$series[$k === 0 ? 'l' : 'r'][] = ['time' => $t, 'S' => cap($s), 'M' => cap($m)];
	}
}

echo json_encode($series);
