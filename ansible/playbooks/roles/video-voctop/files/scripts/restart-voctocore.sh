#!/bin/bash

systemctl stop vocto-source-cam.service vocto-source-slides.service vocto-sink-output.service
systemctl restart voctocore
systemctl start vocto-source-cam.service vocto-source-slides.service vocto-sink-output.service
