from flask import Flask
import snowflake.connector

load_dotenv()

app = Flask(__name__)

def getConnection():
    

@app.route('/')
def main():
    return "Hello from Flask!"

if __name__ == "__main__":
    app.run(debug=True)