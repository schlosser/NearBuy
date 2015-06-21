from app import db
from datetime import datetime


class Deal(db.Document):
    title = db.StringField(required=True, max_length=50)
    date_created = db.DateTimeField(required=True)
    body = db.StringField(required=True)
    offer_code = db.StringField(required=True, max_length=50)
    place_id = db.StringField(required=True, max_length=50)

    def clean(self):
        self.date_created = datetime.now()

    def json(self):
        return {
            'title': self.title,
            'body': self.body,
            'offer_code': self.offer_code,
            'place_id': self.place_id
        }
