from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import os
from token_validator.tv import token_required

inputsPage = Blueprint("inputsPage", __name__, url_prefix="/inputs")

SECRET_KEY = os.getenv("SECRET_KEY")  # for JWT

@inputsPage.route('/')
def inputs():
    print('a')
    return

@inputsPage.route('/insertzFood')
@token_required
def insertOrders():
    data = request.json
    user_id = request.user_id
    return

@inputsPage.route('/insertPref')
@token_required
def insertPref():
    data = request.json
    user_id = request.user_id
    return

@inputsPage.route('/removePref')
@token_required
def removePref():
    data = request.json
    user_id = request.user_id
    return


@inputsPage.route('/analyze')
@token_required
def analyze():
    data = request.json
    user_id = request.user_id
    return