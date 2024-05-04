#!/usr/bin/env python3

#
# dependencies: fontconfig, python-pygame
#
# TODO:
# * Try to reduce CPU usage, currently at ~5%
#   - less frequent updates of "static" data (MAC address, hostname,
#     stream URL)
#   - only redraw what's really necessary instead of the whole block
# * IPv6 address isn't being displayed because it doesn't fit on the
#   screen. We could implement some kind of scrolling marquee for text
#   that doesn't fit on the screen? Or reduce the font size?

import json
import os
import re
import signal
import subprocess
import sys
import time

WHITE = 255,255,255
BLACK = 0,0,0
GREEN = 0,255,0
RED   = 255,0,0

NORMAL = 0
GOOD = 1
BAD = 2

WIDTH=640
HEIGHT=404

IMGHEIGHT=int(((WIDTH-22)*9)/16)

os.environ["LANG"] = "C"

LOGO_FILE =  '/usr/local/bin/logo.png'

class stateEntry():
	""" entry in the states """
	data: str
	state: int # 0 NORMAL 1 GOOD(green) 2 BAD(red)

	def __init__(self, inpdata, inpstate=0):
		self.data = inpdata
		self.state = inpstate



def render_text(states):

	def strRed(skk):
		return "\033[91m" + skk + "\033[00m"
 
	def strGreen(skk): 
		return "\033[92m" + skk + "\033[00m"

	out = ""

	maxLen = 0

	for state in states:
		maxLen = max(maxLen, len(state.data))

	maxLen = int(maxLen / 8 + 1) * 8

	for state in states:
		if state.state == GOOD:
			rend = strGreen(state.data)
		elif state.state == BAD:
			rend = strRed(state.data)
		else:
			rend = state.data
		out += "| " + rend + " " * (maxLen - len(state.data)) + " |\n"

	return out

def output_terminal(states):
	sys.stdout.write("\x1b7\x1b[%d;%df%s\x1b8" % (0, 0, render_text(states)))
	sys.stdout.flush()

def main():
	# Initialize the display
	os.system("clear")
	while True:
		info = update_sysinfo()
		output_terminal(info)

		# Lock the framerate to 1 FPS max
		time.sleep(1)

def update_sysinfo():
	ret = []
	# Hostname
	hostname = os.popen('hostname -s').read().strip()

	# Uptime
	uptime = os.popen('uptime').read().strip()
	matches = re.search('\s?(.*)\s+up\s+(.*?),\s+([0-9]+) users?,\s+load average: ([0-9]+\.[0-9][0-9]),?\s+([0-9]+\.[0-9][0-9]),?\s+([0-9]+\.[0-9][0-9])', uptime)
	uptime_time, uptime_duration, uptime_users, uptime_avg1, uptime_avg5, uptime_avg15 = matches.groups()

	# Interface

	try:
		ifdata = json.loads(subprocess.check_output("ip -j route get 8.8.8.8", shell=True).decode("utf-8"))
		interface = ifdata[0]["dev"]
		# IP addresses
		addr_data = json.loads(subprocess.check_output('ip -j addr show dev ' + interface + ' primary scope global', shell=True).decode("utf-8"))
		ip_link_mac = addr_data[0]["address"]

	#try:
	#	ip_addr_v6 = re.search('\sinet6\ ([^\s]+)', ip_addr).groups()[0]
	#except AttributeError:
	#	ip_addr_v6 = False

		ip_prefix_v4 = False
		ip_addr_v4 = False

		for a in addr_data[0]["addr_info"]:
			try:
				if a["family"] == "inet":
					ip_prefix_v4 = str(a["local"]) + "/" + str(a["prefixlen"])
					ip_addr_v4 = str(a["local"])
			except KeyError:
				pass

	except:
		interface = None
		ip_prefix_v4 = False
		ip_addr_v4 = False
		ip_link_mac = "UNKNOWN"

	rec_info = os.popen('systemctl show video-recorder --property=ActiveState').read()
	if re.search('^ActiveState=active', rec_info) == None:
		rec = False
	else:
		rec = True

	# Signal
	# width: 1920
	# height: 1200
	# signal: no

	try:
		signaldata = json.loads(open('/tmp/ms213x-status', 'r').read())
		if signaldata['signal'] == 'yes':
			signal = True
			resX = signaldata['width']
			resY = signaldata['height']
			resolution = str(resX) + "x" + str(resY)
		else:
			signal = False
	except Exception as e:
		print("exception")
		print(e)
		signal = False
	#print(signaldata)	
	if signal:
		ret.append(stateEntry("SIGNAL " + resolution))
	else:
		ret.append(stateEntry("NO SIGNAL", BAD))
		


	if rec:
		ret.append(stateEntry("RECORD", GOOD))

	else:
		ret.append(stateEntry("PAUSED"))

	
	ret.append(stateEntry("uptime: " + uptime_time + ", up " + uptime_duration))

#	powerstatus = open('/sys/class/power_supply/AC/online', 'r').read().strip()
#	if powerstatus == "0":
#		powerst = "OFF"
#	else:
#		powerst = "ON"
#	print("power supply: " + powerst)

	connected = subprocess.check_output("ss -H -o state established '( sport = :8899 )'  not dst '[::1]'|wc -l", shell = True).strip().decode("utf-8")

	ret.append(stateEntry("connected readers: " + connected, GOOD if int(connected) > 0 else NORMAL))


	sensordata = json.loads(subprocess.check_output("sensors -j 2>/dev/null", shell=True).decode("utf-8"))

    #root@box1:/usr/local/bin# sensors -j 2>/dev/null | jq '."thinkpad-isa-0000".temp1.t:semp1_input' |less
	#root@box1:/usr/local/bin# sensors -j 2>/dev/null | jq '."coretemp-isa-0000"."Package id 0"."temp1_input"' 

	cpu_temp = sensordata["coretemp-isa-0000"]["Package id 0"]["temp1_input"]

	ret.append(stateEntry("temperature cpu: " + str(cpu_temp), NORMAL if cpu_temp < 60 else BAD))

	ret.append(stateEntry("load: " + uptime_avg1 + ", " + uptime_avg5 + ", " + uptime_avg15, NORMAL if float(uptime_avg1) < 3.9 else BAD))

	if ip_addr_v4 != False:
		ret.append(stateEntry("IPv4: " + ip_prefix_v4))
		ret.append(stateEntry("MAC address: " + ip_link_mac))
		ret.append(stateEntry("stream: tcp://" + ip_addr_v4 + ":8898/"))
	else:
		ret.append(stateEntry("IPv4: no IPv4 address", BAD))
		ret.append(stateEntry("MAC address: " + ip_link_mac))
		ret.append(stateEntry("stream: n/a"))


	if os.path.exists('/etc/fosdem_revision'):
		fp = open('/etc/fosdem_revision', "r")
		ret.append(stateEntry("revision: " + fp.read().rstrip()))
		fp.close()
	else:
		ret.append(stateEntry("revision not found"), BAD)

	return ret

def signal_handler(signum, frame):
	# We need something to catch signals since systemd sends a SIGHUP, if we
	# don't catch that, we'll quit and die
	pass

if __name__=="__main__":
	signal.signal(signal.SIGHUP, signal_handler)
	main()

# vim: noai:ts=4:sw=4:noexpandtab
