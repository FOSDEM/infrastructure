#!/bin/sh

LOGFILE="/mnt/ssd/bmd-streamer.log"

# The default socket size is too small
echo 81921024 > /proc/sys/net/core/wmem_max
echo 81921024 > /proc/sys/net/core/wmem_default

echo 81921024 > /proc/sys/net/core/rmem_max
echo 81921024 > /proc/sys/net/core/rmem_default

/usr/local/bin/bmd-streamer -f /usr/lib/firmware -k 2000 -S hdmi -F 0 2>> ${LOGFILE} | ffmpeg -v error -i - -c copy -f mpegts - | /usr/local/bin/sproxy
