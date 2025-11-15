#!/bin/bash

m=mixercli

$m oms USB1 1
$m oms USB2 1
$m ims PC 1
$m set-gain PC USB1 1
$m set-gain PC USB2 1
$m set-gain PC OUT1 1
$m set-gain PC OUT2 1
$m set-gain PC HP1 1
$m set-gain PC HP2 1
