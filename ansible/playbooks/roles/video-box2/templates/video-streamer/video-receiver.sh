#!/bin/sh

usbdev=$(lsusb -d 345f:2131 | sed 's%Bus \([0-9]*\) Device \([0-9]*\): ID 345f:2131.*$%/dev/bus/usb/\1/\2%')

if [ -z $usbdev ]; then
	echo Video board not found, exiting
	sleep 5
	exit 0
fi

/usr/bin/usb_reset "$usbdev"

adev=$(aplay -l  |grep USB3|cut -d: -f1 |cut -d' ' -f 2)
vdev=$(v4l2-ctl --list-devices |grep -A 1 USB3 |tail -n1)

/usr/bin/wait_next_second

ffmpeg -y -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
	-probesize 10M \
	-analyzeduration 10M \
	-f v4l2 -video_size 1280x720 -framerate 25 -i $vdev -itsoffset 0.064 -f alsa -sample_rate 48000 -channels 2 -i hw:$adev \
	-threads:0 0 \
	-aspect 16:9 \
	-filter_complex "[1:a]channelsplit=channel_layout=stereo[left][right]; [0:v] format=nv12,hwupload [vout]" \
	-map '[vout]' \
	-c:v:0 h264_vaapi -rc_mode CBR\
	-g 25 -x264opts "keyint=25:min-keyint=25:no-scenecut"  \
	-maxrate:v:0 2000k -bufsize:v:0 8192k \
	-b:v:0 1000k \
	-qmin:v:0 1 \
	\
	-map '[left]:1' \
	-ac 1 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-map '[right]:2' \
	-ac 1 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-y -f mpegts - | /usr/bin/sproxy

