#!/bin/bash

while read a
do
	if [ "$a" == "quit" ]
	then
		exit
	fi
	tmpfree=$(df --output=avail /tmp | tail -n1)
	storagefree=$(df --output=avail /srv/sreview/storage | tail -n1)
	me=$(hostname -f)

	echo begin
	echo ${me}:tmpfree:${tmpfree}k
	echo global:storage:${storagefree}k
	echo end
done
