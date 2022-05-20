# Import flask and template operators
from flask import Flask, jsonify, request
# Import SQLAlchemy
from flask_sqlalchemy import SQLAlchemy

# Define the WSGI application object
app = Flask(__name__)

# Configurations
app.config.from_object('config')

# Define the database object which is imported
# by modules and controllers
db = SQLAlchemy(app)

@app.errorhandler(404)
def not_found(error):
    return "<h1>404</h1><p>This route does not exist on our API, try again ;)</p>", 404

@app.route('/', methods=['GET'])
def homepage():
    return "Welcome to SOADBasura", 200

@app.route('/trucks', methods=['GET'])
def last_hour_trucks():
    return jsonify([{"long": 2, "lat": 41}]), 200

@app.route('/trucks', methods=['POST'])
def new_truck_observed():
    if not (request.json and 'long' in request.json and 'lat' in request.json):
        return jsonify({'msg':'Missing arguments long or lat'}), 400
    return 'Not implemented yet', 200
