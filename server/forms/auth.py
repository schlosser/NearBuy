from flask_wtf import Form
from flask_wtf.html5 import EmailField
from wtforms import PasswordField
from wtforms.validators import Email, DataRequired


class LoginForm(Form):
    email = EmailField('email', validators=[Email(), DataRequired()])
    password = PasswordField('password', validators=[DataRequired()])
