#!/bin/bash

set -euo pipefail

tty=/dev/tty_fosdem_box_ctl

if [[ $# -ne 1 ]] || [[ ! -f "${1}" ]]; then
    echo "usage: ${0} <firmware elf file>" >&2
    exit 1
fi

if ! picotool version | grep -qE '^picotool v[1-9]'; then
    echo "picotool v1.0 or greater not available on $(hostname), quitting" >&2
    exit 1
fi

if [[ -e "${tty}" ]]; then
    echo 'firmware is currently running: telling it to restart to bootloader'
    stty -F "${tty}" 134
fi

if ! lsusb | grep -qE '\<2e8a:0003\>'; then
	gpioset gpiochip0 17=1
	gpioset gpiochip0 7=1

	sleep 1

	gpioset gpiochip0 17=0
	gpioset gpiochip0 7=0
fi


i=0
while ! lsusb | grep -qE '\<2e8a:0003\>'; do
    sleep 0.5
    i=$(( i + 1 ))
    if [[ "${i}" -gt 20 ]]; then
        echo 'rp2040 bootloader did not appear'
        exit 1
    fi
done

echo 'flashing'
picotool load "${1}"
echo 'rebooting'
picotool reboot
