import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_nutrition.dart';
import '../models/meal_plan.dart';
import 'package:flutter/foundation.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://10.167.56.230:5000'; // Android emulator

  Future<List<FoodItem>> recommendFoods({
    String? dietaryPreference,
    double minSustainabilityScore = 0,
    List<String> allergies = const [],
    int? maxCalories,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recommend-foods'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dietary_preference': dietaryPreference,
          'min_sustainability_score': minSustainabilityScore,
          'allergies': allergies,
          'max_calories': maxCalories,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((item) => FoodItem.fromJson(item))
              .toList();
        }
        throw Exception(data['error']);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<MealPlan> generateMealPlan({
    required String dietaryPreference,
    required List<String> allergies,
    required String duration,
    int? maxCalories,
    double minSustainabilityScore = 0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-meal-plan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dietary_preference': dietaryPreference,
          'allergies': allergies,
          'duration': duration,
          'max_calories': maxCalories,
          'min_sustainability_score': minSustainabilityScore,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return MealPlan.fromJson(data);
        }
        throw Exception(data['error']);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> suggestRecipe(String ingredient, String mealType) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/suggest-recipe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ingredient': ingredient,
          'meal_type': mealType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
        throw Exception(data['error']);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}