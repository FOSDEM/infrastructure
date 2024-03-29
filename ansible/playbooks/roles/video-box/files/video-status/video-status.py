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

import pygame
from pygame.locals import *

WHITE = 255,255,255
BLACK = 0,0,0
GREEN = 0,255,0
RED   = 255,0,0

WIDTH=640
HEIGHT=404

IMGHEIGHT=int(((WIDTH-22)*9)/16)

os.environ["LANG"] = "C"

LOGO_FILE =  '/usr/local/bin/logo.png'

def main():
	# Initialize the display
	size = width, height = WIDTH, HEIGHT
	x = 20
	y = 20
	os.environ['SDL_VIDEO_WINDOW_POS'] = "%d,%d" % (x,y)
	screen = pygame.display.set_mode(size)
	pygame.display.set_caption("FOSDEM video box status")
	pygame.display.set_allow_screensaver(True)
	pygame.init()

	subprocess.check_output('xsetroot -solid \#800080', shell=True)

	# Uninitialise the pygame mixer to release the sound card
	pygame.mixer.quit()

	# Hide the mouse cursor
	pygame.mouse.set_visible(False)

	# Draw our logo straight on the screen
	if os.path.isfile(LOGO_FILE):
		logo = pygame.image.load(LOGO_FILE)
		screen.blit(logo, (22,10))

	# Main loop
	clock = pygame.time.Clock()
	while True:
		for event in pygame.event.get():
			if event.type == QUIT:
				pygame.display.quit()
				sys.exit(0)
			elif event.type == KEYDOWN and event.key == K_ESCAPE:
				pygame.display.quit()
				sys.exit(0)

		update_sysinfo(screen, logo)

		pygame.display.update()


		# Lock the framerate to 1 FPS max
		clock.tick(1)

def update_sysinfo(screen, logo):
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

	# Prepare surface
	surface = pygame.Surface((WIDTH, WIDTH-IMGHEIGHT+80))
	image = surface.convert()
	image.fill(BLACK)
	image.blit(logo, (22,10))

	# Print output
	hpos = 120
	font_size = 25
	font = pygame.font.SysFont("monospace", 25, True)
	image.blit(font.render("hostname: " + hostname, 1, WHITE), (0, hpos))

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
		image.blit(font.render("SIGNAL", 1, GREEN), (480, 20))
		image.blit(font.render(resolution, 1, GREEN), (480, 50))
	else:
		image.blit(font.render("NO SIGNAL", 1, RED), (480, 20))
		

	#screen.blit(image_no_signal, (480, 20))


	if rec:
		if (pygame.time.get_ticks()/1000) % 2: # Print the recording symbol every odd second
			pygame.draw.circle(image, RED, (485, hpos + int(font_size/2)), int(font_size/3))
		image.blit(font.render("RECORD", 1, RED), (500, hpos))

	else:
		pygame.draw.line(image, WHITE, (485, hpos+3), (485, hpos + font_size-2 ), 2) # Pause symbol line 1
		pygame.draw.line(image, WHITE, (490, hpos+3), (490, hpos + font_size-2 ), 2) # Pause symbol line 1
		image.blit(font.render("PAUSED", 1, WHITE), (500, hpos))

	
	hpos += font_size
	image.blit(font.render("uptime: " + uptime_time + ", up " + uptime_duration, 1, WHITE), (0, hpos))

	hpos += font_size
	powerstatus = open('/sys/class/power_supply/AC/online', 'r').read().strip()
	if powerstatus == "0":
		powerst = "OFF"
	else:
		powerst = "ON"
	image.blit(font.render("power supply: " + powerst, 1, RED if powerstatus == "0" else WHITE), (0, hpos))

	hpos += font_size
	connected = subprocess.check_output("ss -H -o state established '( sport = :8899 )'  not dst '[::1]'|wc -l", shell = True).strip().decode("utf-8")

	image.blit(font.render("connected readers: " + connected, 1, RED if connected == "0" else WHITE), (0, hpos))


	hpos += font_size
	sensordata = json.loads(subprocess.check_output("sensors -j 2>/dev/null", shell=True).decode("utf-8"))

    #root@box1:/usr/local/bin# sensors -j 2>/dev/null | jq '."thinkpad-isa-0000".temp1.t:semp1_input' |less
	#root@box1:/usr/local/bin# sensors -j 2>/dev/null | jq '."coretemp-isa-0000"."Package id 0"."temp1_input"' 

	cpu_temp = sensordata["coretemp-isa-0000"]["Package id 0"]["temp1_input"]

	image.blit(font.render("temperature cpu: " + str(cpu_temp), 1, RED if float(cpu_temp) > 80 else WHITE), (0, hpos))

	hpos += font_size
	image.blit(font.render("load: " + uptime_avg1 + ", " + uptime_avg5 + ", " + uptime_avg15, 1, RED if float(uptime_avg1) > 3.95 else WHITE), (0, hpos))

	hpos += font_size
	if ip_addr_v4 != False:
		image.blit(font.render("IPv4: " + ip_prefix_v4, 1, WHITE), (0, hpos))
		hpos += font_size
		image.blit(font.render("MAC address: " + ip_link_mac, 1, WHITE), (0, hpos))
		hpos += font_size
		image.blit(font.render("stream: tcp://" + ip_addr_v4 + ":8898/", 1, WHITE), (0, hpos))
	else:
		image.blit(font.render("IPv4: no IPv4 address", 1, RED), (0, hpos))
		hpos += font_size
		image.blit(font.render("MAC address: " + ip_link_mac, 1, WHITE), (0, hpos))
		hpos += font_size
		image.blit(font.render("stream: n/a", 1, RED), (0, hpos))


	hpos += font_size
	if os.path.exists('/etc/fosdem_revision'):
		fp = open('/etc/fosdem_revision', "r")
		image.blit(font.render("revision: " + fp.read().rstrip(), 1, WHITE), (0, hpos))
		fp.close()
	else:
		image.blit(font.render("revision not found", 1, WHITE), (0, hpos))

	screen.blit(image,(10,10))

def signal_handler(signum, frame):
	# We need something to catch signals since systemd sends a SIGHUP, if we
	# don't catch that, we'll quit and die
	pass

if __name__=="__main__":
	signal.signal(signal.SIGHUP, signal_handler)
	main()

# vim: noai:ts=4:sw=4:noexpandtab
