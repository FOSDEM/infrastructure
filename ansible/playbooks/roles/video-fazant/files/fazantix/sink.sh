#!/bin/bash

teensy=$(arecord -l  |grep -E 'Audio Board|FOSDEM' |cut -d: -f1 |cut -d' ' -f 2)

ffmpeg -y -v error -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
        -probesize 2M \
        -analyzeduration 2M \
        -f rawvideo -video_size 1920x1080 -pixel_format rgba -framerate 30 -i - \
	-f alsa -sample_rate 48000 -channels 2 -itsoffset 0.3 -i hw:$teensy \
        -aspect 16:9 \
        -filter_complex "[0:v] format=nv12,hwupload [vhw]" \
        -map '[vhw]:0' -map 1\
        -c:v:0 h264_vaapi -rc_mode CBR\
        -g 30 \
        -maxrate:v:0 8000k -bufsize:v:0 8192k \
        -b:v:0 5000k \
	-ac 2 -strict -2 -c:a aac -b:a 128k -ar 48000 \
        -f mpegts - | sproxy 2

