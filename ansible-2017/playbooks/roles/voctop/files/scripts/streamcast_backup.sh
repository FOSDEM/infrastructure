#!/bin/bash

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

while true; do
	ffmpeg -y \
	-i "${MULTICAST_SINK}${SOURCE_URL_PARAMETERS}" \
	-c:v copy \
	-strict -2 -c:a libfdk_aac -ab 128k \
	-flags:v +global_header  \
	-f flv \
	${STREAM_BACKUP_DESTINATION}
done
