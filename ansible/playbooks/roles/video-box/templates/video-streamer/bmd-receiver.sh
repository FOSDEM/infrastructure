#!/bin/sh

LOGFILE="/mnt/ssd/bmd-streamer.log"
STREAM_OPTIONS="{{ video_streamer_ffmpeg_options }}"

# The default socket size is too small
echo 81921024 > /proc/sys/net/core/wmem_max
echo 81921024 > /proc/sys/net/core/wmem_default

echo 81921024 > /proc/sys/net/core/rmem_max
echo 81921024 > /proc/sys/net/core/rmem_default

/usr/local/bin/bmd-streamer -f /usr/lib/firmware -k 2000 -S hdmi -F 0 2>> ${LOGFILE} | ffmpeg -i - -c copy -f tee -map 0:v -map 0:a '[f=mpegts]'"udp://127.0.0.1:4000?${STREAM_OPTIONS}"'|[f=mpegts]'"udp://127.0.0.1:4001?${STREAM_OPTIONS}"
