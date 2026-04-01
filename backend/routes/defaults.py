from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import os
from token_validator.tv import token_required
from logic.logic import *

defaultData = Blueprint("defaultData", __name__, url_prefix="/defaults")
SECRET_KEY = os.getenv("SECRET_KEY")

@defaultData.route('/listItems')
@token_required
def itemList():
    user_id = request.user_id
    rows = get_connection(
        collection="orders",
        query={"user_id": user_id}
    )
    items = [
        {
            "order_id": row.get("order_id"),
            "food_name": row.get("food_name"),
            "cost": float(row.get("food_cost", 0)),
            "order_datetime": str(row.get("order_datetime")),
            "category": row.get("category")
        }
        for row in rows
    ]
    return jsonify(items), 200


@defaultData.route('/listEssentials')
@token_required
def essList():
    user_id = request.user_id
    rows = get_connection(
        collection="orders",
        query={"user_id": user_id, "essential": True}
    )
    items = [{"food_name": row.get("food_name")} for row in rows]
    return jsonify(items), 200


@defaultData.route('/listPreference')
@token_required
def prefList():
    user_id = request.user_id
    result = get_connection(
        collection="users",
        query={"_id": user_id},
        fetch_one=True
    )
    return jsonify({"preference": result.get("preferences") if result else None}), 200