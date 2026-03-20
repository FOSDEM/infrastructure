#!/bin/bash
cd /opt/fazantix
cage -d -- bash -c 'nice -n -19 systemd-run --scope -p AllowedCPUs=1 fazantix /opt/fazantix/fosdem.yaml'
