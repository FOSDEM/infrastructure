#!/bin/sh

usbdev=$(lsusb -d 345f:2131 | sed 's%Bus \([0-9]*\) Device \([0-9]*\): ID 345f:2131.*$%/dev/bus/usb/\1/\2%')

if [ -z $usbdev ]; then
	echo Video board not found, exiting
	sleep 5
	exit 0
fi

/usr/bin/usb_reset "$usbdev"

sleep 5
adev=$(arecord -l  |grep -E 'USB3|Hagibis|HC-336' |cut -d: -f1 |cut -d' ' -f 2)
#teensy=$(arecord -l  |grep -E 'Audio Board|FOSDEM' |cut -d: -f1 |cut -d' ' -f 2)
vdev=$(v4l2-ctl --list-devices |grep -EA 1 'USB3|Hagibis|HC-336' |tail -n1)

height=$(cat /tmp/ms213x-status | jq -r '1920/( (.width/.height)|if . > 2 then . / 2 else . end)|floor')
/usr/bin/wait_next_second

LD_PRELOAD=/usr/lib/cursor_disable.so taskset -c 2 ffmpeg -y -v verbose -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
	-fflags nobuffer -flags low_delay -avioflags direct \
	-probesize 32 \
	-analyzeduration 0 \
	-f v4l2 -video_size 1920x${height} -framerate 30 -i $vdev \
        -itsoffset 0.064 -f alsa -sample_rate 48000 -channels 2 -i hw:$adev \
	-threads:0 0 \
	-aspect 16:9 \
	-filter_complex "[1:a] volume=volume=2dB [ain]; [0:v] scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black [vscaled]; [vscaled] split [vgpu][vprepdisplay]; [vprepdisplay] format=yuv420p[vdisplay]; [vgpu] format=nv12,hwupload [vout]" \
	-map '[vout]:0' \
	-c:v:0 h264_vaapi -rc_mode CBR\
	-g 30  \
	-maxrate:v:0 5000k -bufsize:v:0 8192k \
	-b:v:0 3000k \
	-qmin:v:0 1 \
	-fps_mode cfr \
	-map '[ain]:0' \
	-ac 2 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-map '[vdisplay]:v:1' \
	-c:v:1 wrapped_avframe \
	-f tee "[select=\'v:0,a:0\':f=mpegts]pipe:1|[select=\'v:1\':f=opengl]/dev/null" | /usr/bin/sproxy

