from flask import Flask
import snowflake.connector

app = Flask(__name__)

SNOWFLAKE_CONFIG = {
    'user': 'YOUR_USERNAME',         # your default user
    'password': 'YOUR_PASSWORD',     # your Snowflake password
    'account': 'tpilzjq',            # from the URL
    'warehouse': 'MY_WAREHOUSE',     # your warehouse
    'database': 'SPENDING_SAVER_DB', # from URL
    'schema': 'PUBLIC'               # default schema
}

@app.route('/')
def main():
    return "Hello from Flask!"

if __name__ == "__main__":
    app.run(debug=True)