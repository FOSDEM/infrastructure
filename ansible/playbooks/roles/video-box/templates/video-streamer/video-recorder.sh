#!/bin/sh

# The default socket size is too small
echo 81921024 > /proc/sys/net/core/wmem_max
echo 81921024 > /proc/sys/net/core/wmem_default

echo 81921024 > /proc/sys/net/core/rmem_max
echo 81921024 > /proc/sys/net/core/rmem_default

ffmpeg -i "tcp://127.0.0.1:8899?timeout=10000000" -c copy -f mpegts {{ ssd_mount }}/video-recording/log.`date +%s`.ts
