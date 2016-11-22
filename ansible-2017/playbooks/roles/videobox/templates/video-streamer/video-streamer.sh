#!/bin/sh

LOGFILE='/mnt/ssd/bmd-streamer.log'
STREAM_DESTINATION="{{ video_streamer_destination }}"
STREAM_OPTIONS="{{ video_streamer_destination_ffmpeg_options }}"

# The default socket size is too small
echo 81921024 > /proc/sys/net/core/wmem_max
echo 81921024 > /proc/sys/net/core/wmem_default

echo 81921024 > /proc/sys/net/core/rmem_max
echo 81921024 > /proc/sys/net/core/rmem_default

/usr/local/bin/bmd-streamer -f /usr/lib/firmware -k 1000 -S hdmi -F 0 2>> ${LOGFILE} | ffmpeg -i - -c copy -f mpegts "${STREAM_DESTINATION}&${STREAM_OPTIONS}'
