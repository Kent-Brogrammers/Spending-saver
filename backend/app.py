import sys, os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from flask import Flask, jsonify
from dotenv import load_dotenv
from flask_cors import CORS
from db_conn.dbHelper import get_connection
from backend.routes.login import loginPage
from backend.routes.inputs import inputsPage
from backend.routes.defaults import defaultData

load_dotenv(dotenv_path="../.env")

app = Flask(__name__)
CORS(app)

app.register_blueprint(loginPage)
app.register_blueprint(inputsPage)
app.register_blueprint(defaultData)

@app.route('/test-mongo')
def test_mongo():
    db = get_connection()
    collections = db.list_collection_names()
    return jsonify({"collections": collections})

@app.route('/')
def main():
    return "Hello from Flask!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)