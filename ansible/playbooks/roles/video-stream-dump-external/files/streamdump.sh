#!/bin/sh

while true; do
	ffmpeg -v error -y -i "$1"'?timeout=1000000' -c copy $2`date +%s`.ts
done
