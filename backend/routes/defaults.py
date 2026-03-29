from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import os
from token_validator.tv import token_required
from logic.logic import *

defaultData = Blueprint("defaultData", __name__, url_prefix="/defaults")

SECRET_KEY = os.getenv("SECRET_KEY")  # for JWT

@defaultData.route('/listItems')
@token_required
def itemList():
    user_id = request.user_id
    rows = get_connection('ITEMS_DB',
        'SELECT ORDER_ID, FOOD_NAME, COST, ORDER_DATETIME, CATEGORY FROM ITEMS_DB.PUBLIC.ORDERITEMS WHERE ID = %s',
        False,
        params=[user_id]
    )
    items = [
        {"order_id": row[0], "food_name": row[1], "cost": float(row[2]), "order_datetime": str(row[3]), "category": row[4]}
        for row in rows
    ]
    return jsonify(items), 200

@defaultData.route('/listEssentials')
@token_required
def essList():
    user_id = request.user_id
    rows = get_connection('Users',
        'SELECT FOOD_NAME FROM Users.PUBLIC.FOOD_PREFERENCES WHERE ID = %s',
        False,
        params=[user_id]
    )
    items = [{"food_name": row[0]} for row in rows]
    return jsonify(items), 200

    