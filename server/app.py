from flask import (Flask, request, render_template, flash, redirect,
                   url_for)
from flask.ext.mongoengine import MongoEngine
from flask.ext.login import LoginManager
from integrations.google_maps import nearby_places
from utils.json_response import json_success, json_error_message
from config.secrets import SECRET_KEY
from forms.auth import LoginForm
from forms.deals import DealForm
from bson.objectid import ObjectId
from sys import argv
import json
import random

PLACE_ID = 'ChIJqRJTizv2wokRwg_FF-6pYuU'
db = MongoEngine()
login_manager = LoginManager()
app = Flask(__name__)
app.config['MONGODB_SETTINGS'] = {
    'db': 'b14s'
}
app.config['SECRET_KEY'] = SECRET_KEY

login_manager.init_app(app)
db.init_app(app)

debug = len(argv) == 2 and argv[1] == 'debug'

test_data = None
if debug:
    with open('test/test_data.json', 'r') as f:
        test_data = json.loads(f.read())['results']


@app.route('/')
def main():
    flash('Hello!')
    return render_template('index.html')


@app.route('/places')
def places():
    lat = request.args.get('lat')
    lon = request.args.get('lon')
    if lat is None or lon is None:
        return json_error_message("Must provide lat and lon")
    return nearby_places(float(lat), float(lon))


@app.route('/deals')
def deals():
    from models.deal import Deal
    lat = request.args.get('lat')
    lon = request.args.get('lon')
    if lat is None or lon is None:
        return json_error_message("Must provide lat and lon")
    return json_success([deal.json() for deal in Deal.objects()])


@app.route('/login', methods=['GET', 'POST'])
def login():
    # Here we use a class of some kind to represent and validate our
    # client-side form data. For example, WTForms is a library that will
    # handle this for us.
    form = LoginForm()
    if form.validate_on_submit():
        # TODO: Login and validate the user.
        # login_user(user)

        flash('Logged in successfully.')

        next = request.args.get('next')
        # if not next_is_valid(next):
        #     return abort(400)

        return redirect(next or url_for('admin'))
    print "fail!", form.errors
    return render_template('login.html', form=form)


@app.route('/admin', methods=['GET', 'POST'])
def admin():
    from models.deal import Deal
    form = DealForm()
    if form.validate_on_submit():
        offer_code = (form.offer_code.data
                      if form.offer_code.data
                      else _generate_random_offer_code())
        deal = Deal(title=form.title.data,
                    body=form.body.data,
                    offer_code=offer_code,
                    place_id=PLACE_ID)
        deal.save()
        flash("Submitted!")
        redirect(url_for('admin'), code=303)

    deals = Deal.objects().order_by("-date_created")
    return render_template('admin.html', form=form, deals=deals)


def _generate_random_offer_code():
    return ''.join(random.choice('0123456789ABCDEF') for n in xrange(8))


@login_manager.user_loader
def load_user(userid):
    from models.user import User
    return User.objecst.get(id=ObjectId(userid))


if __name__ == '__main__':
    app.run(port=5050, debug=debug)
