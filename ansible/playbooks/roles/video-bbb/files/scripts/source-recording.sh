#!/bin/bash

## file takes event id from penta of video as input

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh
. ${confdir}/streamkeysalt.sh
previous_event_id=$(</tmp/previous_event_id)

STREAMKEY=$(echo -n $1.$SALT | sha256sum| cut -d' ' -f1)

# Stop previous vocto recording ingest if it's not same as the current one
if ! [ "previous_event_id" = $1 ]; then 
	systemctl stop vocto-source-recording@$previous_event_id.service
fi
# Set previous event id to current event id
echo $1 > /tmp/previous_event_id

# preview slide with talk title, etc.
{ echo "set_audio cam1"; } | nc -q0 localhost 9999
{ echo "set_videos_and_composite grabber cam1 fullscreen"; } | nc -q0 localhost 9999

sleep 30

# Set the main input to the mixer to the prerecorded video
{ echo "set_videos_and_composite cam1 grabber fullscreen"; } | nc -q0 localhost 9999

# Ingest prerecorded video into vocto
ffmpeg -re -y -nostdin \
	-i "${RECORDING_DIRECTORY}/${1}.mp4" \
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

# Play the interroll slide
ffmpeg -re -y -nostdin \
	-i "${confdir}/interroll.mp4" \
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

# Ingest q&a video stream into vocto
# Do not set timeout. This will make ffmpeg think you want to set up an rtmp server for listening.
# Use rw_timeout instead.
now=$(date +%s)
endtime=$(cat /opt/config/endtimes/${1})
let runtime=${endtime}-${now}-40
# mark made me write the line below :P
next=`systemctl list-timers|grep recording@|grep -v ^n/a|sed -e 's/.*\@\([0-9].*\)\.service/\1/g'|uniq |grep -A1 ${1}|tail -n1`
if [ -f /opt/config/preroll${next}.raw ]; then
	slide=/opt/config/preroll${next}.raw
else
	slide=/opt/config/background.raw
fi
(sleep 1; cp ${slide} /opt/config/slide.raw) &
if [ $runtime -gt 1 ]; then

	ffmpeg -y -nostdin \
		-rw_timeout 3000000 -t ${runtime} \
		-i "rtmp://localhost/stream/${STREAMKEY}" \
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

fi
{ echo "set_audio grabber"; } | nc -q0 localhost 9999
{ echo "set_videos_and_composite grabber cam1 fullscreen"; } | nc -q0 localhost 9999
