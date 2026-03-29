from flask import Blueprint, jsonify, request
from db_conn.dbHelper import get_connection
import bcrypt, jwt, datetime
import os

loginPage = Blueprint("loginPage", __name__, url_prefix="/login")

SECRET_KEY = os.getenv("SECRET_KEY")  # for JWT

@loginPage.route('/')
def loginHome():
    db_name = get_connection(db="Users", query="SELECT CURRENT_DATABASE()", fetch_one=True)[0]
    return jsonify({"current_database": db_name})

#REGISTER
#----------------------------
@loginPage.route('/create_account', methods=['POST'])
def createAccount():
    data = request.json
    full_name = data.get("full_name")
    username = data.get("username")
    password = data.get("password")

    print(data)

    if not username or not password or not full_name:
        return jsonify({"error": "Full name, username, and password required"}), 400

    print('a')

    # Check if user exists
    result = get_connection(
        db="Users",
        query="SELECT COUNT(*) FROM Users WHERE username = %s",
        fetch_one=True,
        params=(username,)  # parameterized query
    )

    print('b')

    if result[0] > 0:
        return jsonify({"error": "User already exists"}), 409

    # Hash password
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    # Insert new user
    get_connection(
        db="Users",
        query="INSERT INTO Users (full_name, username, password) VALUES (%s, %s, %s)",
        params=(full_name, username, hashed_password),
        commit=True
    )

    return jsonify({"message": "User registered successfully"}), 201

#LOGIN
#--------------------------
@loginPage.route('/login', methods=['POST'])
def loginAccount():
    data = request.json
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Username and password required"}), 400

    # Fetch hashed password from DB
    result = get_connection(
        db="Users",
        query="SELECT ID, PASSWORD FROM Users.PUBLIC.Users WHERE USERNAME = %s",
        fetch_one=True,
        params=(username,)
    )


    if not result:
        return jsonify({"error": "User not found"}), 404

    user_id, stored_hash  = result
    stored_hash = stored_hash.encode('utf-8')

    # Verify password
    if not bcrypt.checkpw(password.encode('utf-8'), stored_hash):
        return jsonify({"error": "Incorrect password"}), 401

    # Generate JWT token
    token = jwt.encode(
        {
            "user_id": user_id,
            "username": username,
            "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
        },
        SECRET_KEY,
        algorithm="HS256"
    )

    return jsonify({"message": "Login successful", "token": token, 'user_id':user_id})