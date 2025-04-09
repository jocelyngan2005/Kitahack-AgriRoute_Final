import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class BlockchainService {
  static const String baseUrl = 'http://172.22.72.7:3000/api';

  Future<Map<String, dynamic>> registerProduct(Product product) async {

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'productId': product.productId,
          'name': product.name,
          'producerName': product.producerName,
          'location': product.location,
          'harvestDate': product.harvestDate.toIso8601String(),
        }),
      );

      

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register product');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getProductHistory(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId/history'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch product history');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> recordHandoff(Map<String, dynamic> handoffData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/handoff'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(handoffData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to record handoff');
      }
    } catch (e) {
      rethrow;
    }
  }
}