#!/bin/bash

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

while true; do
	ffmpeg -y -i "${MULTICAST_SINK}${SOURCE_URL_PARAMETERS}" -c copy -bsf:a aac_adtstoasc -f flv ${STREAM_BACKUP_DESTINATION}
done
