#!/bin/sh

while true; do
	ffmpeg -v error -y -i "$1"'?timeout=1000000' -map 0 -c copy -f mpegts $2`date +%s`.ts
done
