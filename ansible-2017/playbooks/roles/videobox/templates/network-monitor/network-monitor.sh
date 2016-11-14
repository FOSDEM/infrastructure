#!/bin/sh

# Ugly script to test if we have received an address somehow. Assume the network
# works if that is the case.

while true; do
	# FIXME: we should support an IPv6-only network
	# FIXME: the interface should probably be configurable
	IP=$(ip addr show dev eth0 | grep 'inet '| cut -d' ' -f6)

	if [ "$IP" = "" ]; then
		service networking restart
	fi

	sleep 10s
done
