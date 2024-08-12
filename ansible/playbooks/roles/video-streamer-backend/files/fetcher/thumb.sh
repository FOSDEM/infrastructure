#!/bin/bash

if [ -z "$1" ]; then
	echo Usage: $0 room
	exit 2
fi

cd /var/www/hls || exit 3

room="$1"

while :; do
	ffmpeg -v error -y -i `ls -t ${room}-1080p-*ts|head -n1` -update 1 -frames:v 1 ${room}-preview.jpg
	sleep 10
done
