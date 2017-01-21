#!/usr/bin/env python3
#
# Description: Convert ipmitool sensor output to Prometheus text.
# Author: Ben Kochie <superq@gmail.com>

import subprocess
import sys

sensor_cmd = ['ipmitool', 'sensor']
# sensor_cmd = ['cat', 'sensor']

def get_sensor_data():
    try:
        sensors = subprocess.check_output(sensor_cmd, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError as e:
        return None
    return sensors.decode()

# Row format example
#     Sensor ID             : Baseboard 1.25V (0x10)
#     Sensor Reading        : 1.245 (+/- 0.039) Volts
#     Sensor Type (Analog)  : Voltage
#     Status                : ok
#     Lower Non-Recoverable : na
#     Lower Critical        : 1.078
#     Lower Non-Critical    : 1.107
#     Upper Non-Critical    : 1.382
#     Upper Critical        : 1.431
#     Upper Non-Recoverable : na

def print_prometheus(metric, values):
    print("# HELP ipmi_sensor_%s IPMI Metric for %s" % (metric, metric))
    print("# TYPE ipmi_sensor_%s gauge" % (metric))
    for key in values:
        print("ipmi_sensor_%s{sensor=\"%s\"} %f" % (metric, key, values[key]))


def main(argv):
    metrics = {'fan': {}, 'temp': {}}
    sensors = get_sensor_data()
    for line in sensors.split('\n'):
        row = line.split('|')
        sensor = row[0].strip()
        if sensor.startswith('Fan '):
            num = sensor.split(' ')[1]
            metrics['fan'][num] = float(row[1])
        elif sensor.startswith('Temp '):
            num = sensor.split(' ')[1]
            metrics['temp'][num] = float(row[1])

    print_prometheus('fan_speed_percent', metrics['fan'])
    print_prometheus('temp_celcius', metrics['temp'])

if __name__ == "__main__":
     main(sys.argv[1:])
