#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

ffmpeg -y -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
	-probesize 2M \
	-analyzeduration 2M \
	-i tcp://localhost:11000 \
	-threads:0 0 \
	-aspect 16:9 \
	-filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right];[0:v] format=nv12,hwupload [vout] " \
	-map '[vout]:0' \
	-c:v:0 h264_vaapi -rc_mode CBR\
	-g 30 \
	-maxrate:v:0 5000k -bufsize:v:0 8192k \
	-b:v:0 3000k \
	-qmin:v:0 1 \
	-map '[left]:1' \
	-ac:1 1 -strict -2 -c:a:0 aac -b:a:0 128k -ar:0 48000 \
	-map '[right]:2' \
	-ac 1 -strict -2 -c:a:1 aac -b:a:1 128k -ar:1 48000 \
	-f mpegts - | sproxy

