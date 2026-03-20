#!/bin/bash

function getstatus {
	cat /sys/class/drm/*/edid | md5sum |cut -d ' ' -f 1
}

res=$(getstatus)
state=nochange #or switching or nosignal
while :; do
	sleep 0.5
	oldres="$res"
	res=$(getstatus)
	if [[ $state == nochange ]] ; then
		if [[ $res == $oldres ]]; then
			continue
		else
			state=changing
			waited=0
			continue
		fi
	elif [[ $state == changing ]]; then
		waited=$(($waited+1))
		if [[ $res != $oldres ]]; then
			waited=0
			continue
		fi 
		if [[ $waited -eq 3 ]]; then
			logger Display signal stable, restarting receiver
			systemctl restart video-receiver
			sleep 10
			state=nochange
			waited=0
		fi
	elif [[ $state == nosignal ]]; then
		state=changing
		waited=0
		continue
	fi

done
