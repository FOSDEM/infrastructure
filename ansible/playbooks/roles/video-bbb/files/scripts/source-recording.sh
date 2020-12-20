#!/bin/bash

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh
previous_event_id=$(</tmp/previous_event_id)

# TODO:
# Set vocto output to fullscreen intermediate loop
# Stop previous vocto recording ingest
systemctl stop vocto-source-recording@$previous_event_id.service
# Set previous event id to current event id
echo $1 > /tmp/previous_event_id

# Set the main input to the mixer to the prerecorded video
{ echo "set_video_a cam1"; } | telnet localhost 9999

# Ingest prerecorded video into vocto
ffmpeg -re -y -nostdin \
	-i "${SOURCE_RECORDING_DIR}/${1}.mp4" \
	-ac 2 \
	-filter_complex "
		[0:v] scale=$WIDTH:$HEIGHT,fps=$FRAMERATE,setdar=16/9,setsar=1 [v] ;
		[0:a] aresample=$AUDIORATE [a]
	" \
	-map "[v]" -map "[a]" \
	-pix_fmt yuv420p \
	-c:v rawvideo \
	-c:a pcm_s16le \
	-f matroska \
	tcp://localhost:10000

# Set the main input to the mixer to the q&a video

{ echo "set_video_a grabber"; } | telnet localhost 9999

# Ingest q&a video stream into vocto
# Do not set timeout. This will make ffmpeg think you want to set up an rtmp server for listening.
ffmpeg -y -nostdin \
	-i "rtmp://localhost/stream/${1}" \
	-ac 2 \
	-filter_complex "
		[0:v] scale=$WIDTH:$HEIGHT,fps=$FRAMERATE,setdar=16/9,setsar=1 [v] ;
		[0:a] aresample=$AUDIORATE [a]
	" \
	-map "[v]" -map "[a]" \
	-pix_fmt yuv420p \
	-c:v rawvideo \
	-c:a pcm_s16le \
	-f matroska \
	tcp://localhost:10000
