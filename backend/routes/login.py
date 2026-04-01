from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import bcrypt, jwt, datetime, os, uuid

loginPage = Blueprint("loginPage", __name__, url_prefix="/login")
SECRET_KEY = os.getenv("SECRET_KEY")

@loginPage.route('/')
def loginHome():
    return jsonify({"message": "MongoDB connected"})

@loginPage.route('/create_account', methods=['POST'])
def createAccount():
    data = request.json
    full_name = data.get("full_name")
    username = data.get("username")
    password = data.get("password")

    if not username or not password or not full_name:
        return jsonify({"error": "Full name, username, and password required"}), 400

    existing = get_connection(collection="users", query={"email": username}, fetch_one=True)
    if existing:
        return jsonify({"error": "User already exists"}), 409

    hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    doc = {
        "_id": str(uuid.uuid4()),
        "name": full_name,
        "email": username,
        "password": hashed_password,
        "preferences": "",
        "created_at": datetime.datetime.utcnow().isoformat(),
        "updated_at": datetime.datetime.utcnow().isoformat(),
    }

    get_connection(collection="users", insert=doc)
    return jsonify({"message": "User registered successfully"}), 201


@loginPage.route('/login', methods=['POST'])
def loginAccount():
    data = request.json
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Username and password required"}), 400

    user = get_connection(collection="users", query={"email": username}, fetch_one=True)
    if not user:
        return jsonify({"error": "User not found"}), 404

    if not bcrypt.checkpw(password.encode("utf-8"), user["password"].encode("utf-8")):
        return jsonify({"error": "Incorrect password"}), 401

    token = jwt.encode(
        {
            "user_id": user["_id"],
            "username": username,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
        },
        SECRET_KEY,
        algorithm="HS256"
    )

    return jsonify({"message": "Login successful", "token": token, "user_id": user["_id"]})