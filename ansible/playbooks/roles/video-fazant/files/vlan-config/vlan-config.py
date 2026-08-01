#!/usr/bin/python3


import os
import socket
import re
import sys
import syslog
import time
import tomllib


def serial_cmd(cmd):
	start = time.time()
	sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
	try:
		sock.connect("/dev/sock_fosdem_box_ctl")
	except:
		return []
	sock.send(cmd)
	sock.send(b"\n\n")
	reader = sock.makefile()
	retdata = []
	while True:
		try:
			l = reader.readline().strip()
		except (ConnectionResetError, ConnectionRefusedError) as error:
			return retdata
		if re.match(r"^(ok|fail)", l):
			break
		retdata.append(l)
	end = time.time()
	duration = end - start
#	print(f"Command took {duration}")
	return retdata


portnames = ["IN", "01", "02", "03", "04"]


def port_name_to_idx(name):
    for i, n in enumerate(portnames):
        if n == name:
            return i

if not os.path.isfile("/etc/network/switch.toml"):
    syslog.syslog("No switch config file found, disabling vlan support")
    port.write(b"netswitch.vlan-init 0\n")
    sys.exit(0)

with open("/etc/network/switch.toml", "rb") as handle:
    config = tomllib.load(handle)

    serial_cmd(b"netswitch.vlan-init 0\n")

    if not config['vlans']:
        syslog.syslog("VLAN support is disabled in the config")
        sys.exit(0)

    serial_cmd(b"netswitch.vlan-init 1\n")

    memberconfig = 1
    all_tagged = set()
    all_untagged = set()
    for vlan_name in config:
        if not isinstance(config[vlan_name], dict):
            continue

        vlan = config[vlan_name]

        vid = vlan['vlan']
        members = 0
        tagged = 0
        untagged = 0
        syslog.syslog(f"Creating vlan '{vlan_name}' with vid {vid}")

        for p in vlan['tagged']:
            members |= 1 << port_name_to_idx(p)
            tagged |= 1 << port_name_to_idx(p)
            all_tagged.add(p)
        for p in vlan['untagged']:
            members |= 1 << port_name_to_idx(p)
            untagged |= 1 << port_name_to_idx(p)
            all_untagged.add(p)
        print(f"VLAN {vid} tagged {tagged} untagged {untagged} members {members}")

        serial_cmd(f"netswitch.vlan-entry-define {vid} {members} {untagged}\n".encode())

        if untagged != 0:
            serial_cmd(f"netswitch.vlan-member-define {memberconfig} {vid} {untagged}\n".encode())
            print(f"netswitch.vlan-member-define {memberconfig} {vid} {untagged}\n".encode())
            memberconfig += 1

    for p in all_tagged - all_untagged:
        serial_cmd(f"netswitch.vlan-filtering {port_name_to_idx(p)} tagged-only\n".encode())
    for p in all_untagged - all_tagged:
        serial_cmd(f"netswitch.vlan-filtering {port_name_to_idx(p)} untagged-only\n".encode())
    for p in all_tagged & all_untagged:
        serial_cmd(f"netswitch.vlan-filtering {port_name_to_idx(p)} all\n".encode())
