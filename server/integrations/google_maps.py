from utils.json_response import json_success, json_error_message
from config.secrets import GOOGLE_API_KEY
import requests

API_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
RADIUS = 500  # meters
TYPES = '|'.join([
    'bakery',
    'bar',
    'cafe',
    'food',
    'grocery_or_supermarket',
    'meal_delivery',
    'meal_takeaway'
])


def nearby_places(lat, lon):
    params = {
        'key': GOOGLE_API_KEY,
        'location': '{lat},{lon}'.format(lat=lat,
                                         lon=lon),
        'radius': RADIUS,
        'types': TYPES
    }
    response = requests.get(API_URL, params=params)
    if not response.ok:
        return json_error_message("Google Places API request failed",
                                  error_data=response.json())
    return json_success(response.json()['results'])
