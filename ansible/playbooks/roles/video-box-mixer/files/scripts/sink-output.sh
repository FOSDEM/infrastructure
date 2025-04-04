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
# in the GPU, make a copy of the stream to [vout], [vout-preds] and [vout-preds2]
# in the GPU, scale [vout-preds] to 1280x720 and write to [vout-ds]
# in the GPU, scale [vout-preds2] to 854:480 and write to [vout-ds2]
# (ds stands for "downscaled")
#
# Then, for  [vout], [vout-ds] and [vout-ds2] do an encode to the revevant bitrate, CBR mode
#
# Then, encode the audio streams separately, one per video stream, otherwise ffmpeg
# on the streambackend can't generate the HLS properly
#
# Then, create a mpeg-ts stream with three video streams and four audio streams that would
# be consumed upstream

ffmpeg -y -nostdin -init_hw_device vaapi=intel:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device intel -filter_hw_device intel  \
	-probesize 2M \
	-analyzeduration 2M \
	-i tcp://localhost:11000 \
	-threads:0 0 \
	-aspect 16:9 \
	-filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right]; [0:v] format=nv12,hwupload [vout]" \
	-map '[vout]:0' \
	-c:v:0 h264_vaapi -rc_mode CBR\
	-g 30 \
	-maxrate:v:0 5000k -bufsize:v:0 8192k \
	-b:v:0 3000k \
	-qmin:v:0 1 \
	-map '[left]:1' \
	-ac:1 1 -strict -2 -c:a:0 aac -b:a:0 128k -ar:0 48000 \
	-map '[right]:2' \
	-ac 1 -strict -2 -c:a:1 aac -b:a:1 128k -ar:1 48000 \
	-f mpegts - | sproxy

