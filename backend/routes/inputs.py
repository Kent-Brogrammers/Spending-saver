from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import os
from token_validator.tv import token_required
from logic.logic import *
import datetime

inputsPage = Blueprint("inputsPage", __name__, url_prefix="/inputs")

SECRET_KEY = os.getenv("SECRET_KEY")  # for JWT

#
@inputsPage.route('/insertFood', methods=['POST'])
@token_required
def insertOrders():
    data = request.json
    user_id = request.user_id   

    query = query = """
<<<<<<< HEAD
INSERT INTO orderitems (ID, food_name, cost, order_datetime, category, order_id, dow, FREQUENCY)
VALUES (%s, %s, %s, CURRENT_TIMESTAMP(), %s, order_id_seq.NEXTVAL, TO_CHAR(CURRENT_TIMESTAMP(), 'Day', %s))
=======
INSERT INTO orderitems (ID, food_name, cost, order_datetime, category, order_id, dow)
VALUES (%s, %s, %s, CURRENT_TIMESTAMP(), %s, order_id_seq.NEXTVAL, TO_CHAR(CURRENT_TIMESTAMP(), 'Day'))
>>>>>>> refs/remotes/origin/front-end
"""

    params = [user_id, data.get("Name"), data.get("Cost"), data.get("Category"), data.get("Frequency")]

    try:
        get_connection("ITEMS_DB", query=query, params=params, commit=True)
        return jsonify({"message": "Order inserted successfully!"}), 201
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
    
@inputsPage.route('/deleteFood', methods=['DELETE'])
@token_required
def deleteOrder():
    data = request.json
    user_id = request.user_id
    order_id = data.get("ORDER_ID")

    if not order_id:
        return jsonify({"error": "order_id is required"}), 400

    query = "DELETE FROM orderitems WHERE order_id = %s AND ID = %s"
    params = [order_id, user_id,]

    try:
        get_connection("ITEMS_DB", query=query, params=params, commit=True)
        return jsonify({"message": "Order deleted successfully!"}), 200
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

# Insert a food preference
@inputsPage.route('/insertPref', methods=['POST'])
@token_required
def insertPref():
    data = request.json
    user_id = request.user_id
    food_name = data.get("food_name")

    # Check if food_name is provided
    if not food_name:
        return jsonify({"error": "Food name is required"}), 400

    # Query to insert the food preference
    query = """
    INSERT INTO FOOD_PREFERENCES (ID, food_name)
    VALUES (%s, %s)
    """

    params = [user_id, food_name,]

    try:
        # Insert the food preference into the database
        get_connection("Users", query=query, params=params, commit=True)
        return jsonify({"message": f"Food preference '{food_name}' added for user {user_id}."}), 201
    except Exception as e:
        # Handle any errors
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


# Remove a food preference
@inputsPage.route('/removePref', methods=['DELETE'])
@token_required
def removePref():
    data = request.json
    user_id = request.user_id
    food_name = data.get("food_name")

    # Check if food_name is provided
    if not food_name:
        return jsonify({"error": "Food name is required"}), 400

    # Query to remove the food preference
    query = """
    DELETE FROM FOOD_PREFERENCES
    WHERE ID = %s AND food_name = %s
    """

    params = [user_id, food_name]

    try:
        # Perform the delete operation
        get_connection("Users", query=query, params=params, commit=True)
        return jsonify({"message": f"Food preference '{food_name}' removed for user {user_id}."}), 200
    except Exception as e:
        # Handle any errors
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


@inputsPage.route('/analyze', methods=['POST'])
@token_required
def analyze():
    user_id = request.user_id

    # Fetch items from DB
    rows = get_connection('ITEMS_DB',
        'SELECT i.FOOD_NAME, i.COST, '
        'CASE WHEN fp.FOOD_NAME IS NOT NULL THEN TRUE ELSE FALSE END AS IS_PREFERRED, '
        'i.ORDER_DATETIME '
        'FROM ITEMS_DB.PUBLIC.ORDERITEMS i '
        'LEFT JOIN Users.PUBLIC.FOOD_PREFERENCES fp '
        'ON i.FOOD_NAME = fp.FOOD_NAME AND i.ID = fp.ID '
        'WHERE i.ID = %s',
        False,
        params=[user_id]
    )

    # Convert tuples to dicts
    items = [
        {"name": row[0], "price": float(row[1]), "is_preferred": row[2], "timestamp": row[3]}
        for row in rows
    ]

    # Date calculations
    today = datetime.date.today()
    start_of_this_week = today - datetime.timedelta(days=today.weekday())
    start_of_last_week = start_of_this_week - datetime.timedelta(weeks=1)

    this_week_items = []
    last_week_items = []

    for item in items:
        item_date = item["timestamp"].date()
        if start_of_this_week <= item_date < start_of_this_week + datetime.timedelta(weeks=1):
            this_week_items.append(item)
        elif start_of_last_week <= item_date < start_of_last_week + datetime.timedelta(weeks=1):
            last_week_items.append(item)

    this_week_total = sum(item["price"] for item in this_week_items)
    last_week_total = sum(item["price"] for item in last_week_items)

    return jsonify(analyze_spending(items, this_week_total, last_week_total))