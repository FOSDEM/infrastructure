#!/bin/sh

# When booting the laptop via WoL, it seems the network interface is sometimes
# missing. Quick and dirty fix: reboot if the interface isn't there.

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

cat /proc/net/dev | grep "^${NETWORK_INTERFACE}" > /dev/null

if [ $? -gt 0 ]; then
	echo "not there" > /tmp/netif
else
	echo "there" > /tmp/netif
fi
