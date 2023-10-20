#!/bin/bash

status=$(cat /tmp/ms213x-status)
state=nochange #or switching or nosignal
while :; do
	sleep 0.2
	oldstatus="$status"
	status=$(cat /tmp/ms213x-status)
	if [[ $state == nochange ]] ; then
		if [[ $status == $oldstatus ]]; then
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
		if [[ $status != $oldstatus ]]; then
			waited=0
			continue
		fi 
		if [[ $waited -eq 3 ]]; then
			logger Signal stable, restarting receiver
			systemctl restart video-receiver
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
