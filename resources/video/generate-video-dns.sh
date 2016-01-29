#!/bin/bash

set -e

INV='inventory.csv'
PREFIX_LEN='19'

main() {
  generate_zonefile_header

  echo ";;"
  echo

  fgrep ':' $INV | while read line; do
    host=$(echo $line | cut -d, -f2)
    ipv4=$(echo $line | cut -d, -f4)
    echo "$host    IN    A    $ipv4"
  done
}


generate_zonefile_header() {
  echo '$TTL 3600'
  echo "@ IN SOA ns0.conference.fosdem.net. hostmaster.conference.fosdem.net. ("
  echo " $(generate_serial) ; serial"
  echo " 600 ; refresh"
  echo " 300 ; retry"
  echo " 604800 ; expire"
  echo " 3600 ; default_ttl"
  echo " )"
  echo "@ IN NS ns0.conference.fosdem.net."
  echo "; @ IN NS ns0.conference.fosdem.net."
}

generate_serial() {
  date +%Y%m%d%H%M%S
}


main
