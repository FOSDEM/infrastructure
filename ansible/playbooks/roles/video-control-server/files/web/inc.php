<?php

function _e($str)
{
	global $db;

	return $db->escape($str);
}

$db = new PDO("pgsql:dbname=fosdem user=www-data");
