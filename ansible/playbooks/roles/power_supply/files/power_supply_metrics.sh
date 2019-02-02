#!/bin/bash
#
# Description: Generate /sys/class/power_supply metrics

if [[ -f /sys/class/power_supply/AC/online ]] ; then
  echo "# HELP node_power_supply_ac_online Boolean if the AC is plugged in"
  echo "# TYPE node_power_supply_ac_online gauge"
  echo "node_power_supply_ac_online $(< /sys/class/power_supply/AC/online)"
fi
