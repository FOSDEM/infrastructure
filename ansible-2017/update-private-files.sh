#!/bin/sh

if [ -z $1 ]; then
	echo "please tell me where I can find the private files."
	exit 1
fi

echo -n "copying private files from ${1}... "

cp $1/bmd-firmware/bmd-atemtvstudio.bin playbooks/roles/videobox/files/bmd/bmd-atemtvstudio.bin
cp $1/bmd-firmware/bmd-h264prorecorder.bin playbooks/roles/videobox/files/bmd/bmd-h264prorecorder.bin
cp $1/certificates/stream.fosdem.org.key playbooks/roles/streamer-frontend/files/nginx/certificate/stream.fosdem.org.key
cp $1/certificates/stream.fosdem.org.crt playbooks/roles/streamer-frontend/files/nginx/certificate/stream.fosdem.org.crt
cp $1/certificates/live.fosdem.org.key playbooks/roles/web-frontend/files/nginx/certificate/live.fosdem.org.key
cp $1/certificates/live.fosdem.org.crt playbooks/roles/web-frontend/files/nginx/certificate/live.fosdem.org.crt
cp $1/certificates/control.video.fosdem.org.key playbooks/roles/control-server/files/nginx/certificate/control.video.fosdem.org.key
cp $1/certificates/control.video.fosdem.org.crt playbooks/roles/control-server/files/nginx/certificate/control.video.fosdem.org.crt
cp $1/sreview/config.pl playbooks/roles/streamer-backend/files/sreview/config.pl

echo "done."
