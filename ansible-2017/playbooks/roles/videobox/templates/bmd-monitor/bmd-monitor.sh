#! /bin/sh

SERVICE='bmd-streamer.service'
LOGFILE='/mnt/ssd/bmd-streamer.log'
BMDTIMEOUT=15

touch $LOGFILE

# If we catch anything new in the bmdstreamer log
while inotifywait -e modify $LOGFILE 2>>/dev/null ; do
    # Check if it's a 'no signal' event being logged

    NOSIGNAL=$(tail -n $BMDTIMEOUT $LOGFILE | grep "no signal$" | wc -l)
    STOPPEDENCODER=$(tail -n1 $LOGFILE | grep 'stopping encoder' | wc -l)

    if [ $NOSIGNAL -eq $BMDTIMEOUT ] || [ $STOPPEDENCODER -eq 1 ]; then
        service bmd-streamer stop
	sleep 10s
	#TODO notify someone
	echo 'Monitoring service attempting to restart bmd-streamer...' > $LOGFILE
	service bmd-streamer start
    fi
done
