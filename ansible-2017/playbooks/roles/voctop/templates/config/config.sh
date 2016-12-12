#!/bin/sh

{% for config in vocto_config %}
{% if inventory_hostname == "voctop-" + config.room + ".video.fosdem.org" %}
SOURCE_CAM="{{ config.cam_source }}"
SOURCE_SLIDES="{{ config.slides_source }}"
SOURCE_URL_PARAMETERS="{{ vocto_source_url_parameters }}"
STREAM_DESTINATION="{{ config.stream_destination }}"
RECORDING_DIRECTORY="{{ vocto_recording_directory }}"
HOST="voctop-{{ config.room }}"
ROOM="{{ config.room }}"
{% endif %}
{% endfor %}
