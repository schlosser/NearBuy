import requests
import json

def find_location_website(place):
	"""
	Given a place from Google Places API response, returns the top url for a
	Google web search
	"""
	name = place.get('name').replace('&', 'and').replace(' ', '+')
	vicinity = place.get('vicinity')
	(address, city) = vicinity.split(',')
	address = address.replace(' ', '+')
	city = city.replace(' ', '+')

	query = (name + '+' + address + '+' + city)
	search_url = 'https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q='+query

	response = requests.get(search_url)
	json_result = json.loads(response.text).get('responseData').get('results')[0]

	return json_result.get('url')

