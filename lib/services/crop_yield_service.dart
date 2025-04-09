import 'dart:convert';
import 'package:http/http.dart' as http;

class CropYieldService {
  // Base URL for your backend API
  static const String _baseUrl = 'http://10.167.56.230:5000'; 
  

  // Predict crop yield
  Future<CropYieldPrediction> predictCropYield({
    required String area,
    required String item,
    required int year,
    required double rainfall,
    required double pesticides,
    required double avgTemp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'Area': area,
          'Item': item,
          'Year': year,
          'average_rain_fall_mm_per_year': rainfall,
          'pesticides_tonnes': pesticides,
          'avg_temp': avgTemp,
        }),
      );

      // Check response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Check for successful status
        if (data['status'] == 'success') {
          return CropYieldPrediction(
            cropYield: data['yield'],
            status: data['status'],
          );
        } else {
          throw Exception(data['error'] ?? 'Unknown error occurred');
        }
      } else {
        // Handle error responses
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Prediction failed');
      }
    } catch (e) {
      // Rethrow the error for UI to handle
      rethrow;
    }
  }

  // Health check for API
  Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/health'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'healthy' && data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}

// Data model for crop yield prediction
class CropYieldPrediction {
  final double cropYield;
  final String status;

  CropYieldPrediction({
    required this.cropYield,
    required this.status,
  });
}