from flask import request, jsonify
import jwt
import os
from db_conn.dbHelper import get_connection
from functools import wraps

SECRET_KEY = os.getenv("SECRET_KEY")  # Your JWT secret key

# Token validation decorator
def token_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = None
        # Check if the token is passed in the header
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]  # Extract token from 'Bearer <token>'
        
        if not token:
            return jsonify({'message': 'Token is missing!'}), 403
        
        try:
            # Decode the token and get the user_id (or other claims)
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            current_user = data['user_id']  # Extract user_id from the token
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token has expired!'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Invalid token!'}), 401

        # Attach the current user ID to the request for easy access in the route
        request.user_id = current_user
        return f(*args, **kwargs)
