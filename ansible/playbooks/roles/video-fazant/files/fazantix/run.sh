#!/bin/bash
cd /opt/fazantix
#cage -d -- bash -c 'GOEXPERIMENT=preemptibleloops systemd-run --scope -p AllowedCPUs=1 fazantix /opt/fazantix/fosdem.yaml'
cage -d -- bash -c 'GOEXPERIMENT=preemptibleloops GOMAXPROCS=32  systemd-run --scope -p AllowedCPUs=1 fazantix /opt/fazantix/fosdem.yaml'
