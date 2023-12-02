<?php

$room = $_GET['room'] or die('room required');

$data = http_build_query(array(
    'db' => 'ebur',
    'q' => 'SELECT  mean(S) as S, mean(M) as M FROM "ebur" WHERE time >= now() - 5m and time <= now() and stream =~ /^'.$room.'$/ GROUP BY time(1s) fill(null)',
    'epoch' => 'ms'
));

$ch = curl_init('http://localhost:8086/query?'.$data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$curl_result = curl_exec($ch);

curl_close($ch);

$result = json_decode($curl_result, true)['results'][0]['series'][0];

$columns = $result['columns'];
$values = $result['values'];


$output = array_map(function($arr) {
    global $columns;
    return array_combine($columns, $arr);
}, $values);

echo json_encode($output);
