#!/bin/bash

if [ -z "$2" ]; then
	echo Usage: $0 source room
	exit 2
fi

src="$1"
room="$2"

cvlc -I dummy "$src" vlc://quit \
	--sout='#duplicate{dst=std{access=livehttp{seglen=5,delsegs=true,numsegs=5,index=/var/www/hls/'${room}'.m3u8,index-url=https://live.fosdem.org/hls/'${room}'-########.ts},mux=ts{use-key-frames},dst=/var/www/hls/'${room}'-########.ts},dst=std{access=file,mux=ts,dst=/var/www/dump/'${room}-`date +%Y%m%d%H%M%S`'.ts},dst=nodisplay}'


#cvlc -I dummy 'tcp://[2a02:1807:0:790:f2de:f1ff:fecf:eafa]:8811' vlc://quit \
#	--sout='#duplicate{dst=std{access=livehttp{seglen=5,delsegs=true,numsegs=5,index=./stream.m3u8,index-url=http://vasil.ludost.net/hls/stream-########.ts},mux=ts{use-key-frames},dst=./stream-########.ts},dst=std{access=file,mux=ts,dst=./dump.'`date +%s`'.ts},dst=nodisplay}'
