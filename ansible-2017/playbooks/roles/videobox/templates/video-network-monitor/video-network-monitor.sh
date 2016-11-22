#!/bin/sh

# Ugly script to test if we have received an address somehow. Assume the network
# works if that is the case.

while true; do
	# FIXME: we should support an IPv6-only network
	IP=$(ip addr show dev {{ network_device }} | grep 'inet '| cut -d' ' -f6)

	if [ "$IP" = "" ]; then
		service networking restart
	fi

	sleep 10s
done
