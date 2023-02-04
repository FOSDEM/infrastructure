#!/bin/bash

if [ -z "$1" ]; then
	echo Usage: $0 room
	exit 2
fi

cd /var/www/hls || exit 3

room="$1"

if [ $1 == mtest ] ; then
	src=tcp://mtest-vocto.video.fosdem.org:8898/
elif [ $1 == dtest ] ; then
	src=tcp://dtest-vocto.video.fosdem.org:8898/
else
	src=$(curl -s http://control.video.fosdem.org/query-room.php?room=$room)
fi

if [ -z "$src" ]; then
	# we don't exist, sleep for a while
	sleep 60
fi

if echo  $room |grep -q ^d; then
	extraaudio=""
else
	extraaudio="-map 0:a:1"
fi

ffmpeg -v error -nostdin -y -i "$src" \
	-c copy -map 0:v:0 -map 0:a:0 ${extraaudio} \
	-f tee '[f=hls:hls_flags=delete_segments+temp_file:hls_start_number_source=datetime:hls_time=2:hls_delete_threshold=10:hls_segment_filename='${room}-'%d.ts]'${room}'.m3u8|[f=segment:segment_time=1800:segment_format=mpegts:strftime=1]/var/www/dump/'${room}/${room}'-%Y%m%d%H%M%S.ts' 

