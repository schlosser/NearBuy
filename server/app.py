from flask import Flask, request
from utils.json_response import json_success, json_error_message
from integrations.google_maps import nearby_places
app = Flask(__name__)


@app.route('/')
def main():
    return json_success({
        'response': 'Hello World'
    })


@app.route('/places')
def places():
    lat = float(request.args.get('lat'))
    lon = float(request.args.get('lon'))
    if lat is None or lon is None:
        return json_error_message("Must provide lat and lon")
    return nearby_places(lat, lon)


if __name__ == '__main__':
    debug = len(argv) == 2 and argv[1] == 'debug'
    app.run(port=5050, debug=debug)
