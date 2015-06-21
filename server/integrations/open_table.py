import requests
import json

def find_open_table_url(restaurant):
	"""
	Given a restaurant from Google Places API response, returns mobile url for
	OpenTable reservation if it exists, otherwise results None
	"""
	try:
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
		restaurant_json = json.loads(response.text)

		resto = restaurant_json.get('restaurants')
		if resto:
			resto = resto[0]
		if resto:
			return resto.get('mobile_reserve_url')
		else:
			return None
	except:
		return None