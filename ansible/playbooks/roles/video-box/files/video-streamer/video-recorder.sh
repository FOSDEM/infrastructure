#!/bin/sh

ffmpeg -v error -i "tcp://127.0.0.1:8899?timeout=10000000" -c copy -f mpegts /home/video-recording/log.`date +%s`.ts
