#!/bin/bash

while :; do
	sleep 0.2
	ms213x-status status --json > /tmp/status.tmp
	if [ $? -eq 0 ]; then
		mv /tmp/status.tmp /tmp/ms213x-status
	fi
done
