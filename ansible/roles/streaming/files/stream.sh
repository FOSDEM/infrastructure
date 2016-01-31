#!/bin/bash

hName=`hostname`
fileName="/ssd/`ls -tr1 /ssd/ | grep time -A 1000 | tail -n 1`"
if [[ "$fileName" == "" ]]; then
  fileName="/ssd/`ls -tr1 /ssd/ | grep \.ts | tail -n 1`"
fi
seek=`avprobe $fileName |& grep Duration | cut -d " " -f 4 | cut -d "," -f 1`
avconv -ss $seek -re -i $fileName -c copy -f flv rtmp://stream-a.fosdem.org/fosdemmagie/fosdem+$hName
touch /ssd/time
