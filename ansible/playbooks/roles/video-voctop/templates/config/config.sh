#!/bin/sh

{% for room in video_rooms %}
{% if inventory_hostname ==  room + "-voctop.video.fosdem.org" %}
SOURCE_CAM="tcp://{{ room }}-cam.local:8898/?timeout=2000000"
SOURCE_SLIDES="tcp://{{ room }}-slides.local:8898/?timeout=2000000"
SOURCE_URL_PARAMETERS="{{ vocto_source_url_parameters }}"
RECORDING_DIRECTORY="{{ vocto_recording_directory }}"
HOST="{{ room }}-voctop"
ROOM="{{ room }}"
{% endif %}
{% endfor %}
