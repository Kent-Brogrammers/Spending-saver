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
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]
        
        if not token:
            return jsonify({'message': 'Token is missing!'}), 403
        
        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
            current_user = data['user_id']
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token has expired!'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Invalid token!'}), 401

        request.user_id = current_user
        return f(*args, **kwargs)  # ← OUTSIDE the try block, at function level
    
    return decorated_function  # ← YOU ARE MISSING THIS LINE