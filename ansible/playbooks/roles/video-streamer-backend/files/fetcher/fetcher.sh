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

#
# The video encoding needs to be kept in sync with the review system,
# otherwise things like
# https://twitter.com/jlecour/status/1229381883680694273 happen.
#
# Either update playbooks/roles/encoder-common/templates/config.j2
# (extra_profiles variable, FOSDEM key) or talk to Wouter V. if you can't
# figure it out. Thanks!
#

if echo  $room |grep -q ^d; then
#	ffmpeg -nostdin -y -i "$src" \
#		-f lavfi -i anullsrc=channel_layout=mono:sample_rate=48000  -loop 1 -shortest \
#		-c:v:0 copy -c:a:0 copy -map 0:v:0 -map 0:a:0 -map 1:a:0 -c:a:1 aac -b:a:1 128k \
#		-f tee '[f=hls:hls_flags=delete_segments+temp_file:hls_start_number_source=datetime:hls_time=2:hls_delete_threshold=10:hls_segment_filename='${room}-'%d.ts]'${room}'.m3u8|[f=segment:segment_time=1800:segment_format=mpegts:strftime=1]/var/www/dump/'${room}/${room}'-%Y%m%d%H%M%S.ts' 
		echo Remote rooms not supported
		sleep 60
		exit 1
else
	ffmpeg -v error -nostdin -y -i "$src" \
		-c copy -map 0:v:0 -map 0:a:0 -map 0:a:1 -map 0:a:2 -map 0:v:1 \
		-f tee "[select=\'v:0,v:1,a:0,a:1\':f=hls:hls_flags=delete_segments+temp_file:hls_start_number_source=datetime:hls_time=2:hls_delete_threshold=10:var_stream_map=\'v:0,a:0,name:1080p v:1,a:1,name:480p\':hls_segment_filename=${room}-%v-%d.ts]${room}-%v.m3u8|[select=\'v:0,a:0,a:2\':f=segment:segment_time=1800:segment_format=mpegts:strftime=1]/var/www/dump/${room}/${room}-%Y%m%d%H%M%S.ts"
fi

