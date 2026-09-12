import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> fetchProducts(int limit, int skip) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> fetchProductById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load product details');
    }

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/search?q=$query'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to search products');
    }

    return json.decode(response.body);
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/categories'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories');
    }

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> fetchProductsByCategory(String categorySlug) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/category/$categorySlug'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products by category');
    }

    return json.decode(response.body);
  }
}