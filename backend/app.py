import sys
import os

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

#Snowflake Setup
#----------------------------

#With no query, will still work and just return the connection
#With a query, will return the result
@app.route('/test-snowflake')
def test_snowflake():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT CURRENT_VERSION()")
    version = cur.fetchone()
    cur.close()
    conn.close()
    return jsonify({"snowflake_version": version[0]})



#MAIN MAIN MAIN
#-------------------------------------
@app.route('/')
def main():
    return "Hello from Flask!"



if __name__ == "__main__":
    app.run(debug=True)