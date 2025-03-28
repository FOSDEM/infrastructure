#!/bin/bash
cgexec -g cpuset:fosdem.slice/preview ffmpeg -y -v error -i tcp://localhost:8899 -s 240x134 -vf fps=fps=1,format=rgb565be -c:v rawvideo  -f image2 -s 240x134 -update 1 -atomic_writing 1 /tmp/picture.raw -s  1280x720  -update 1 -atomic_writing 1 /var/www/html/preview.jpg
