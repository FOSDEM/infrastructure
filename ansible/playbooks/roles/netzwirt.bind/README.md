# Ansible Bind

 - Manage bind config files. Zonefiles must be managed somewhere else.
 - This role will solely copy the masterfiles from `bind_lookup_zones`.
 - Build slaves from master without configuring zones.

## Configuration:

Lookup path for master zone files on local ansible machine, relative to playbook.

```yaml
bind_lookup_zones: path/to/zones_dir
```
## ACLs

Create bind ACLs in named.conf.options

```yaml
bind_acls:
  v6localhost:
    - ::1/128
  some_random_networks:
    - 8.0.0.0/8
    - 169.254.0.0/16
```
## dns64 clients

Create dns64 clients list in named.conf.options

```yaml
bind_dns64_clients:
  - v6localhost
```
## Zones definition

Zones are defined as dict. The key is used as domain name.
- `secondary` is optional.
- `type` is defaulted to "master".
- When `type` is set to "slave", the `secondary` property is used as master.

```yaml
bind_zones:
  example.com:
    secondary:
      - '10.100.2.1'
    type: master

  foobar.com:
    secondary:
      - '10.100.2.3'
    type: slave
```
Optionally: List of IP's wich are allowed to do recursive queries.

```yaml
bind_recursion_allowed_clients:
  - 127.0.0.1
  - 127.0.0.2
```
Optionally: Use ipv4, ip6 or any protocols

```yaml
bind_use_protocol: any
```
Optionally: Define listen adresses. Default: bind listens on all interfaces.

```yaml
bind_listen: []
```
Optionally: Define forwarders. If you define forwarders but no zonefiles. Bind is setup as forwarding only.

```yaml
bind_forwarders:
  - 8.8.8.8
  - 8.8.4.4
```
Optionally: Include RFC-1918 zones or not (True|False)

```yaml
bind_rfc1918: any
```
### Build slave from master zones

Set `bind_create_slave_from_master` to create a slave with not having to define zones.

```yaml
bind_create_slave_from_master:
  - master: 'master-ns'
  - master_address:
    - 10.100.2.20
```
## Dependencies

None.


## Example Playbook

```yaml
---
- hosts: bind
  become: yes
  roles:
    - { role: netzwirt.bind }
```

## License

BSD


## Author Information

[netzwirt](https://github.com/netzwirt)

