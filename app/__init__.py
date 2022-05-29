# Import flask and template operators
from datetime import datetime, timedelta
from flask import Flask, jsonify, request
# Import SQLAlchemy
from flask_sqlalchemy import SQLAlchemy

import uuid
from sqlalchemy.dialects.postgresql import UUID

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

# Returns garbage seen during the last hour
@app.route('/trucks', methods=['GET'])
def last_hour_trucks():
    trucks = Truck.query.filter(Truck.observedAt >= datetime.now()-timedelta(hours=1)).all()
    return jsonify([t.toJSON() for t in trucks]), 200

# Saves a new truck to DB
@app.route('/trucks', methods=['POST'])
def new_truck_observed():
    if not (request.json and 'long' in request.json and 'lat' in request.json):
        return jsonify({'msg':'Missing arguments long or lat'}), 400

    new_truck = Truck(uuid.uuid4(), request.json['lat'], request.json['long'], datetime.now())
    new_truck.save()

    return jsonify(new_truck.toJSON()), 201

# Returns garbage seen during the last 24 hours
@app.route('/garbage', methods=['GET'])
def last_day_garbage():
    garbage = Garbage.query.filter(Garbage.observedAt >= datetime.now()-timedelta(days=1)).all()
    return jsonify([g.toJSON() for g in garbage]), 200

# Saves a new garbage to DB
@app.route('/garbage', methods=['POST'])
def new_garbage_observed():
    if not (request.json and 'long' in request.json and 'lat' in request.json):
        return jsonify({'msg':'Missing arguments long or lat'}), 400

    new_garbage = Garbage(uuid.uuid4(), request.json['lat'], request.json['long'], datetime.now())
    new_garbage.save()

    return jsonify(new_garbage.toJSON()), 201

#### MODELS ####

class Truck(db.Model):
    __tablename__ = 'truck'
    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    observedAt = db.Column(db.DateTime)

    def __init__(self, id, latitude, longitude, observedAt):
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.observedAt = observedAt

    def save(self):
        db.session.add(self)
        db.session.commit()

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    def toJSON(self):
        return {"lat": self.latitude, "long": self.longitude, "time": self.observedAt}

class Garbage(db.Model):
    __tablename__ = 'garbage'
    id = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4())
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    observedAt = db.Column(db.DateTime)

    def __init__(self, latitude, longitude, observedAt):
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.observedAt = observedAt

    def save(self):
        db.session.add(self)
        db.session.commit()

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    def toJSON(self):
        return {"lat": self.latitude, "long": self.longitude, "time": self.observedAt}