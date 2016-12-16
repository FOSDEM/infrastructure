#!/bin/sh

while true; do
	ffmpeg -y -i $1 -f flv $2
done
