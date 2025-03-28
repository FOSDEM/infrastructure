<?php

function _e($str)
{
	global $db;

	return $db->quote($str);
}

$db = new PDO("pgsql:dbname=fosdem user=www-data");
