import sys, getopt, codecs, json, requests
from itertools import groupby
from collections import namedtuple
import requests.packages.urllib3

Row = namedtuple("Row", ["userid", "vehicleid", "booking_ts",  "u_gps_latitude", "u_gps_longitude", "v_gps_latitude", "v_gps_longitude"])
api_key = 'AIzaSyDTIyx0KMQPCwlpMLLYqRmsdgiaROsOxEI'
url = "https://maps.googleapis.com/maps/api/distancematrix/json"

def requestGet(url, payload):

    r = requests.get(url, params=payload)
    return r.json()

UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
requests.packages.urllib3.disable_warnings()

for line in sys.stdin:
    row = Row(*line.rstrip().split("\t", 7))

    userLocation = str(row.u_gps_latitude) + ',' + str(row.u_gps_longitude)
    vehicleLocation = str(row.v_gps_latitude) + ',' + str(row.v_gps_longitude)

    payload = {'units':'metric',
            'mode':'walking',
            'origins':userLocation,
            'destinations':vehicleLocation,
            'key': api_key}

    ob = dataMetric = requestGet(url, payload)
    seconds = 0
    meters = 0
    if "duration" in ob["rows"][0]["elements"][0]:
	seconds = ob["rows"][0]["elements"][0]["duration"]["value"]
    if "distance" in ob["rows"][0]["elements"][0]:
    	meters = ob["rows"][0]["elements"][0]["distance"]["value"]

    print "\t".join([row.userid, row.vehicleid, row.booking_ts, row.u_gps_latitude, row.u_gps_longitude, row.v_gps_latitude, row.v_gps_longitude, str(seconds), str(meters)])
