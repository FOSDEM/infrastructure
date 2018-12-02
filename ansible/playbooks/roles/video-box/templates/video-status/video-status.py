#!/usr/bin/env python2

#
# dependencies: fontconfig, python-pygame
#
# TODO:
# * Read a config file on the box to find the stream URL
# * Try to reduce CPU usage, currently at ~5%
#   - less frequent updates of "static" data (MAC address, hostname,
#     stream URL)
#   - only redraw what's really necessary instead of the whole block
# * IPv6 address isn't being displayed because it doesn't fit on the
#   screen. We could implement some kind of scrolling marquee for text
#   that doesn't fit on the screen? Or reduce the font size?

import os, sys, re, signal, pygame
from pygame.locals import *

WHITE = 255,255,255
BLACK = 0,0,0
GREEN = 0,255,0
RED   = 255,0,0

GIT_REVISION = '{{ git_version.stdout }}'
NETWORK_INTERFACE = '{{ network_device }}'
SCREENSHOT_FILE =  '{{ video_screenshot_directory }}/{{ video_screenshot_filename }}'
LOGO_FILE =  '/usr/local/bin/logo.png'

def main():
	# Initialize the display
	size = width, height = 320, 240
	screen = pygame.display.set_mode(size)
	pygame.display.set_caption("FOSDEM video box status")
	pygame.init()

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

		update_screenshot(screen)
		update_sysinfo(screen)

		pygame.display.update()

		# Lock the framerate to 1 FPS max
		clock.tick(1)

def update_screenshot(screen):
	surface = pygame.Surface((162, 92))
	image = surface.convert()
	image.fill(BLACK)

	pygame.draw.rect(image, WHITE, (0, 0, 162, 92), 1) # border

	if os.path.isfile(SCREENSHOT_FILE):
		image.blit(pygame.image.load(SCREENSHOT_FILE), (1,1))
	else:
		pygame.draw.line(image, RED, (50,10), (110,80), 10) # cross leg 1
		pygame.draw.line(image, RED, (50,80), (110,10), 10) # cross leg 1

		font = pygame.font.SysFont("monospace", 25, True)
		image.blit(font.render("no input", 1, WHITE), (25, 30))

	screen.blit(image,(150,10))

def update_sysinfo(screen):
	# Hostname
	hostname = os.popen('hostname -s').read().strip()

	# Uptime
	uptime = os.popen('uptime').read().strip()
	matches = re.search('\s?(.*)\s+up\s+(.*?),\s+([0-9]+) users?,\s+load average: ([0-9]+\.[0-9][0-9]),?\s+([0-9]+\.[0-9][0-9]),?\s+([0-9]+\.[0-9][0-9])', uptime)
	uptime_time, uptime_duration, uptime_users, uptime_avg1, uptime_avg5, uptime_avg15 = matches.groups()

	# IP addresses
	ip_addr = os.popen('ip addr show dev ' + NETWORK_INTERFACE + ' primary scope global').read()

	#try:
	#	ip_addr_v6 = re.search('\sinet6\ ([^\s]+)', ip_addr).groups()[0]
	#except AttributeError:
	#	ip_addr_v6 = False

	try:
		ip_prefix_v4 = re.search('\sinet\ ([^\s]+)', ip_addr).groups()[0]
		ip_addr_v4 = re.search('\sinet\ ([^\s]+)/', ip_addr).groups()[0]
	except AttributeError:
		ip_prefix_v4 = False
		ip_addr_v4 = False

	# MAC address
	ip_link = os.popen('ip link show dev ' + NETWORK_INTERFACE).read()

	try:
		ip_link_mac = re.search('.*ether\ ([^\s]+)', ip_link).groups()[0]
	except AttributeError:
		ip_link_mac = ""

	rec_info = os.popen('systemctl show video-recorder --property=ActiveState').read()
	if re.search('^ActiveState=active', rec_info) == None:
		rec = False
	else:
		rec = True

	# Prepare surface
	surface = pygame.Surface((300, 130))
	image = surface.convert()
	image.fill(BLACK)

	# Print output
	font = pygame.font.SysFont("monospace", 13, True)
	image.blit(font.render("hostname: " + hostname, 1, WHITE), (0, 0))

	if rec:
		if (pygame.time.get_ticks()/1000) % 2: # Print the recording symbol every odd second
			pygame.draw.circle(image, RED, (240, 7), 6)
		image.blit(font.render("RECORD", 1, RED), (250, 0))
	else:
		pygame.draw.line(image, WHITE, (235,3), (235,11), 2) # Pause symbol line 1
		pygame.draw.line(image, WHITE, (240,3), (240,11), 2) # Pause symbol line 1
		image.blit(font.render("PAUSED", 1, WHITE), (250, 0))

	image.blit(font.render("uptime: " + uptime_time + ", up " + uptime_duration, 1, WHITE), (0, 15))
	image.blit(font.render("load: " + uptime_avg1 + ", " + uptime_avg5 + ", " + uptime_avg15, 1, RED if float(uptime_avg1) > 1.95 else WHITE), (0, 30))

	if ip_addr_v4 != False:
		image.blit(font.render("IPv4: " + ip_prefix_v4, 1, WHITE), (0, 45))
		image.blit(font.render("stream: tcp://" + ip_addr_v4 + ":8898/", 1, WHITE), (0, 75))
	else:
		image.blit(font.render("IPv4: no IPv4 address", 1, RED), (0, 45))
		image.blit(font.render("stream: n/a", 1, RED), (0, 75))

	image.blit(font.render("MAC address: " + ip_link_mac, 1, WHITE), (0, 60))

	image.blit(font.render("Revision: " + GIT_REVISION, 1, WHITE), (0, 90))

	screen.blit(image,(10,120))

def signal_handler(signum, frame):
	# We need something to catch signals since systemd sends a SIGHUP, if we
	# don't catch that, we'll quit and die
	pass

if __name__=="__main__":
	signal.signal(signal.SIGHUP, signal_handler)
	main()
