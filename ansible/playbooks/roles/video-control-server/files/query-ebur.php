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

$results = json_decode($curl_result, true)['results'][0];
$result = array_key_exists('series', $results) && $results['series'] != null ? $results['series'][0] : [];

$columns = array_key_exists('columns', $result) ? $result['columns'] : [];
$values = array_key_exists('values', $result) ? $result['values'] : [];


// cap silence to -50
foreach($values as &$entry) {
    if($entry[1] != null) $entry[1] = max($entry[1], -50);
    if($entry[2] != null) $entry[2] = max($entry[2], -50);
}
unset($entry);

$output = array_map(function($arr) {
    global $columns;
    return array_combine($columns, $arr);
}, $values);

echo json_encode($output);
