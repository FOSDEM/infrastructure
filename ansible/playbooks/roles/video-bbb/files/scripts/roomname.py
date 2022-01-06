#! /usr/bin/python3
 
from slugify import slugify
import json
import os
import re
import socket
import sys
import wget
import xml.etree.ElementTree as ET 


fullhostname=socket.gethostname()
hostname= re.match('.*?-', fullhostname).group()[:-1]

penta_url = 'https://fosdem.org/2022/schedule/xml'        
if os.path.isfile(os.path.basename(penta_url)):
  penta = os.path.basename(penta_url)
else:
  penta = wget.download(penta_url)

pentaparse = ET.parse(penta).getroot()
'''Match only devrooms, keynotes, lightning talks, main tracks'''
pattern='^[D,K,L,M]'
fullrooms=sorted(list(set([r.get('name') for r in pentaparse.findall('.//room') if r.get('name') and re.match(pattern,r.get('name')) ])))

rooms=sorted(list(set([slugify(r.get('name'),separator='') for r in pentaparse.findall('.//room') if r.get('name') and re.match(pattern,r.get('name')) ])))

mappings= [(rooms[i], fullrooms[i]) for i in range(0, len(rooms))]


for m in mappings:
	if m[0] == hostname:
		print(m[1])
		sys.exit()
