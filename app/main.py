import os
from flask import Flask, jsonify, request
import json, requests


app = Flask(__name__)


@app.route("/",methods=['GET','POST'])
def index():
    if request.method=='GET':
        return jsonify({'Success':"You have hit the backend"})  

    else:
        return jsonify({'Error':"This is a GET API method"})
