#!/bin/sh

# Ugly script to test if we have received an address somehow. Assume the network
# works if that is the case.

while true; do
	sleep 15s

	# FIXME: we should support an IPv6-only network
	IP=$(ip addr show dev {{ network_device }} | grep 'inet '| cut -d' ' -f6)

	if [ "$IP" = "" ]; then
		systemctl stop ifup@{{ network_device }}.service
		systemctl start ifup@{{ network_device }}s.service
	fi
done
