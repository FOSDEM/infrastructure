#!/bin/sh

{% for config in vocto_config %}
{% if inventory_hostname ==  config.room + "-voctop.video.fosdem.org" %}
SOURCE_CAM="tcp://{{ config.room }}-cam.local:8898/"
SOURCE_SLIDES="tcp://{{ config.room }}-slides.local:8898/"
SOURCE_URL_PARAMETERS="{{ vocto_source_url_parameters }}"
STREAM_DESTINATION="{{ config.stream_destination }}"
STREAM_BACKUP_DESTINATION="{{ config.stream_backup_destination }}"
RECORDING_DIRECTORY="{{ vocto_recording_directory }}"
HOST="{{ config.room }}-voctop"
ROOM="{{ config.room }}"
{% endif %}
{% endfor %}
