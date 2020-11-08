#!/bin/sh

{% for room in video_rooms %}
{% if inventory_hostname ==  room + "-voctop.video.fosdem.org" %}
# If you want to test use these:
# SOURCE_CAM="http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
# SOURCE_SLIDES="http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
SOURCE_CAM="http://{{ room }}-cam.video.fosdem.org/0.ts"
SOURCE_SLIDES="http://{{ room }}-slides.video.fosdem.org/0.ts"
SOURCE_URL_PARAMETERS="{{ vocto_source_url_parameters }}"
RECORDING_DIRECTORY="{{ vocto_recording_directory }}"
HOST="{{ room }}-voctop"
ROOM="{{ room }}"
{% endif %}
{% endfor %}
