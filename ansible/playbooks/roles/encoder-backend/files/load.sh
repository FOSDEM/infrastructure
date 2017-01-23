#!/bin/bash

while read a
do
	if [ "$a" == "quit" ]
	then
		exit
	fi
	srvfree_h=$(df --output=avail /srv/sreview/1/H | tail -n1)
	srvfree_k=$(df --output=avail /srv/sreview/1/K | tail -n1)
	srvfree_j=$(df --output=avail /srv/sreview/1/J | tail -n1)
	srvfree_aw=$(df --output=avail /srv/sreview/1/A | tail -n1)
	srvfree_u=$(df --output=avail /srv/sreview/1/U | tail -n1)
	tmpfree=$(df --output=avail /tmp | tail -n1)
	me=$(hostname -f)

	echo begin
	echo global:srvfree_h:${srvfree_h}k
	echo global:srvfree_k:${srvfree_k}k
	echo global:srvfree_j:${srvfree_j}k
	echo global:srvfree_aw:${srvfree_aw}k
	echo global:srvfree_u:${srvfree_u}k
	echo ${me}:tmpfree:${tmpfree}k
	echo end
done
