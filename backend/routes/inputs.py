from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import os
from backend.token_validator.tv import *
from logic.logic import *
import datetime

inputsPage = Blueprint("inputsPage", __name__, url_prefix="/inputs")

SECRET_KEY = os.getenv("SECRET_KEY")  # for JWT

@inputsPage.route('/')
def inputsP():
    print('a')
    return jsonify("PP")

@inputsPage.route('/insertFood')
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
    
    print('items_db', 'SELECT * FROM %s WHERE user_id=%s', False, params=['items_db', user_id,])
    
    nitems = []
    # Updated SQL query to include timestamp_column (or the actual column that stores the timestamp)
    items = get_connection('SELECT i.food_name, i.cost, CASE WHEN fp.food_name IS NOT NULL THEN TRUE ELSE FALSE END AS is_preferred, i.timestamp_column FROM items_db i LEFT JOIN FOOD_PREFERENCES fp ON i.food_name = fp.food_name AND i.user_id = fp.user_id WHERE i.user_id = %s;', False, params=[user_id])
    # Append items to nitems
    for i in items:
        nitems.append([i[0], i[1], i[2]])

    # Get today's date (current date)
    today = datetime.date.today()

    # Calculate the start of this week and the start of last week
    start_of_this_week = today - datetime.timedelta(days=today.weekday())  # Monday of this week
    start_of_last_week = start_of_this_week - datetime.timedelta(weeks=1)   # Monday of last week

    # Initialize lists for this week's and last week's items
    this_week_items = []
    last_week_items = []

    # Loop through the items and split them based on their timestamp
    for item in items:
        food_name, cost, i_preferred, timestamp = item  # timestamp_column should be in your result now
        item_date = timestamp.date()  # Convert timestamp to datse

        # Check if the item is from this week
        if start_of_this_week <= item_date < start_of_this_week + datetime.timedelta(weeks=1):
            this_week_items.append(item)

        # Check if the item is from last week
        elif start_of_last_week <= item_date < start_of_last_week + datetime.timedelta(weeks=1):
            last_week_items.append(item)

    # Assuming analyze_spending and waste_calculator are valid functions
    return jsonify(analyze_spending(items, waste_calculator(last_week_items), waste_calculator(this_week_items)))