// lib/data/services/product_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  // Fetch product list with pagination
  Future<Map<String, dynamic>> fetchProducts(int limit, int skip) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return json.decode(response.body);
  }

  // Fetch single product by id
  Future<Map<String, dynamic>> fetchProductById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load product details');
    }

    return json.decode(response.body);
  }

  // Search products by query
  Future<Map<String, dynamic>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/search?q=$query'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search products');
    }

    return json.decode(response.body);
  }
}