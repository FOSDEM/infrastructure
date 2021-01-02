#! /usr/bin/python3
 
from slugify import slugify
import json
import os
import sys
import wget
import xml.etree.ElementTree as ET 



penta_url = 'https://fosdem.org/2021/schedule/xml'        
print("Checking if we have the schedule...")
if os.path.isfile(os.path.basename(penta_url)):
  penta = os.path.basename(penta_url)
else:
  print("Getting the schedule...")
  penta = wget.download(penta_url)

print("Parsing the schedule file...")
pentaparse = ET.parse(penta).getroot()
rooms=sorted(list(set([slugify(r.get('name')) for r in pentaparse.findall('.//room') if r.get('name')])))

output=''

print('Creating ansible host entries')
for r in rooms:
    output += r+'-vocto.video.fosdem.org\n'

f = open('/tmp/ansible_hosts_voctos', 'w')
f.write(output)
f.close()

output=''
print('Creating ansible group_vars/video.yml')
for r in rooms:
    output += '- ' + r + '\n'

f = open('/tmp/video.yml', 'w')
f.write(output)
f.close()
