#!/bin/sh

# When booting the laptop via WoL, it seems the network interface is sometimes
# missing. Quick and dirty fix: reboot if we have less than two interfaces.

interfaces=`/sbin/ip a | grep -v "^\s" | wc -l`

if [ $interfaces -lt 2 ]; then
	/sbin/reboot
fi
