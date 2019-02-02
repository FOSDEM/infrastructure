#!/bin/bash
#

export PRIVATE_API_KEY='{{ dashboard_sync.private_api_key }}'
export PRIVATE_URL='{{ dashboard_sync.private_url }}'
export PUBLIC_API_KEY='{{ dashboard_sync.public_api_key }}'
export PUBLIC_URL='{{ dashboard_sync.public_url }}'

sync_grafana_dashboards.rb
