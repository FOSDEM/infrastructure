#! /usr/bin/python3
 
from datetime import datetime, timedelta
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

penta_url = 'https://fosdem.org/2021/schedule/xml'
timer_dir = '/etc/systemd/system'
recording_timer_template_prefix = 'vocto-source-recording@'
video_cache_dir = '/opt/media/recordings'
endtimes_dir = '/opt/config/endtimes'
recording_timer_template = recording_timer_template_prefix + '.timer'
slide_timer_template_prefix = 'vocto-source-slide@'
slide_timer_template = slide_timer_template_prefix+ '.timer'

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
    date = datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
    #date+= timedelta(weeks=-1)

    # Recordings
    output = '[Timer]\nOnCalendar=\nOnCalendar=' + str(date)
    recording_timer_override_dir= timer_dir + '/' + recording_timer_template_prefix + e + '.timer.d'

    try:
        os.makedirs(recording_timer_override_dir, mode=0o755)
    except:
        pass

    f = open(recording_timer_override_dir+ '/'+ 'OnCalendar.conf', 'w')
    f.write(output)
    f.close()

    # End times

    xpath_string=".//event[@id='" + e + "']/duration"
    durationstring = pentaparse.find(xpath_string).text
    dd= datetime.strptime(durationstring,'%H:%M')
    duration=timedelta(hours=dd.hour,minutes=dd.minute)
    enddate=date+duration
    endtime=str(int(enddate.timestamp()))

    try:
        os.makedirs(endtimes_dir, mode=0o755)
    except:
        pass

    f = open(endtimes_dir+ '/'+ e, 'w')
    f.write(endtime)
    f.close()

    # Slides
    date+= timedelta(minutes=-5)
    output = '[Timer]\nOnCalendar=\nOnCalendar=' + str(date)
    slide_timer_override_dir= timer_dir + '/' + slide_timer_template_prefix + e + '.timer.d'

    try:
        os.makedirs(slide_timer_override_dir, mode=0o755)
    except:
        pass

    f = open(slide_timer_override_dir+ '/'+ 'OnCalendar.conf', 'w')
    f.write(output)
    f.close()

print('Start recording timers')
subprocess.check_call(['systemctl', 'enable', recording_timer_template ])
for e in events:
    timer = recording_timer_template_prefix + e + '.timer'
    # TODO. Naive. If an event has already been deleted from penta, this will not stop the old one from appearing at the same time as the new one. Dangerous!
    subprocess.check_call(['systemctl', 'stop', timer ])
    subprocess.check_call(['systemctl', 'disable', timer ])
    subprocess.check_call(['systemctl', 'disable', recording_timer_template ])
    subprocess.check_call(['systemctl', 'enable', recording_timer_template ])
    subprocess.check_call(['systemctl', 'enable',  timer ])
    subprocess.check_call(['systemctl', 'start', timer ])

print('Start slides timers')
subprocess.check_call(['systemctl', 'enable', slide_timer_template ])
for e in events:
    timer = slide_timer_template_prefix + e + '.timer'
    # TODO. Naive. If an event has already been deleted from penta, this will not stop the old one from appearing at the same time as the new one. Dangerous!
    subprocess.check_call(['systemctl', 'stop', timer ])
    subprocess.check_call(['systemctl', 'disable', timer ])
    subprocess.check_call(['systemctl', 'disable', slide_timer_template ])
    subprocess.check_call(['systemctl', 'enable', slide_timer_template ])
    subprocess.check_call(['systemctl', 'enable',  timer ])
    subprocess.check_call(['systemctl', 'start',  timer ])
 
