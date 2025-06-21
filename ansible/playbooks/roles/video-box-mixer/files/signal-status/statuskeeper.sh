#!/bin/bash

usbpos=4-2
upath=/sys/bus/usb/devices/$usbpos
rdev=/dev/$(basename $(find $upath/*/*/hidraw -mindepth 1 -maxdepth 1 | sort |head -n1)) 

ms213x-status status --json --loop 1000 --filename /tmp/ms213x-status --raw-path=$rdev --region=bertold
