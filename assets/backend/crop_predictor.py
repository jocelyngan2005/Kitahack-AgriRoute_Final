import os
import flask
from flask import Flask, request, jsonify
import tensorflow as tf
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
import joblib
import logging
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

class CropYieldPredictor:
    def __init__(self, model_path='assets/models/crop_yield_model'):
        self.model_path = model_path
        self.model = None
        self.scaler = None
        self.area_encoder = None
        self.item_encoder = None
        self.load_model()

    def prepare_data(self, data):
        """
        Prepare and preprocess input data for yield prediction
        """
        # Encode categorical variables
        data['Area_encoded'] = self.area_encoder.fit_transform(data['Area'])
        data['Item_encoded'] = self.item_encoder.fit_transform(data['Item'])
        
        # Select features
        features = [
            'Area_encoded', 
            'Item_encoded', 
            'Year', 
            'average_rain_fall_mm_per_year', 
            'pesticides_tonnes', 
            'avg_temp'
        ]
        
        # Separate features and target
        X = data[features]
        y = data['hg/ha_yield']
        
        # Scale numerical features
        X_scaled = self.scaler.fit_transform(X)
        
        return X_scaled, y

    def build_model(self, input_shape):
        """
        Build neural network for yield prediction
        """
        model = tf.keras.Sequential([
            tf.keras.layers.Dense(64, activation='relu', input_shape=(input_shape,)),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dropout(0.3),
            tf.keras.layers.Dense(32, activation='relu'),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(1, activation='linear')
        ])
        
        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
            loss='mean_squared_error',
            metrics=['mae']
        )
        
        return model

    def train(self, data):
        """
        Train the crop yield prediction model and save it
        """
        X, y = self.prepare_data(data)
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
         # Scale data
        scaler = StandardScaler()
        X_train = scaler.fit_transform(X_train)
        X_test = scaler.transform(X_test)

        # Build and train model
        self.model = self.build_model(X.shape[1])
        
        history = self.model.fit(
            X_train, y_train,
            validation_split=0.2,
            epochs=100,
            batch_size=32,
            verbose=1
        )
        
        # Evaluate model
        test_loss, test_mae = self.model.evaluate(X_test, y_test)
        print(f"Test Loss: {test_loss}, Test MAE: {test_mae}")
        
        # Save the entire model
        self.save_model()
        
        return history

    def save_model(self):
        """
        Save the trained model, scaler, and encoders
        """
        # Ensure directory exists
        os.makedirs(self.model_path, exist_ok=True)
        
        # Save TensorFlow model
        self.model.save(os.path.join(self.model_path, 'model.keras'))
        
        # Save preprocessing objects
        import joblib
        
        # Save scaler
        joblib.dump(self.scaler, os.path.join(self.model_path, 'scaler.joblib'))
        
        # Save label encoders
        joblib.dump({
            'area_encoder': self.area_encoder,
            'item_encoder': self.item_encoder
        }, os.path.join(self.model_path, 'encoders.joblib'))
        
        print(f"Model saved to {self.model_path}")

    def load_model(self):
        """
        Load the saved model, scaler, and encoders
        """
        try:
            # Load TensorFlow model
            self.model = tf.keras.models.load_model(os.path.join(self.model_path, 'model.keras'))
            
            # Load preprocessing objects
            import joblib
            
            # Load scaler
            self.scaler = joblib.load(os.path.join(self.model_path, 'scaler.joblib'))
            
            # Load label encoders
            encoders = joblib.load(os.path.join(self.model_path, 'encoders.joblib'))
            self.area_encoder = encoders['area_encoder']
            self.item_encoder = encoders['item_encoder']
            
            print("Model loaded successfully")
            return True
        except Exception as e:
            print(f"Error loading model: {e}")
            return False

    def predict_yield(self, input_data):
        """
        Predict crop yield for given input data
        
        input_data should be a DataFrame with same structure as training data
        """
        try:
            # Prepare input data
            input_df = pd.DataFrame([input_data])
            
            # Encode categorical variables
            input_df['Area_encoded'] = self.area_encoder.transform(input_df['Area'])
            input_df['Item_encoded'] = self.item_encoder.transform(input_df['Item'])
            
            # Select and prepare features
            features = [
                'Area_encoded', 
                'Item_encoded', 
                'Year', 
                'average_rain_fall_mm_per_year', 
                'pesticides_tonnes', 
                'avg_temp'
            ]
            
            # Prepare input data
            X_input = input_df[features]
            input_scaled = self.scaler.transform(X_input)
            
            # Predict
            prediction = self.model.predict(input_scaled)
            return float(prediction[0][0])
        
        except Exception as e:
            logging.error(f"Prediction error: {e}")
            raise

# Initialize predictor
predictor = CropYieldPredictor()

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get input data from request
        data = request.json
        
        # Validate input data
        required_fields = [
            'Area', 'Item', 'Year', 
            'average_rain_fall_mm_per_year', 
            'pesticides_tonnes', 
            'avg_temp'
        ]
        
        # Check for missing fields
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'error': f'Missing required field: {field}',
                    'status': 'error'
                }), 400
        
        # Validate input data
        try:
            input_data = {
                'Area': str(data['Area']),
                'Item': str(data['Item']),
                'Year': int(data['Year']),
                'average_rain_fall_mm_per_year': float(data['average_rain_fall_mm_per_year']),
                'pesticides_tonnes': float(data['pesticides_tonnes']),
                'avg_temp': float(data['avg_temp'])
            }
        except (ValueError, TypeError) as e:
            return jsonify({'error': f'Invalid input data: {e}', 'status': 'error'}), 400
        
        # Make prediction
        yield_prediction = predictor.predict_yield(input_data)
        
        # Return prediction
        return jsonify({
            'yield': yield_prediction,
            'status': 'success'
        })
    
    except ValueError as e:
        logging.error(f"ValueError: {e}")
        return jsonify({'error': str(e), 'status': 'error'}), 400
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        return jsonify({'error': 'Internal server error', 'status': 'error'}), 500

@app.route('/health', methods=['GET'])
def health_check():
    """
    Health check endpoint to verify API is running
    """
    return jsonify({
        'status': 'healthy',
        'model_loaded': predictor.model is not None
    })

"""""
# Example usage demonstrating model saving and loading
def main():
    # Load and prepare data
    data = pd.read_csv('crop_yield.csv')
    
    # Create predictor and train model
    predictor = CropYieldPredictor()
    predictor.train(data)
    
    # Create a new predictor instance and load the saved model
    new_predictor = CropYieldPredictor()
    new_predictor.load_model()
    
    # Predict yield for new data
    new_crop_data = pd.DataFrame({
        'Area': ['India'],
        'Item': ['Wheat'],
        'Year': [2023],
        'average_rain_fall_mm_per_year': [750],
        'pesticides_tonnes': [50],
        'avg_temp': [28]
    })
    
    predicted_yield = new_predictor.predict_yield(new_crop_data)
    print(f"Predicted Yield: {predicted_yield} hg/ha")
"""""

if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(level=logging.INFO)
    
    # Run the Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)