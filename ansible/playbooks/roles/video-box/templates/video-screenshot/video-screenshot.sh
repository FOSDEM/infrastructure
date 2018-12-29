#! /bin/sh

SCREENSHOT_PATH="{{ video_screenshot_directory }}/{{ video_screenshot_filename }}"

while true; do
	# Make a screenshot and move atomically
	ffmpeg -v quiet -i tcp://localhost:8898/?timeout=10000 -vf scale=160:-1 -qscale:v 20 -vframes 1 -y ${SCREENSHOT_PATH}.$$.jpg 2>> /dev/null && mv ${SCREENSHOT_PATH}.$$.jpg ${SCREENSHOT_PATH}

	# If we failed, make sure there is no file at all
	if [ $? -ne 0 ]; then
		if [ -f $SCREENSHOT_PATH ]; then
			rm $SCREENSHOT_PATH
		fi
	fi
	rm -f ${SCREENSHOT_PATH}.$$.jpg

	sleep 2s
done
