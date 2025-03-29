#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh


usbdev=$(lsusb -d 345f:2131 | sed 's%Bus \([0-9]*\) Device \([0-9]*\): ID 345f:2131.*$%/dev/bus/usb/\1/\2%')

if [ -z $usbdev ]; then
        echo Video board not found, exiting
        sleep 5
        exit 0
fi

/usr/bin/usb_reset "$usbdev"

sleep 5
adev=$(arecord -l  |grep -E 'USB3|Hagibis|HC-336' |cut -d: -f1 |cut -d' ' -f 2)
vdev=$(v4l2-ctl --list-devices |grep -EA 1 'USB3|Hagibis|HC-336' |tail -n1)

height=$(cat /tmp/ms213x-status | jq -r ${WIDTH}'/( (.width/.height)|if . > 2 then . / 2 else . end)|floor')

/usr/bin/wait_next_second

taskset -c 3 ffmpeg -y -nostdin -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device /dev/dri/renderD128 \
	-analyzeduration 3M \
	-f v4l2 -video_size ${WIDTH}x${height} -framerate 30 -i $vdev \
	-itsoffset 0.064 -f alsa -sample_rate 48000 -channels 2 -i hw:$adev \
	-ac 2 \
	-filter_complex "
		[0:v] scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=decrease,pad=${WIDTH}:${HEIGHT}:-1:-1:color=black,fps=$FRAMERATE,setdar=16/9,setsar=1 [v] ;
		[1:a] aresample=$AUDIORATE [a]
	" \
	-map "[v]" -map "[a]" \
	-pix_fmt yuv420p \
	-c:v rawvideo \
	-c:a pcm_s16le \
	-f matroska \
	tcp://localhost:10001
