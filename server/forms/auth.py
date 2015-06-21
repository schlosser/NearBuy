from flask_wtf import Form
from flask_wtf.html5 import EmailField
from wtforms import PasswordField, StringField
from wtforms.validators import Email, DataRequired, EqualTo


class LoginForm(Form):
    email = EmailField('email', validators=[Email(), DataRequired()])
    password = PasswordField('password', validators=[DataRequired()])


class SignupForm(Form):
    first_name = StringField('first_name', validators=[DataRequired()])
    last_name = StringField('first_name', validators=[DataRequired()])
    email = EmailField('email', validators=[Email(), DataRequired()])
    password = PasswordField(
        'password',
        validators=[
            DataRequired(),
            EqualTo('password_confirm', message='Passwords must match')])
    password_confirm = PasswordField('password')
    restaurant_name = StringField('restaurant_name',
                                  validators=[DataRequired()])
