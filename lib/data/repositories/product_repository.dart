import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/services/product_api_service.dart';

class ProductRepository {
  final ProductApiService _apiService = ProductApiService();

  Future<ProductResponse> getProducts(int limit, int skip) async {
    final json = await _apiService.fetchProducts(limit, skip);
    return ProductResponse.fromJson(json);
  }

  Future<Product> getProductById(int id) async {
    final json = await _apiService.fetchProductById(id);
    return Product.fromJson(json);
  }

  Future<ProductResponse> searchProducts(String query) async {
    final json = await _apiService.searchProducts(query);
    return ProductResponse.fromJson(json);
  }

  Future<List<Category>> getCategories() async {
    final jsonList = await _apiService.fetchCategories();
    return jsonList.map((json) => Category.fromJson(json)).toList();
  }

  Future<ProductResponse> getProductsByCategory(String categorySlug) async {
    final json = await _apiService.fetchProductsByCategory(categorySlug);
    return ProductResponse.fromJson(json);
  }
}