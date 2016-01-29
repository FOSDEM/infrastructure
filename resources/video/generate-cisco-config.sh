#!/bin/bash

set -e

INV='inventory.csv'
PREFIX_LEN='19'

main() {
  fgrep ':' $INV | while read line; do
    mac=$(echo $line | cut -d, -f1)
    host=$(echo $line | cut -d, -f2)
    encoder=$(echo $line | cut -d, -f3)
    ipv4=$(echo $line | cut -d, -f4)
    gen_cisco_config_for_host $mac $host $encoder $ipv4
  done
}

gen_cisco_config_for_host() {
  mac=$1
  host=$2
  encoder=$3
  ipv4=$4
  pool_name="video-static-${host}"
  delete_pool $pool_name
  create_pool $pool_name
  set_address $ipv4
  set_mac_address $mac
  set_static_info
  exit_pool
}

delete_pool() {
  echo "no ip dhcp pool $1"
}

create_pool() {
  echo "ip dhcp pool $1"
}

set_address() {
  echo "host $1 /${PREFIX_LEN}"
}

set_mac_address() {
  echo "hardware-address $1"
}

set_static_info() {
  echo "default-router 151.216.223.254"
  echo "dns-server 8.8.4.4 8.8.8.8"
  echo "domain-name v.conference.fosdem.net"
}

exit_pool() {
  echo "exit"
  echo
}

main
