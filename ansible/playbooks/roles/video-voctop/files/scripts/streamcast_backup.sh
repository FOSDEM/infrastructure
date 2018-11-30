#!/bin/bash

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

while true; do
	ffmpeg -y \
	-i "tcp://localhost:8899" \
	-c:v copy \
	-strict -2 -c:a aac -ab 128k \
	-flags:v +global_header  \
	-field_order progressive \
	-f flv \
	${STREAM_BACKUP_DESTINATION}
done
