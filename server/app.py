from flask import Flask, request
from sys import argv
app = Flask(__name__)


@app.route('/')
def main():
    return "Hello World"


@app.route('/places')
def places():
    lat = request.args.get('lat')
    lon = request.args.get('lon')
    return 'lat: %s\nlon: %s' % (lat, lon)

if __name__ == '__main__':
    debug = len(argv) == 2 and argv[1] == 'debug'
    app.run(debug=debug)
