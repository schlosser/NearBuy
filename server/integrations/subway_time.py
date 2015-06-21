import requests
import json
from datetime import datetime
import operator

from station_dict import STATION_DICT

def find_subway_time(station):
	"""
	Given a NYC subway station Google Places result, returns the number of
	minutes until the next train comes
	"""
	name = station.get('name')
	if name not in STATION_DICT.keys():
		return None

	station_id = STATION_DICT[name]

	sub_url = 'http://mtaapi.herokuapp.com/api?id=' + station_id

	response = requests.get(sub_url)
	subway_json = json.loads(response.text)
	arrivals = subway_json.get('result').get('arrivals')
	if not arrivals:
		return None

	sp_arrivals = [arr.split(':') for arr in arrivals]
	now = datetime.now().strftime("%H:%M:%S").split(':')
	sub = [[int(arr[i]) - int(now[i]) for i in range(3) if ((int(arr[0]) - int(now[0])) == 0 or (int(arr[0]) - int(now[0])) == 1)] for arr in sp_arrivals]
	sorted_diffs = sorted(sub)
	print sorted_diffs

	minutes = -1
	for diff in [d for d in sorted_diffs if d]:
		if diff[0] == 0:
			minutes = diff[1]
			if minutes > 0:
				break
			continue
		if diff[0] == 1:
			minutes = int(diff[1]) + 60
			break

	return minutes