#!/bin/bash

while read a
do
	if [ "$a" == "quit" ]
	then
		exit
	fi
	tmpfree=$(df --output=avail /tmp | tail -n1)
	storagefree=$(df --output=avail /srv/sreview/storage | tail -n1)
	st2=$(df --output=avail /srv/sreview/storage/1/2018-02-04 | tail -n1)
	me=$(hostname -f)

	echo begin
	echo ${me}:tmpfree:${tmpfree}k
	echo global:storagefree:${storagefree}k
	echo global:storagefree2:${st2}k
	echo end
done
