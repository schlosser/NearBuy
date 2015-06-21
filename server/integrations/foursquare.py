import requests
import json
from config.secrets import FOURSQUARE_CLIENT_ID, FOURSQUARE_CLIENT_SECRET

def find_foursquare_url(lat, lon, name):
	"""
	Given a latitude, longitude and the name of a restaurant or a bar from Google Places API
	response, returns mobile url for Foursquare
	"""
	try:
		SEARCH_API_URL = 'https://api.foursquare.com/v2/venues/search'
		VENUE_API_URL = 'https://api.foursquare.com/v2/venues/'

		params = {
	        'client_id': FOURSQUARE_CLIENT_ID,
	        'client_secret' : FOURSQUARE_CLIENT_SECRET,
	        'll': '{lat},{lon}'.format(lat=lat, lon=lon),
	        'radius': '100',
	        'v': '20141016',
	        'query': name,
	        'limit': '1',
	        'intent': 'match'
	    }
		response = requests.get(SEARCH_API_URL, params=params)

		# Request failed
		if not response.ok:
			print "[FOURSQUARE] failed: ", response.json()
			return json_error_message("FOURSQUARE API request failed",
	                                  error_data=response.json())
		
		result = response.json()['response']['venues']
		if len(result) == 0:
			return

		venueId = result[0]['id']

		# No results found
		if len(result) == 0:
			print "[FOURSQUARE] no results found,"
			return json_error_message("No places found near this location.")

		venueParams = {
	        'client_id': FOURSQUARE_CLIENT_ID,
	        'client_secret' : FOURSQUARE_CLIENT_SECRET,
	        'v': '20141016'
	    }
		venueResponse = requests.get(VENUE_API_URL+venueId, params=venueParams).json()['response']['venue']
		shortUrl = venueResponse['shortUrl']

		return {
	        "4sqUrl": shortUrl,
	        "url": venueResponse.get('url'),
	        "venueId": venueId
	    }
	except:
		return None
# Sample response object from Google Places API
# name: "Shake Shack", lat: 40.77912606570555, lon: -73.95490489457822