from utils.json_response import json_success, json_error_message
from config.secrets import GOOGLE_API_KEY
from integrations.open_table import find_open_table_url
from math import sin, cos, atan2, pi, ceil
import requests

NUM_DEGREES = 360
API_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
RADIUS = 500  # meters
TYPES = '|'.join([
    'bakery',
    'bar',
    'cafe',
    'food',
    'grocery_or_supermarket',
    'meal_delivery',
    'meal_takeaway',
    'movie_theater'
])


def get_resource(lat, lon, place):
    return {
        'name': place['name'],
        'place_id': place['place_id'],
        'bearing': get_bearing(lat, lon, place),
        'open_table_url': find_open_table_url(place)
    }


def get_bearing(my_lat, my_lon, place):
    place_lat = place['geometry']['location']['lat']
    place_lon = place['geometry']['location']['lng']

    # Calculate the bearing using:
    # http://www.ig.utexas.edu/outreach/googleearth/latlong.html
    delta_lon = place_lon - my_lon
    bearing = atan2(sin(delta_lon) * cos(place_lat),
                    (cos(my_lat) * sin(place_lat) -
                     sin(my_lat) * cos(place_lat) * cos(delta_lon)))
    # return bearing as and integer number of degrees
    return (bearing / pi * 180) % 360


def generate_map(lat, lon, results):

    # Find all the links / metadata to be passed to the client for each result
    resources = (get_resource(lat, lon, place) for place in results)

    # Pairs of (resource, int(round(bearing)))
    rb_pairs = [(resource, int(round(resource['bearing']))) for resource in resources]
    print "Got links and angles..."

    # Sort the pairs by bearing
    rb_pairs.sort(key=lambda lna: lna[1])
    print rb_pairs

    # Empty map
    map = [None] * NUM_DEGREES
    print "Generating map..."

    first_resource, first_bearing = rb_pairs[0]
    last_resource, last_bearing = rb_pairs[-1]
    first_midpoint = int((
        last_bearing +
        ceil((NUM_DEGREES - last_bearing + first_bearing) / 2)
    ) % NUM_DEGREES)
    print first_bearing, last_bearing, first_midpoint
    if first_midpoint < first_bearing:
        for a in range(first_midpoint) + range(last_bearing, NUM_DEGREES):
            map[a] = last_resource['place_id']
        previous_midpoint = first_midpoint
    else:
        for a in range(last_bearing, first_midpoint):
            map[a] = last_resource['place_id']
        for a in range(first_midpoint, NUM_DEGREES):
            map[a] = first_resource['place_id']
        previous_midpoint = 0

    for i in range(0, len(rb_pairs) - 1):
        links, this_angle = rb_pairs[i]
        next_angle = rb_pairs[(i + 1) % len(rb_pairs)][1]
        midpoint = int(this_angle + ceil((next_angle - this_angle) / 2))
        for a in range(previous_midpoint, midpoint):
            map[a] = links['place_id']
        previous_midpoint = midpoint

    for a in range(midpoint, last_bearing):
        map[a] = last_resource['place_id']

    data = dict((links['place_id'], links) for links, _ in rb_pairs)

    return {
        "map": map,
        "data": data
    }


def nearby_places(lat, lon):
    params = {
        'key': GOOGLE_API_KEY,
        'location': '{lat},{lon}'.format(lat=lat, lon=lon),
        'rankby': 'distance',
        'types': TYPES
    }
    response = requests.get(API_URL, params=params)

    # Request failed
    if not response.ok:
        print "[PLACES] failed: ", response.json()
        return json_error_message("Google Places API request failed",
                                  error_data=response.json())

    results = response.json()['results']

    # No results found
    if len(results) == 0:
        print "[PLACES] no results found,"
        return json_error_message("No places found near this location.")

    print "Found {} Places at {},{}".format(len(results), lat, lon)
    return json_success(generate_map(lat, lon, results))
