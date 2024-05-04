#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

/usr/bin/wait_next_second

ffmpeg -y -nostdin -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
	-timeout 3000000 \
	-analyzeduration 3M \
	-i "${SOURCE_SLIDES}" \
	-ac 3 \
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
