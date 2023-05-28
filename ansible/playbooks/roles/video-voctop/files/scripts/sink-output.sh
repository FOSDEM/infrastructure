#!/bin/sh

confdir="`dirname "$0"`/../config/"
. ${confdir}/defaults.sh
. ${confdir}/config.sh

#
# The video encoding needs to be kept in sync with the review system,
# otherwise things like
# https://twitter.com/jlecour/status/1229381883680694273 happen.
#
# Either update playbooks/roles/encoder-common/templates/config.j2
# (extra_profiles variable, FOSDEM key) or talk to Wouter if you can't
# figure it out. Thanks!
#

# this is weird and hairy, so here's a longer explanation what it does -- VK

# make two fifos, so we can write to them - I can't write to to two processes
# from a single process

mkfifo scaled.mp4 unscaled.mp4 || true

# each sproxy just reads and sends. First one is on 8898 and 8899, second one
# on 8918 and 8919 (originals +20)

/usr/bin/sproxy < unscaled.mp4 &
/usr/bin/sproxy 20 < scaled.mp4 &

# This is a ffmpeg invocation to have the two streams done in one ffmpeg process.
# The reason is that voctomix eats ~30% CPU on each process reading the finished output,
# and that can lead to CPU starvation, so this much saved CPU counts.
#
# flow is as follows:
#
# Fetch data from voctomix (tcp://localhost:11000)
# split audio in two channels, as we send them as two separate streams
#
# filter-complex explanation:
# take the video stream, get it to the gpu ([vhw])
# in the GPU, make a copy of the stream to [vout] and [vout-preds]
# in the GPU, scale [vout-preds] to 1280x720 and write to [vout-ds]
# (ds stands for "downscaled")
#
# Then, for both [vout] and [vout-ds], do an encode to the revevant bitrate, CBR mode
#
# Then, encode the audio streams separately
#
# Then, in -f tee, make one mpegts stream with video:0 (vout), and both audio streams as separate channels,
# and one video stream with video:1 (vout-ds) and both channels again.

ffmpeg -y -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
	-probesize 10M \
	-analyzeduration 10M \
	-i tcp://localhost:11000 \
	-threads:0 0 \
	-aspect 16:9 \
	-filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right]; [0:v] format=nv12,hwupload [vhw]; [vhw] split [vout] [vout-preds]; [vout-preds] scale_vaapi=w=1280:720 [vout-ds] " \
	-map '[vout]:0' \
	-c:v:0 h264_vaapi -rc_mode CBR\
	-g 30 \
	-maxrate:v:0 5000k -bufsize:v:0 8192k \
	-b:v:0 2500k \
	-qmin:v:0 1 \
	\
	-map '[vout-ds]:1' \
	-c:v:1 h264_vaapi -rc_mode CBR\
	-g 30 \
	-maxrate:v:0 3000k -bufsize:v:0 8192k \
	-b:v:1 1000k \
	-qmin:v:1 1 \
	-map '[left]:1' \
	-ac 1 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-map '[right]:2' \
	-ac 1 -strict -2 -c:a aac -b:a 128k -ar 48000 \
	-f tee "[select=\'v:0,a:0,a:1\':f=mpegts]unscaled.mp4|[select=\'v:1,a:0,a:1\':f=mpegts]scaled.mp4"
