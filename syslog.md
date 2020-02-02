# Syslog

We have an `rsyslog` instance running on `server001`. All network-team managed
network devices are configured to log to it. The following facilities log to
specific files.


## Facilities

- `local7`: `/var/log/rsyslog/network-combined`
  - Syslog from all network-team managed network devices.
- `local6`: `/var/log/rsyslog/tacacs-combined`
  - TACACS accounting from all network-team managed devices (what commands have been run)
- `local5`: `/var/log/rsyslog/video-combined`
  - Reserved for video device syslogs
- `local4`: `/var/log/rsyslog/applications-combined`
  - Reserved for application containers (prometheus, grafana, etc etc)

