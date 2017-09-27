import sys, getopt, codecs, json, requests, time
from itertools import groupby
from collections import namedtuple
import requests.packages.urllib3
Row = namedtuple("Row", ["userid", "vehicleid", "creation_ts", "u_gps_latitude", "u_gps_longitude", "v_gps_latitude", "v_gps_longitude"])
api_key = 'AIzaSyDxTrHf7jskfCTyBICMRASspMaXV3qR4n4'
url = "https://maps.googleapis.com/maps/api/distancematrix/json"

def readData(inData):
    for line in inData:
        yield Row(*line.rstrip().split("\t", 7))

def requestGet(url, payload):
    r = requests.get(url, params=payload)
    return r.json()

def emitRow(rows, userLocation, vehicleLocation):
    payload = {'units':'metric',
            'mode':'walking',
            'origins':userLocation,
            'destinations':vehicleLocation,
            'key': api_key}
    ob = requestGet(url, payload)
    seconds = 0
    meters = 0
    counter = 0
    for row in rows:
        v_gps_latitude = row.v_gps_latitude
        v_gps_longitude = row.v_gps_longitude
        if v_gps_longitude > v_gps_latitude:
            v_gps_latitude = v_gps_longitude
            v_gps_longitude = row.v_gps_latitude
        if str(v_gps_latitude) != '0.0':
          try:
              if "duration" in ob["rows"][0]["elements"][counter]:
                  seconds = ob["rows"][0]["elements"][counter]["duration"]["value"]
              if "distance" in ob["rows"][0]["elements"][counter]:
                  meters = ob["rows"][0]["elements"][counter]["distance"]["value"]
              print "\t".join([row.userid, row.vehicleid, row.creation_ts, row.u_gps_latitude, row.u_gps_longitude, v_gps_latitude, v_gps_longitude, str(seconds), str(meters)])
              counter = counter + 1
          except:
              print ob
              print counter
              sys.exit(1)

UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)
requests.packages.urllib3.disable_warnings()
for key, i in groupby(readData(sys.stdin), key=lambda row: (row.userid)):
    rows = []
    vehicleLocation = ''
    userLocation = ''
    for row in i:
        rows.append(row)
        userLocation = str(row.u_gps_latitude) + ',' + str(row.u_gps_longitude)
        v_gps_latitude = row.v_gps_latitude
        v_gps_longitude = row.v_gps_longitude
        if v_gps_longitude > v_gps_latitude:
            v_gps_latitude = v_gps_longitude
            v_gps_longitude = row.v_gps_latitude
        if str(v_gps_latitude) != '0.0':
            if vehicleLocation == '':
                vehicleLocation = str(v_gps_latitude) + ',' + str(v_gps_longitude)
            else:
                vehicleLocation = vehicleLocation + '|' + str(v_gps_latitude) + ',' + str(v_gps_longitude)
        if len(rows) == 15:
            emitRow(rows, userLocation, vehicleLocation)
            rows = []
            time.sleep(1)
	    vehicleLocation = ''

    emitRow(rows, userLocation, vehicleLocation)
    vehicleLocation = ''
