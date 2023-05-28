#!/bin/bash

export DISPLAY=:0.0
mpv --stop-screensaver=no --ao=null --geometry=50%-20+20 --vd-lavc-fast --vd-lavc-skiploopfilter=all --vd-lavc-skipframe=nonref --vd-lavc-framedrop=nonref --no-ytdl --quiet --demuxer-lavf-analyzeduration=30 --lavfi-complex='[aid1] asplit [t1] [ao] ; [t1] showvolume=w=700:h=100 [t2] ; [vid1]  [t2]  overlay  [vo]' tcp://localhost:8898
