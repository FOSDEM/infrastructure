#!/usr/bin/env python2

import signal, sys, os, curses

def signal_handler(signum, frame):
	curses.endwin()
	sys.exit(0)

def play(key):
	screen.addstr(12, 0, "Sending " + key + "...")
	screen.clrtoeol()
	screen.refresh()

	path = os.path.dirname(__file__)
	os.system("aplay -q " + path + "/lenkengir/" + key + ".wav")

	screen.addstr(12, 0, "Sent " + key)
	screen.clrtoeol()
	screen.refresh()

signal.signal(signal.SIGINT, signal_handler)

screen = curses.initscr()
curses.cbreak()
curses.noecho()

screen.keypad(1)

screen.addstr(0, 0, "Lenkeng IR remote control")
screen.addstr(2, 0, "left/right/down/up: use keypad")
screen.addstr(3, 0, "input: i")
screen.addstr(4, 0, "720p/1080p: r")
screen.addstr(5, 0, "menu: m")
screen.addstr(6, 0, "ok: enter")
screen.addstr(7, 0, "exit: x")

screen.addstr(9, 0, "quit: q")

screen.addstr(12, 0, "")

screen.refresh()

key = ''
while key != ord('q'):
	key = screen.getch()
	screen.refresh()

	if key == curses.KEY_LEFT:
		play("left")
	elif key == curses.KEY_RIGHT:
		play("right")
	elif key == curses.KEY_UP:
		play("up")
	elif key == curses.KEY_DOWN:
		play("down")
	elif key == curses.KEY_ENTER or key == 10 or key == 13:
		play("ok")
	elif key == ord("i"):
		play("input")
	elif key == ord("r"):
		play("720-1080")
	elif key == ord("m"):
		play("menu")
	elif key == ord("x"):
		play("exit")

	screen.refresh()

curses.endwin()
