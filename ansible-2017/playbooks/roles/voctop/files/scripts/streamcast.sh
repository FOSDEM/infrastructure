#!/bin/sh

while true; do
	ffmpeg -y -i $1 -f mpegts $2
done
