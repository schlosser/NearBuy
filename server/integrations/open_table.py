import requests
import json

def find_open_table_url(restaurant):
	"""
	Given a restaurant from Google Places API response, returns mobile url for
	OpenTable reservation if it exists
	"""
	name = restaurant.get('name').replace('&', 'and').replace(' ', '+')
	vicinity = restaurant.get('vicinity')
	(address, city) = vicinity.split(',')
	address = address.replace(' ', '+')
	city = city.lstrip().replace(' ', '+')

	ot_url = 'http://opentable.herokuapp.com/api/restaurants?'
	if name:
		ot_url += ('name=' + name + '&')
	if vicinity:
		ot_url += ('address=' + address + '&city=' + city)

	response = requests.get(ot_url)
	restaurant_json = json.loads(response.text).get('restaurants')[0]

	return restaurant_json.get('mobile_reserve_url')