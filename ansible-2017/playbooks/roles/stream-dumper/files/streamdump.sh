#!/bin/sh

while true; do
	ffmpeg -y -i $1 -c copy $2`date +%s`.ts
done
