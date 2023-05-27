#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

#
# The video encoding needs to be kept in sync with the review system,
# otherwise things like
# https://twitter.com/jlecour/status/1229381883680694273 happen.
#
# Either update playbooks/roles/encoder-common/templates/config.j2
# (extra_profiles variable, FOSDEM key) or talk to Wouter if you can't
# figure it out. Thanks!
#
ffmpeg -v error -y -nostdin \
	-probesize 10M \
	-analyzeduration 10M \
	-i tcp://localhost:11000 \
	-threads:0 0 \
	-aspect 16:9 \
	-c:v libx264 \
	-g 45 \
	-maxrate:v:0 2000k -bufsize:v:0 8192k \
	-pix_fmt:0 yuv420p -profile:v:0 main -b:v 512k \
	-preset:v:0 veryfast \
	\
	-ac 2 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-map 0:v \
	-map 0:a \
	-y -f mpegts - | /usr/bin/sproxy
