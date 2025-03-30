#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

usbport=3:5

usbdev=$(lsusb -s $usbport | sed 's%Bus \([0-9]*\) Device \([0-9]*\): ID '$usbid'.*$%/dev/bus/usb/\1/\2%')
usbdevname=$(lsusb -s $usbport |cut -d ' ' -f 7- )


mixercli -s  set-gain IN2 USB1 1
mixercli -s  set-gain IN2 USB2 1
mixercli -s  unmute IN2 USB1
mixercli -s  unmute IN2 USB2
mixercli -s  ims IN2 1
mixercli -s  oms USB1 1
mixercli -s  oms USB2 1

#/usr/bin/usb_reset "$usbdev"
#
#sleep 5
#
camres=1280x720
vdev=$(v4l2-ctl --list-devices |grep -EA 1 "Camera|eMeet|UHD" |tail -n1)
if [ -z "$vdev" ]; then
	vdev=$(v4l2-ctl --list-devices |grep -EA 1 "Brio" |tail -n1)
	camres=640x360
fi
adev=$(arecord -l  |grep -E 'Audio Board' |cut -d: -f1 |cut -d' ' -f 2)

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
