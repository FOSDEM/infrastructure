#!/bin/sh

LOGFILE="/mnt/ssd/bmd-streamer.log"

/usr/local/bin/bmd-streamer -f /usr/lib/firmware -k 2000 -S hdmi -F 0 2>> ${LOGFILE} | ffmpeg -v error -i - -c copy -f mpegts - | /usr/local/bin/sproxy
