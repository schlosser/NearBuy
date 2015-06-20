from flask import Flask, request
app = Flask(__name__)


@app.route('/')
def main():
    return "Hello World"

@app.route('/places')
def places():
    lat = request.args.get('lat')
    lon = request.args.get('lon')

if __name__ == '__main__':
    app.run()
