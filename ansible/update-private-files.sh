#!/bin/sh

if [ $# != 1 -o ! -d $1 ]; then
  echo "ERROR: please tell me where I can find the private files."
  echo "usage: $(basename $0) <directory>"
  exit 1
fi

echo -n "copying private files from ${1}... "

cp $1/bmd-firmware/bmd-atemtvstudio.bin playbooks/roles/video-box/files/bmd/bmd-atemtvstudio.bin
cp $1/bmd-firmware/bmd-h264prorecorder.bin playbooks/roles/video-box/files/bmd/bmd-h264prorecorder.bin
cp $1/certificates/stream.fosdem.org.key playbooks/roles/video-streamer-frontend/files/nginx/certificate/stream.fosdem.org.key
cp $1/certificates/stream.fosdem.org.crt playbooks/roles/video-streamer-frontend/files/nginx/certificate/stream.fosdem.org.crt
cp $1/certificates/live.fosdem.org.key playbooks/roles/video-web-frontend/files/nginx/certificate/live.fosdem.org.key
cp $1/certificates/live.fosdem.org.crt playbooks/roles/video-web-frontend/files/nginx/certificate/live.fosdem.org.crt
cp $1/certificates/control.video.fosdem.org.key playbooks/roles/video-control-server/files/nginx/certificate/control.video.fosdem.org.key
cp $1/certificates/control.video.fosdem.org.crt playbooks/roles/video-control-server/files/nginx/certificate/control.video.fosdem.org.crt
cp $1/sreview/config.pl playbooks/roles/video-streamer-backend/files/sreview/config.pl
cp $1/control/htpasswd playbooks/roles/video-control-server/files/nginx/htpasswd
cp $1/jibri/streamkeysalt.sh playbooks/roles/video-bbb/files/config/streamkeysalt.sh
cp $1/monitoring/send_nsca.cfg playbooks/roles/video-monitoring/files/send_nsca.cfg

echo "done."
