#!/bin/bash

if [ -z "$2" ]; then
	echo Usage: $0 source room
	exit 2
fi

src="$1"
room="$2"

ffmpeg -v error -nostdin -y -i "$src" \
	-c copy -map 0:v:0 -map 0:a:0 -map 0:a:1 \
	-f tee '[f=hls:hls_flags=delete_segments+temp_file:hls_start_number_source=datetime:hls_time=5:hls_delete_threshold=5]'${room}'.m3u8|[f=segment:segment_time=1800:segment_format=mpegts:strftime=1]/var/www/dump/'${room}/${room}'-%Y%m%d%H%M%S.ts' 

