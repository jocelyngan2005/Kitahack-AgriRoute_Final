import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async' show TimeoutException;


class FarmingService {
  final String _baseUrl = 'http://10.167.56.230:5000'; // Replace with your actual API endpoint
  
  // Method to get recommendations based on manual location input
  Future<Map<String, dynamic>> getClimateSmartRecommendations({
    required String location,
    required String cropType,
    String? climateChallenge,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'location': location,
          'crop_type': cropType,
          'climate_challenge': climateChallenge,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }
  
  // Method to get recommendations based on current device location
  Future<Map<String, dynamic>> getRecommendationsForCurrentLocation({
    required String cropType,
    String? climateChallenge,
  }) async {
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      final response = await http.post(
        Uri.parse('$_baseUrl/recommendations/by-coordinates'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'crop_type': cropType,
          'climate_challenge': climateChallenge,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      if (e is LocationServiceDisabledException) {
      throw Exception('Location services are disabled. Please enable them in settings.');
    } else if (e is TimeoutException) {
      throw Exception('Location request timed out. Check your connection or try again.');
    } else {
      throw Exception('Error getting recommendations by location: $e');
    }
    }
  }
}