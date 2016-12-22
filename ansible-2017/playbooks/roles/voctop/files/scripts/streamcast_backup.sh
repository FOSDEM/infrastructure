#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

while true; do
	ffmpeg -y -i ${MULTICAST_SINK} -c copy -f flv ${STREAM_BACKUP_DESTINATION}
done
