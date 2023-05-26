#!/bin/sh

xclock -digital -update 1 -geometry +1+730 &
systemctl restart mpv video-status
xsetroot -gray -cursor_name X_cursor
sleep 30d

