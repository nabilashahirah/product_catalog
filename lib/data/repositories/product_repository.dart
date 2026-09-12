// lib/data/repositories/product_repository.dart

import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/services/product_api_service.dart';

class ProductRepository {
  final ProductApiService _apiService = ProductApiService();

  // Get paginated product list
  Future<ProductResponse> getProducts(int limit, int skip) async {
    final json = await _apiService.fetchProducts(limit, skip);
    return ProductResponse.fromJson(json);
  }

  // Get single product by id
  Future<Product> getProductById(int id) async {
    final json = await _apiService.fetchProductById(id);
    return Product.fromJson(json);
  }

  // Search products by query
  Future<ProductResponse> searchProducts(String query) async {
    final json = await _apiService.searchProducts(query);
    return ProductResponse.fromJson(json);
  }
}