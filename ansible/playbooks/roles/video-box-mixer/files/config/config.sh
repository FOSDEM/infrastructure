#!/bin/sh


#data=$(curl -s http://control.video.fosdem.org/query-vocto.php?voctop=$(hostname))
#
#if [ -z "$data" ] || [ "$data" == "notfound" ]; then
#	# we don't exist. wait.
#	sleep 60
#	exit
#fi
#
#room=$(echo $data | cut -d ' ' -f 1)
#cam=$(echo $data | cut -d ' ' -f 2)
#slides=$(echo $data | cut -d ' ' -f 3)
#
#SOURCE_CAM=tcp://${cam}:8899/
#SOURCE_SLIDES=tcp://${slides}:8899/
