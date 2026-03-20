#!/usr/bin/python3

# reset the macrosilicon USB 3 device before use
# after close it doesn't work without reset and having the driver patches is not going to be fast

import fcntl
import re
import subprocess
import sys

usbInfo = subprocess.check_output('lsusb -d 345f:2131', shell=True).decode("utf-8")
# Bus 002 Device 005: ID 345f:2131 MACROSILICON USB3 Video

matches = re.search("Bus (\d+) Device (\d+): ID 345f:2131", usbInfo).groups()
bus = matches[0]
device = matches[1]
srcfd = open(f'/dev/bus/usb/{bus}/{device}','wb')

USBDEVFS_RESET = 0x5514
fcntl.ioctl(srcfd.fileno(), USBDEVFS_RESET, 0)
