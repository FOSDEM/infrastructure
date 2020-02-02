# Syslog


## Syslog setup

We have an `rsyslog` instance running on `server001`. All network-team managed
network devices are configured to log to it.

Docker containers running on `server002` are configured using the Docker syslog
driver to push to the `rsyslog` instance on `server001`.

## Facilities

- `local7`: `/var/log/rsyslog/network-combined`
  - Syslog from all network-team managed network devices.
- `local6`: `/var/log/rsyslog/tacacs-combined`
  - TACACS accounting from all network-team managed devices (what commands have been run)
- `local5`: `/var/log/rsyslog/video-combined`
  - Reserved for video device syslogs
- `local4`: `/var/log/rsyslog/applications-combined`
  - Reserved for application containers (prometheus, grafana, etc etc)
