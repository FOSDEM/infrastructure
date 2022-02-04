#!/bin/bash -e
cd /opt/config
cp preroll$(systemctl list-timers|grep recording@|grep -v ^n/a|sed -e 's/.*\@\([0-9].*\)\.service/\1/g'|uniq |head -n1).raw slide.raw
