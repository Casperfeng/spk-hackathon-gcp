import os
import functions_framework
from flask import Flask, jsonify, request


app = Flask(__name__)


@app.route("/",methods=['GET','POST'])
def index():
    if request.method=='GET':
        return jsonify({"message": "Api served from a Flask app in Cloud Run"})
    else:
        return jsonify({'Error':"This is a GET API method"})


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))