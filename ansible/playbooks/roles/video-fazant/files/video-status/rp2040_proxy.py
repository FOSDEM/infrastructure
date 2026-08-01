#!/usr/bin/python3

import os
import serial
import re
import socket
import sys

sockname = "/dev/sock_fosdem_box_ctl"

serial = serial.Serial('/dev/tty_fosdem_box_ctl', 115200, timeout=1, exclusive=True)

listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
try:
	os.unlink(sockname)
except:
	pass
listener.bind(sockname)
listener.listen()

while True:
	data = []
	(conn, addr) = listener.accept()
	reader = conn.makefile(encoding='latin1')
	while True:
		l = reader.readline().encode('latin1')
		if len(l) == 0 or l == b"\n":
			break
		data.append(l)
		serial.write(l)
	while True:
		l = serial.readline()
		conn.send(l)
		if re.match(r"^(ok|fail)", l.decode("latin1").strip()):
			break
	reader.close()
	conn.close()
	
