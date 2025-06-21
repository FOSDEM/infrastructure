#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

mixercli -s  set-gain IN2 USB1 1
mixercli -s  set-gain IN2 USB2 1
mixercli -s  unmute IN2 USB1
mixercli -s  unmute IN2 USB2
mixercli -s  ims IN2 1
mixercli -s  oms USB1 1
mixercli -s  oms USB2 1

usbpos=4-1
camres=1920x1080
upath=/sys/bus/usb/devices/$usbpos
vdev=/dev/$(basename $(find $upath/*/video4linux -mindepth 1 -maxdepth 1 | sort |head -n1))
#adev=$(basename $(find $upath/*/sound -mindepth 1 -maxdepth 1 | sort |tail -n1|sed s/card//))
adev=$(arecord -l  |grep -E 'Audio Board' |cut -d: -f1 |cut -d' ' -f 2)
. $upath/uevent
/usr/bin/usb_reset "/dev/bus/usb/$BUSNUM/$DEVNUM"
sleep 5

/usr/bin/wait_next_second

ffmpeg -y -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel \
	-analyzeduration 3M \
	-f v4l2 -video_size ${camres} -framerate 30 -i ${vdev} \
	-f alsa -sample_rate 48000 -channels 2 -i hw:${adev} \
	-ac 2 \
	-filter_complex "
		[0:v] scale=$WIDTH:$HEIGHT,fps=$FRAMERATE,setdar=16/9,setsar=1 [v] ;
		[1:a] aresample=$AUDIORATE [a]
	" \
	-map "[v]" -map "[a]" \
	-pix_fmt yuv420p \
	-c:v rawvideo \
	-c:a pcm_s16le \
	-f matroska \
	tcp://localhost:10000
