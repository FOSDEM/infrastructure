#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

ffmpeg -y -nostdin -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
	-i "${SOURCE_SLIDES}" \
	-ac 2 \
	-filter_complex "
		[0:v]  scale_vaapi=w=$WIDTH:h=$HEIGHT  [v2]; [v2] hwdownload,format=nv12,format=yuv420p [v1]; [v1] scale=$WIDTH:$HEIGHT,fps=$FRAMERATE,setdar=16/9,setsar=1 [v] ;
		[0:a] aresample=$AUDIORATE [a]
	" \
	-map "[v]" -map "[a]" \
	-pix_fmt yuv420p \
	-c:v rawvideo \
	-c:a pcm_s16le \
	-f matroska \
	tcp://localhost:10001
