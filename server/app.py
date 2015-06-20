from flask import Flask, request
from utils.json_response import json_success, json_error_message
from sys import argv
app = Flask(__name__)


@app.route('/')
def main():
    return json_success({
        'response': 'Hello World'
    })


@app.route('/places')
def places():
    lat = request.args.get('lat')
    lon = request.args.get('lon')
    if lat is None or lon is None:
        return json_error_message("Must provide lat and lon")
    return json_success({
        'lat': lat,
        'lon': lon
    })


@app.route('/actions')
def actions():
    place_id = request.args.get('place_id')
    return 'place_id: %s' % place_id


if __name__ == '__main__':
    debug = len(argv) == 2 and argv[1] == 'debug'
    app.run(debug=debug)
