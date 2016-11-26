#!/bin/sh
SOURCE_CAM="{{ clone_config.cam_source }}"
SOURCE_SLIDES="{{ clone_config.slides_source }}"
SOURCE_URL_PARAMETERS="{{ vocto_container_source_url_parameters }}"
STREAM_DESTINATION="{{ clone_config.stream_destination }}"
RECORDING_DIRECTORY="{{ vocto_container_recording_directory }}"
HOST="vocto-{{ clone_config.room }}"
ROOM="{{ clone_config.room }}"
