#! /bin/sh

while true; do
	ffmpeg -i {{ bmd_streamer_destination }} -vf scale=160:-1 -qscale:v 20 -vframes 1 -y /mnt/ssd/statuspage/screenshot.jpg 2>> /dev/null
	b64=$(base64 -w0 /mnt/ssd/statuspage/screenshot.jpg)
	uptime=$(uptime)
	ip=$(ip addr show dev eth0|grep 'inet '|cut -d' ' -f6)
	hostname=$(hostname | cut -d'.' -f1)
	uptime=$(uptime | cut -d ',' -f1)
	loadaverage=$(uptime | sed -e 's/.*load\ average\:\ //')
	sed -e "s/%%uptime%%/$uptime/g" -e "s/%%loadaverage%%/$loadaverage/g" -e "s;%%base64_image%%;$b64;g" -e "s/%%hostname%%/$hostname/g" -e "s?%%ip_address%%?$ip?g" /mnt/ssd/statuspage/template.html > /mnt/ssd/statuspage/output.html
	sleep 2s
done
