#!/bin/sh

STREAM_DESTINATION="{{ video_streamer_destination }}"
STREAM_OPTIONS="{{ video_streamer_ffmpeg_options }}"

# The default socket size is too small
echo 81921024 > /proc/sys/net/core/wmem_max
echo 81921024 > /proc/sys/net/core/wmem_default

echo 81921024 > /proc/sys/net/core/rmem_max
echo 81921024 > /proc/sys/net/core/rmem_default

ffmpeg -i "udp://127.0.0.1:4001?${STREAM_OPTIONS}&timeout=10000000" -c copy -f mpegts "${STREAM_DESTINATION}?${STREAM_OPTIONS}&pkt_size=1000"
