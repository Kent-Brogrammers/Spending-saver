import os
from flask import Flask, jsonify
from dotenv import load_dotenv
from flask_cors import CORS
from db_conn.dbHelper import get_connection
from routes.login import *
from routes.inputs import *


load_dotenv(dotenv_path="../.env")

app = Flask(__name__)
CORS(app)
app.register_blueprint(loginPage)
app.register_blueprint(inputsPage)

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