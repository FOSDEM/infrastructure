#!/bin/bash

status=$(cat /tmp/ms213x-status)
res=$(echo "$status" | jq -r '(.width*1000/.height)|floor |if . > 2000 then . * 2 else . end')
state=nochange #or switching or nosignal
while :; do
	sleep 0.2
	oldres="$res"
	status=$(cat /tmp/ms213x-status)
	res=$(echo "$status" | jq -r '(.width*1000/.height)|floor |if . > 2000 then . * 2 else . end')
	if [[ $state == nochange ]] ; then
		if [[ $res == $oldres ]]; then
			continue
		else
			if [ $(echo "$status" | jq -r .signal) == "no" ]; then
				state=nosignal
				logger Signal lost
				continue
			else
				state=changing
				waited=0
				continue
			fi
		fi
	elif [[ $state == changing ]]; then
		waited=$(($waited+1))
		if [[ $res != $oldres ]]; then
			waited=0
			continue
		fi 
		if [[ $waited -eq 3 ]]; then
			logger Signal stable, restarting receiver
			systemctl restart video-receiver
			sleep 10
			state=nochange
		fi
	elif [[ $state == nosignal ]]; then
		if [ $(echo "$status" | jq -r .signal) == "yes" ]; then
			state=changing
			waited=0
			continue
		fi
	fi

done
