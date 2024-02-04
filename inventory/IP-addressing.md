# IP address allocations, FOSDEM 2017

## IPv4

### RIPE objects

- 151.216.128.0/17 # FOSDEM... suballocation from COLT?
- 185.175.216.0/22 # Fosdem LIR allocation.
  - 185.175.216.0/24 # Servers
  - 185.175.217.0/24 # Wired clients (servers etc)

### Configured

- 151.216.128.0/19 # FOSDEM-ancient SSID
  - 151.216.159.254 # asr1k po1.1402
- 151.216.160.0/19 # FOSDEM wired clients
  - 151.216.191.254 # asr1k po1.4001
- 151.216.220.0/23 # wired video
  - 151.216.221.254 # asr1k po1.4006
- 151.216.224.0/20 # nat64 pool
- 185.175.216.240/28 # infra servers
  - 185.175.216.251 # server001 eno4
  - 185.175.216.252 # server002 eno4
  - 185.175.216.254 # asr1k po1.212
- 185.175.218.0/24 # wired video
  - 185.175.218.254/32 # asr1k po1.4006
- 192.168.1.0/24 # server out of band
  - 192.168.1.1 # server001 eno3
  - 192.168.1.2 # server002 eno3
  - 192.168.1.11 # server001 iDRAC
  - 192.168.1.12 # server002 iDRAC
  - 192.168.1.21 # proxmox001
  - 192.168.1.22 # proxmox002
  - 192.168.1.23 # proxmox003
  - 192.168.1.30 # monitoring.n.fosdem.net (for ntp etc..) 
  - 192.168.1.31 # proxmox001 iDRAC
  - 192.168.1.32 # proxmox002 iDRAC
  - 192.168.1.33 # proxmox003 iDRAC
  - 192.168.1.250 # coreswitch001.n.fosdem.net
  - 192.168.1.251 # coreswitch002.n.fosdem.net
  - 192.168.1.252 # coreswitch003.n.fosdem.net /video
  - 192.168.1.253 # nanopi-oob
  - 192.168.1.254 # asr1k gi2/2/0
- 192.168.211.0/24 # switch management
  - 192.168.211.249 # asr1k po1.211
- 213.246.232.52/30 # colt uplink
  - 213.246.232.54 # asr1k gi2/2/1

## IPv6

- 2001:67c:1810::/48 # FOSDEM RIPE allocation
  - 2001:67c:1810:f051::/64 # FOSDEM SSID
  - 2001:67c:1810:f052::/64 # FOSDEM wired clients
  - 2001:67c:1810:f053::/64 # Wired video LAN
  - 2001:67c:1810:f054::/64 # infra servers
  - 2001:67c:1810:f055::/64 # FOSDEM-ancient SSID

