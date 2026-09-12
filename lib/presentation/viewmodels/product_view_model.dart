// lib/presentation/viewmodels/product_view_model.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _skip = 0;
  int _total = 0;
  String _searchQuery = '';
  Timer? _debounceTimer;

  static const int _limit = 20;

  // Getters — View reads these
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  bool get isEmpty => !_isLoading && _errorMessage == null && _products.isEmpty;

  // Initial load
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _skip = 0;
      final response = await _repository.getProducts(_limit, _skip);
      _products = response.products;
      _total = response.total;
      _hasMore = _products.length < _total;
    } catch (e) {
      _errorMessage = 'Failed to load products. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load next page
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _skip += _limit;
      final response = await _repository.getProducts(_limit, _skip);
      _products.addAll(response.products);
      _hasMore = _products.length < _total;
    } catch (e) {
      _skip -= _limit; // revert skip on failure
      _errorMessage = 'Failed to load more products.';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // Debounced search
  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      fetchProducts();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchProducts(query);
    });
  }

  // Actual search call
  Future<void> _searchProducts(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.searchProducts(query);
      _products = response.products;
      _total = response.total;
      _hasMore = false; // disable pagination during search
    } catch (e) {
      _errorMessage = 'Failed to search products. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Pull-to-refresh
  Future<void> refreshProducts() async {
    if (_searchQuery.isNotEmpty) {
      await _searchProducts(_searchQuery);
    } else {
      await fetchProducts();
    }
  }

  // Retry last failed action
  void retry() {
    if (_searchQuery.isNotEmpty) {
      _searchProducts(_searchQuery);
    } else if (_products.isEmpty) {
      fetchProducts();
    } else {
      loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}