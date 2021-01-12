#! /usr/bin/python3
 
from datetime import datetime
from dateutil import parser
from slugify import slugify
import argparse
import json
import os
import shutil
import subprocess
import sys
import wget
import xml.etree.ElementTree as ET 

penta_url = 'https://archive.fosdem.org/2020/schedule/xml'
timer_dir = '/etc/systemd/system'
timer_template_prefix = 'vocto-source-recording@'
video_cache_dir = '/opt/media/recordings'
timer_template = timer_template_prefix + '.timer'

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--room", help="the room name as seen in pentabarf xml", required=True)
args = parser.parse_args()
room = args.room

print("Checking if we have the schedule...")
if os.path.isfile(os.path.basename(penta_url)):
    penta = os.path.basename(penta_url)
else:
    print("Getting the schedule...")
    penta = wget.download(penta_url)

print("Parsing the schedule file...")
pentaparse = ET.parse(penta).getroot()

print('Getting events for room '+ room)
xpath_string='.//event[room="'+room+'"]'
events= [e.get('id') for e in pentaparse.findall(xpath_string)]

print('Creating systemd timer OnCalendar overrides for events in room '+ room)
for e in events:
    xpath_string=".//event[@id='" + e + "']...."
    date = pentaparse.find(xpath_string).get('date')
    xpath_string=".//event[@id='" + e + "']/start"
    time = pentaparse.find(xpath_string).text + ':00'
    dt = date + ' ' + time
    # TODO. Remove replace(year=2021) once the actual programme is coming together
    date = datetime.strptime(dt, '%Y-%m-%d %H:%M:%S').replace(year=2021)
    output = '[Timer]\nOnCalendar=\nOnCalendar=' + str(date)
    timer_override_dir= timer_dir + '/' + timer_template_prefix + e + '.timer.d'

    try:
        os.makedirs(timer_override_dir, mode=0o755)
    except:
        pass

    f = open(timer_override_dir+ '/'+ 'OnCalendar.conf', 'w')
    f.write(output)
    f.close()

print('Start timers')
subprocess.check_call(['systemctl', 'enable', timer_template ])
for e in events:
    timer = timer_template_prefix + e + '.timer'
    # TODO. Naive. If an event has already been deleted from penta, this will not stop the old one from appearing at the same time as the new one. Dangerous!
    subprocess.check_call(['systemctl', 'stop', timer ])
    subprocess.check_call(['systemctl', 'disable', timer ])
    subprocess.check_call(['systemctl', 'disable', timer_template ])
    subprocess.check_call(['systemctl', 'enable', timer_template ])
    subprocess.check_call(['systemctl', 'enable',  timer ])
    subprocess.check_call(['systemctl', 'start', timer ])
