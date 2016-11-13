#!/bin/sh

# The default socket size is too small
echo 81921024 > /proc/sys/net/core/wmem_max
echo 81921024 > /proc/sys/net/core/wmem_default

echo 81921024 > /proc/sys/net/core/rmem_max
echo 81921024 > /proc/sys/net/core/rmem_default

/usr/local/bin/bmd-streamer -f /usr/lib/firmware -k 1000 -S hdmi -F 0 2>> /mnt/ssd/bmdstreamer.log | ffmpeg -i - -c copy -f mpegts '{{ bmd_streamer_destination }}&{{ bmd_streamer_ffmpeg_options }}'
