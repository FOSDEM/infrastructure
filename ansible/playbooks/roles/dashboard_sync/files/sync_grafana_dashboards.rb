#!/usr/bin/env ruby
#
# Description: Sync one Grafana to another.
#
require 'uri'
require 'net/http'
require 'json'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN

private_api_key = ENV['PRIVATE_API_KEY']
private_url = ENV['PRIVATE_URL']
public_api_key = ENV['PUBLIC_API_KEY']
public_url = ENV['PUBLIC_URL']

if private_api_key.nil?
  puts 'Missing ENV: PRIVATE_API_KEY'
  exit 1
end

if private_url.nil?
  puts 'Missing ENV: PRIVATE_URL'
  exit 1
end

if public_api_key.nil?
  puts 'Missing ENV: PUBLIC_API_KEY'
  exit 1
end

if public_url.nil?
  puts 'Missing ENV: PUBLIC_URL'
  exit 1
end

# Fetch all the dashboards from the private Grafana server.
uri = URI(private_url + '/api/search')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == "https")
req = Net::HTTP::Get.new(uri.request_uri)
req['Authorization'] = "Bearer #{private_api_key}"

res = http.request(req)
case res
when Net::HTTPSuccess
  logger.debug("Fetched private dashboard list")
else
  logger.error("Failed fetching private dashboard list: #{res.value}")
  exit 1
end

private_dashboards = JSON.parse(res.body)

# Fetch all the dashboards from the public Grafana server.
uri = URI(public_url + '/api/search')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == "https")
req = Net::HTTP::Get.new(uri.request_uri)
req['Authorization'] = "Bearer #{public_api_key}"

res = http.request(req)
case res
when Net::HTTPSuccess
  logger.debug("Fetched public dashboard list")
else
  logger.error("Failed fetching public dashboard list: #{res.value}")
  exit 1
end

public_dashboards = JSON.parse(res.body)

# Get a list of the UIDs.
public_uids = public_dashboards.map { |db| db['uid'] }

# Get and update all dashboards.
private_dashboards.each do |dashboard|
  # Skip non-dashboard entries.
  if dashboard['type'] != 'dash-db'
    next
  end
  # Skip influxdb dashboards
  if dashboard['tags'].include? 'influxdb'
    next
  end
  # Skip broken dashboards
  if dashboard['folderTitle'] == '.BROKEN'
    next
  end

  # Fetch the current dashboard.
  logger.debug("Fetching #{dashboard['uri']}")
  uri = URI(private_url + "/api/dashboards/uid/#{dashboard['uid']}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  req = Net::HTTP::Get.new(uri.request_uri)
  req['Authorization'] = "Bearer #{private_api_key}"
  res = http.request(req)

  case res
  when Net::HTTPSuccess
    logger.debug("Fetched #{dashboard['uri']}")
  else
    logger.error("Failed fetching #{dashboard['uri']}: #{res.value}")
    # Skip trying to update a dashboard that has failed to fetch.
    next
  end

  dashboard_source = JSON.parse(res.body)
  dashboard_source['dashboard']['id'] = nil
  dashboard_source['overwrite'] = true

  # Do the dashboards update.
  logger.debug("Updating #{dashboard['uri']}")
  uri = URI(public_url + '/api/dashboards/db')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  req = Net::HTTP::Post.new(uri.request_uri)
  req['Authorization'] = "Bearer #{public_api_key}"
  req['Accept'] = 'application/json',
  req['Content-Type'] = 'application/json'
  req.body = JSON.generate(dashboard_source)
  res = http.request(req)
  case res
  when Net::HTTPSuccess
    logger.debug("Updated #{dashboard['uri']}")
  else
    logger.error("Failed updating #{dashboard['uri']}: #{res.value}")
  end

  # Remove UID from cleanup list.
  public_uids.delete dashboard['uid']
end

# Cleanup any old UIDs.
public_uids.each do |uid|
  dashboard = public_dashboards.find {|d| d['uid'] == uid }
  logger.debug("Deleting #{dashboard['uri']}")
  uri = URI(public_url + "/api/dashboards/uid/#{uid}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  req = Net::HTTP::Delete.new(uri.request_uri)
  req['Authorization'] = "Bearer #{public_api_key}"
  req['Accept'] = 'application/json',
  req['Content-Type'] = 'application/json'
  res = http.request(req)
  case res
  when Net::HTTPSuccess
    logger.debug("Deleted #{dashboard['uid']}")
  else
    logger.error("Failed deleting #{dashboard['uid']}: #{res.value}")
  end
end
