#!/bin/bash

export DISPLAY=:0.0
mpv --geometry=50%+660+20 --vd-lavc-fast --vd-lavc-skiploopfilter=all --vd-lavc-skipframe=nonref --vd-lavc-framedrop=nonref --no-ytdl --term-status-msg='  ${=time-pos}' --demuxer-lavf-analyzeduration=30 --lavfi-complex='[aid1] asplit [t1] [ao] ; [t1] showvolume=w=700:h=100 [t2] ; [vid1]  [t2]  overlay  [vo]' tcp://localhost:8898
