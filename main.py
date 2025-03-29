from flask import Flask, render_template, request, jsonify
from flask_cors import CORS  # Added CORS for Web3 integration

app = Flask(__name__)
CORS(app)  # Enable CORS to allow requests from your frontend

# Simulated whiteboard data
whiteboard_content = "Welcome to the AI Whiteboard!"

@app.route('/')
def home():
    return render_template('index.html', content=whiteboard_content)

@app.route('/update_content', methods=['POST'])
def update_content():
    global whiteboard_content
    new_content = request.json.get('content', '')
    whiteboard_content = new_content.strip()
    return jsonify({"status": "success", "content": whiteboard_content})

@app.route('/transaction_status', methods=['POST'])
def transaction_status():
    tx_hash = request.json.get('tx_hash')
    print(f"Received transaction hash: {tx_hash}")  # Added for debugging
    return jsonify({"status": "Transaction received", "tx_hash": tx_hash})

if __name__ == '__main__':
    app.run(debug=True)
