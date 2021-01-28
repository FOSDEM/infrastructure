#! /usr/bin/python3
 
import argparse
import os
import re
import shutil
import subprocess
import sys
import wget
import xml.etree.ElementTree as ET 

penta_url = 'https://fosdem.org/2021/schedule/xml'
video_cache_dir = '/opt/media/preroll'

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
events= [e for e in pentaparse.findall(xpath_string)]

for e in events:
  with open('/tmp/fosdem_preroll_template.svg', 'r') as f:
    t=f.read()

  print("Creating preroll slide for talk "+ str(e.get('id')))
  basename='/tmp/preroll'+ e.get('id')
  if e.find('title').text is not None:
      talk_title= e.find('title').text
  else:
      talk_title= ' '

  if e.find('subtitle').text is not None:
      talk_subtitle= e.find('subtitle').text
  else:
      talk_subtitle= ' '

  if e.find('track').text is not None:
      talk_track= e.find('track').text
  else:
      talk_track= ' '

  if e.findall('persons/person') is not None:
      talk_speakers= "".join([p.text+'  ' for p in e.findall('persons/person')])
  else:
      talk_speakers= ' '

  for r in (("talk_title", talk_title),("talk_subtitle", talk_subtitle), ("talk_track", talk_track), ("talk_speakers", talk_speakers)):
      t = t.replace(*r)

  i=open(basename+ '.svg', 'w')
  i.write(t)
  i.close()
  f.close()

  p=subprocess.run(['/usr/bin/inkscape', basename+'.svg', '--export-png', basename+ '.png'])
  p=subprocess.run(['/usr/bin/ffmpeg', '-i', basename+'.png', '-c:v', 'rawvideo', '-pix_fmt:v', 'yuv420p', '-c:v', 'rawvideo', '-pix_fmt', 'yuv420p', '-frames', '1', '-f', 'rawvideo', basename+'.raw'])

