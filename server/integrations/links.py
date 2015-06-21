import requests
import json
from integrations.open_table import find_open_table_url
from integrations.foursquare import find_foursquare_url

def find_active_links(lat, lon, place, name):
	"""
	Given a latitude, longitude and the name of a restaurant or a bar from Google Places API
	response, returns mobile url for Foursquare
	"""
	WIKIPEDIA_BASE = 'https://wikipedia.org/wiki/Special:Search/'
	links = {}
	links["wikipediaUrl"] = WIKIPEDIA_BASE + name

	try:
		fsqReturn = find_foursquare_url(lat, lon, name)
		foursquareVenueId = fsqReturn['venueId']
		foursquareUrl = fsqReturn['4sqUrl']
		website = fsqReturn['url']

		if foursquareUrl is not None:
			links['foursquareUrl'] = foursquareUrl

		if foursquareVenueId is not None:
			links['foursquareVenueId'] = foursquareVenueId

		if website is not None:
			links['url'] = website

	except:
		print "foursquare failed"

	try:
		openTableUrl = find_open_table_url(place)
		if openTableUrl is not None:
			links['openTableUrl'] = openTableUrl

	except: 
		print "opentable failed"

	return links


# Sample response object from Google Places API
# name: "Shake Shack", lat: 40.77912606570555, lon: -73.95490489457822