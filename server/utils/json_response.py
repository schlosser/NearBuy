from flask import make_response
import json


def json_response(data, code):
    """Return a :class:`flask.Response` with a JSON encoded object ``data`` in
    the body.
    """
    text = json.dumps(data)
    response = make_response(text, code)
    response.headers['Content-Type'] = 'application/json'
    return response


def json_success(data, code=200):
    """Return a :class:`flask.Response` with a JSON error message in the body.
    """
    return json_response({
        'status': 'success',
        'data': data
    }, code)


def json_error_message(error_message, code=400, error_data=None):
    """Return a :class:`flask.Response` with a JSON error message in the body.
    """
    if error_data is None:
        error_data = {}  # error_data should always be a dictionary

    return json_response({
        'status': 'error',
        'error': {
            'message': error_message,
            'code': code,
            'data': error_data
        }
    }, code)
