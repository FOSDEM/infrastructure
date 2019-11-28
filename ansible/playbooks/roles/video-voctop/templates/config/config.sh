#!/bin/sh

{% for room in video_rooms %}
{% if inventory_hostname ==  room + "-voctop.video.fosdem.org" %}
SOURCE_CAM="http://{{ room }}-cam.video.fosdem.org:8080/0.ts"
SOURCE_SLIDES="http://{{ room }}-slides.video.fosdem.org:8080/0.ts"
SOURCE_URL_PARAMETERS="{{ vocto_source_url_parameters }}"
RECORDING_DIRECTORY="{{ vocto_recording_directory }}"
HOST="{{ room }}-voctop"
ROOM="{{ room }}"
{% endif %}
{% endfor %}
