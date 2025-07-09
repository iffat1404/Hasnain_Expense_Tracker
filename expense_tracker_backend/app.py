from flask import Flask, request, jsonify
import joblib
import re

# Initialize the Flask app
app = Flask(__name__)

# --- Load Models and Helper Functions ---

# Load the trained Scikit-learn pipeline
try:
    category_classifier = joblib.load('category_classifier.pkl')
    print("Category classification model loaded successfully.")
except FileNotFoundError:
    print("Error: 'category_classifier.pkl' not found. Please run train_model.py first.")
    exit()

def extract_amount(text):
    """Uses regex to find the first number (integer or float) in the text."""
    # This regex looks for digits, optionally followed by a dot and more digits.
    numbers = re.findall(r'\d+\.?\d*', text)
    if numbers:
        return float(numbers[0])
    return None

def extract_item(text, amount):
    """A simple but effective heuristic to guess the item."""
    # Convert amount to string to remove it from the text
    amount_str = str(int(amount) if amount.is_integer() else amount)
    text = text.lower().replace(amount_str, '')

    # Remove common stop words and units
    stop_words = [
        'bought', 'paid', 'for', 'a', 'an', 'the', 'rs', 'rupees', 'was', 'of',
        'my', 'recharged', 'new', 'got'
    ]
    querywords = text.split()
    
    # Rebuild the string without the stop words
    resultwords  = [word for word in querywords if word.lower() not in stop_words]
    item = ' '.join(resultwords).strip().title() # Capitalize first letters
    
    return item if item else "Unknown Item"


# --- API Endpoint Definition ---

@app.route('/process', methods=['POST'])
def process_text():
    
    print("\n--- Request received at /process endpoint! ---") 
    # 1. Get the JSON data from the request body
    data = request.get_json()
    if not data or 'text' not in data:
        return jsonify({'error': 'Invalid input. Please provide a "text" field.'}), 400

    input_text = data['text']

    # 2. Predict the Category using our trained model
    # The model expects a list of strings, so we pass [input_text]
    predicted_category = category_classifier.predict([input_text])[0]

    # 3. Extract Amount using our regex helper
    amount = extract_amount(input_text)
    if amount is None:
        # If no amount is found, we can't create a valid expense
        return jsonify({'error': 'Could not determine the amount from the text.'}), 400
        
    # 4. Extract Item using our heuristic helper
    item = extract_item(input_text, amount)

    # 5. Structure the final response
    response = {
        'item': item,
        'amount': amount,
        'category': predicted_category
    }

    # Return the structured data as JSON
    return jsonify(response)


# This allows running the app directly with `python app.py` for easy testing
if __name__ == '__main__':
    # Runs on http://127.0.0.1:5000
    app.run(host='0.0.0.0', port=5000, debug=True)