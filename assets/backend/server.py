# server.py - API server for climate_smart_advisor
from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import os
import io
from google.cloud import vision
import tensorflow as tf
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
import joblib
import logging
from climate_smart_advisor import ClimateSmartFarmingAdvisor
from plant_disease_info import PlantDiseaseInfo
from nutrition_planner import recommend_foods, generate_meal_plan, suggest_recipes, df
from crop_predictor import CropYieldPredictor


app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "path-to-your-credentials.json"
client = vision.ImageAnnotatorClient()

# Initialize the advisor
advisor = ClimateSmartFarmingAdvisor()
disease_info = PlantDiseaseInfo()
predictor = CropYieldPredictor(model_path='assets/models/crop_yield_model')

@app.route('/recommendations', methods=['POST'])
def get_recommendations():
    data = request.json
    
    if not data or 'location' not in data or 'crop_type' not in data:
        return jsonify({'error': 'Missing required fields: location and crop_type'}), 400
    
    location = data['location']
    crop_type = data['crop_type']
    climate_challenge = data.get('climate_challenge')  # Optional
    
    try:
        recommendations = advisor.get_climate_smart_recommendations(
            location=location,
            crop_type=crop_type,
            climate_challenge=climate_challenge
        )
        return jsonify(recommendations)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/adaptation_strategies', methods=['POST'])
def get_adaptation_strategies():
    data = request.json
    
    if not data or 'location' not in data or 'climate_challenge' not in data:
        return jsonify({'error': 'Missing required fields: location and climate_challenge'}), 400
    
    location = data['location']
    climate_challenge = data['climate_challenge']
    
    try:
        strategies = advisor.get_specific_adaptation_strategy(
            location=location,
            climate_challenge=climate_challenge
        )
        return jsonify(strategies)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/farming_calendar', methods=['POST'])
def get_farming_calendar():
    data = request.json
    
    if not data or 'location' not in data or 'crop_type' not in data:
        return jsonify({'error': 'Missing required fields: location and crop_type'}), 400
    
    location = data['location']
    crop_type = data['crop_type']
    
    try:
        calendar = advisor.get_sustainable_farming_calendar(
            location=location,
            crop_type=crop_type
        )
        return jsonify(calendar)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@app.route('/recommendations/by-coordinates', methods=['POST'])
def get_recommendations_by_coordinates():
    data = request.json
    
    if not data or 'latitude' not in data or 'longitude' not in data or 'crop_type' not in data:
        return jsonify({'error': 'Missing required fields: latitude, longitude, and crop_type'}), 400
    
    latitude = data['latitude']
    longitude = data['longitude']
    crop_type = data['crop_type']
    climate_challenge = data.get('climate_challenge')  # Optional
    
    try:
        # You'll need to modify your advisor class to handle coordinates instead of location names
        recommendations = advisor.get_climate_smart_recommendations_by_coordinates(
            latitude=latitude,
            longitude=longitude,
            crop_type=crop_type,
            climate_challenge=climate_challenge
        )
        return jsonify(recommendations)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@app.route('/disease_info', methods=['POST'])
def get_plant_disease_info():
    data = request.json
    
    if not data or 'disease_name' not in data:
        return jsonify({'error': 'Missing required field: disease_name'}), 400
    
    disease_name = data['disease_name']
    
    try:
        result = disease_info.get_disease_information(
            disease_name=disease_name
        )
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

    
@app.route('/recommend-foods', methods=['POST'])
def api_recommend_foods():
    try:
        data = request.json
        filtered = recommend_foods(
            df,
            dietary_preference=data.get('dietary_preference'),
            min_sustainability_score=data.get('min_sustainability_score', 0),
        )
        # Convert to list of dicts
        result = filtered.to_dict('records')
        return jsonify({'success': True, 'data': result})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/generate-meal-plan', methods=['POST'])
def api_generate_meal_plan():
    try:
        data = request.json
        meal_plan = generate_meal_plan(
            df,
            dietary_preference=data['dietary_preference'],
            allergies=data['allergies'],
            duration=data['duration'],
            max_calories=data.get('max_calories'),
            min_sustainability_score=data.get('min_sustainability_score', 0),
        )
        return jsonify({'success': True, 'data': meal_plan})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

@app.route('/suggest-recipe', methods=['POST'])
def api_suggest_recipe():
    try:
        data = request.json
        recipe = suggest_recipes(
            data['ingredient'],
            data['meal_type'],
        )
        return jsonify({'success': True, 'data': recipe})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400
    
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

@app.route('/detect', methods=['POST'])
def detect():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400

    try:
        file = request.files['file']
        content = file.read()
        
        # Log file details
        app.logger.info(f"File received: {file.filename}, size: {len(content)} bytes")
        
        try:
            image = vision.Image(content=content)
            response = client.label_detection(image=image)
            labels = response.label_annotations
            
            results = [{'description': label.description, 'score': label.score} for label in labels]
            return jsonify({'labels': results})
        except Exception as e:
            app.logger.error(f"Vision API error: {str(e)}")
            return jsonify({'error': f"Vision API error: {str(e)}"}), 500
            
    except Exception as e:
        app.logger.error(f"File processing error: {str(e)}")
        return jsonify({'error': f"File processing error: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)