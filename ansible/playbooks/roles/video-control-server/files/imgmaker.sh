#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 room"
	exit 2
fi
cd /var/www/html

ROOM=$1
HOST=$(psql -A -t -q fosdem -c "select voctop from fosdem where roomname='$ROOM'")

if [ -z "$HOST" ]; then
	# we have no voctop for this room, do not spin
	sleep 60
	exit 0
fi

t=`mktemp`
rm -f ${t} ${t}.jpg

ffmpeg=`which ffmpeg`
if ! [ $? -eq 0 ]; then
	echo No ffmpeg/avconv found.
	exit 3
fi


function ff_fetch {
	# $0 host port file
	$ffmpeg -v quiet -y -i tcp://"$1":"$2"'?timeout=1000000' -map 0:v -s 320x180 -q 5 -an -vframes 1 "${t}".jpg && mv ${t}.jpg $3
}

mkdir -p ${ROOM}

# exit after this many times to reload voctop
times=30
i=0

while /bin/true; do
	let i=$i+1
	if [ $i -gt $times ]; then
		exit 0
	fi
	ff_fetch $HOST 11000 ${ROOM}/room.jpg
	ff_fetch $HOST 13000 ${ROOM}/cam.jpg
	ff_fetch $HOST 13001 ${ROOM}/grab.jpg
	sleep 1
done
