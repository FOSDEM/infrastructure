#!/bin/sh

while true; do
	ffmpeg -y -i ${MULTICAST_SINK} -f mpegts ${STREAM_BACKUP_DESTINATION}
done
