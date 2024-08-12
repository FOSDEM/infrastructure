<?php

function _e($str)
{
	global $dbconn;

	return pg_escape_string($dbconn, $str);
}

$dbconn = pg_connect("dbname=fosdem user=www-data");
