#! /bin/sh

SERVICE='bmd-streamer.service'
LOGFILE='/mnt/ssd/bmd-streamer.log'

touch $LOGFILE

# If we catch anything new in the bmdstreamer log
while inotifywait -e modify $LOGFILE; do
    # Check if it's a 'no signal' event being logged
    if tail -n1 $LOGFILE | grep 'stopping encoder'; then
        service bmdstreamer stop
	sleep 10s
	#TODO notify someone
	echo 'Monitoring service attempting to restart bmd-streamer...' > $LOGFILE
	service bmdstreamer start
    fi
done
