from flask_wtf import Form
from wtforms import StringField, TextAreaField
from wtforms.validators import DataRequired, Length


class DealForm(Form):
    title = StringField('email', validators=[DataRequired(), Length(max=50)])
    body = TextAreaField('body', validators=[DataRequired()])
    offer_code = StringField('offer_code', validators=[Length(max=50)])
