from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import os, datetime, uuid
from token_validator.tv import token_required
from logic.logic import *

inputsPage = Blueprint("inputsPage", __name__, url_prefix="/inputs")
SECRET_KEY = os.getenv("SECRET_KEY")

@inputsPage.route('/insertFood', methods=['POST'])
@token_required
def insertOrders():
    data = request.json
    user_id = request.user_id

    doc = {
        "order_id": str(uuid.uuid4()),
        "user_id": user_id,
        "food_name": data.get("Name"),
        "food_cost": float(data.get("Cost", 0)),
        "category": data.get("Category"),
        "essential": data.get("Essential", False),
        "order_datetime": datetime.datetime.utcnow().isoformat(),
    }

    try:
        get_connection(collection="orders", insert=doc)
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

    try:
        get_connection(collection="orders", query={"order_id": order_id, "user_id": user_id}, delete=True)
        return jsonify({"message": "Order deleted successfully!"}), 200
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


@inputsPage.route('/insertPref', methods=['POST'])
@token_required
def insertPref():
    data = request.json
    user_id = request.user_id
    food_name = data.get("food_name")

    if not food_name:
        return jsonify({"error": "Food name is required"}), 400

    # Store essentials as orders with essential=True
    doc = {
        "order_id": str(uuid.uuid4()),
        "user_id": user_id,
        "food_name": food_name,
        "food_cost": 0.0,
        "category": "preference",
        "essential": True,
        "order_datetime": datetime.datetime.utcnow().isoformat(),
    }

    try:
        get_connection(collection="orders", insert=doc)
        return jsonify({"message": f"Food preference '{food_name}' added."}), 201
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


@inputsPage.route('/removePref', methods=['DELETE'])
@token_required
def removePref():
    data = request.json
    user_id = request.user_id
    food_name = data.get("food_name")

    if not food_name:
        return jsonify({"error": "Food name is required"}), 400

    try:
        get_connection(collection="orders", query={"user_id": user_id, "food_name": food_name, "essential": True}, delete=True)
        return jsonify({"message": f"Food preference '{food_name}' removed."}), 200
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


@inputsPage.route('/changePref', methods=['PUT'])
@token_required
def changePref():
    data = request.json
    user_id = request.user_id
    preference = data.get("preference")

    if not preference:
        return jsonify({"error": "Preference is required"}), 400

    try:
        get_connection(collection="users", query={"_id": user_id}, update={"preferences": preference})
        return jsonify({"message": "Preference updated successfully!"}), 200
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


@inputsPage.route('/changeName', methods=['PUT'])
@token_required
def changeName():
    data = request.json
    user_id = request.user_id
    full_name = data.get("full_name")

    if not full_name:
        return jsonify({"error": "Full name is required"}), 400

    try:
        get_connection(collection="users", query={"_id": user_id}, update={"name": full_name})
        return jsonify({"message": "Name updated successfully!"}), 200
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500


@inputsPage.route('/analyze', methods=['POST'])
@token_required
def analyze():
    user_id = request.user_id

    rows = get_connection(collection="orders", query={"user_id": user_id})

    items = [
        {
            "name": row.get("food_name"),
            "price": float(row.get("food_cost", 0)),
            "essential": bool(row.get("essential", False)),
            "timestamp": datetime.datetime.fromisoformat(row.get("order_datetime")),
        }
        for row in rows
    ]

    today = datetime.date.today()
    start_of_this_week = today - datetime.timedelta(days=today.weekday())
    start_of_last_week = start_of_this_week - datetime.timedelta(weeks=1)

    this_week_items, last_week_items = [], []

    for item in items:
        item_date = item["timestamp"].date()
        if start_of_this_week <= item_date < start_of_this_week + datetime.timedelta(weeks=1):
            this_week_items.append(item)
        elif start_of_last_week <= item_date < start_of_last_week + datetime.timedelta(weeks=1):
            last_week_items.append(item)

    this_week_total = sum(i["price"] for i in this_week_items)
    last_week_total = sum(i["price"] for i in last_week_items)

    return jsonify(analyze_spending(items, this_week_total, last_week_total))