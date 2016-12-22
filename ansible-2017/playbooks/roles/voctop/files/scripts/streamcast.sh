#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

while true; do
	ffmpeg -y -flags +global_header -bsf:a aac_adtstoasc -i "${MULTICAST_SINK}${SOURCE_URL_PARAMETERS}" -c copy -f flv ${STREAM_DESTINATION}
done
