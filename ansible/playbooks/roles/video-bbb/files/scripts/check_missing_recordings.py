#! /usr/bin/python3

'''
Checks for missing prerecorded video files against penta xml for room. 
'''
 
import argparse
import json
import os
import sys
import time
import wget
import xml.etree.ElementTree as ET 

penta_url = 'https://fosdem.org/2021/schedule/xml'
video_cache_dir = '/mnt/video/'

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--room", help="the room name as seen in pentabarf xml", required=True)
args = parser.parse_args()
room = args.room

# Check if we have a recent schedule
if os.path.isfile(os.path.basename(penta_url)):
    # Remove stale schedule
    if (time.time()-(os.path.getmtime(os.path.basename(penta_url))) < 300):
        penta = os.path.basename(penta_url)
    else:
        os.remove(os.path.basename(penta_url))

if not os.path.isfile(os.path.basename(penta_url)):
    penta = wget.download(penta_url)

# Parsing the schedule file
pentaparse = ET.parse(penta).getroot()

# Getting events for room
xpath_string='.//event[room="'+room+'"]'
events= [e.get('id') for e in pentaparse.findall(xpath_string)]

missing_videos=[e for e in events if not os.path.isfile(video_cache_dir + e + ".mp4")]

for v in missing_videos:
    print(v) 

'''
Json output alternative:
with open('/tmp/missing_videos.json', 'w') as json_file:
   json.dump(missing_events, json_file)
'''
