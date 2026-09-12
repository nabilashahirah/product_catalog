import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/presentation/viewmodels/product_view_model.dart';

void main() {
  late ProductViewModel viewModel;

  setUp(() {
    viewModel = ProductViewModel();
  });

  group('ProductViewModel', () {
    test('initial state should be correct', () {
      expect(viewModel.products, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.isLoadingMore, false);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.hasMore, true);
      expect(viewModel.searchQuery, '');
      expect(viewModel.selectedCategory, isNull);
      expect(viewModel.isEmpty, true);
    });

    test('fetchProducts should load products', () async {
      await viewModel.fetchProducts();

      expect(viewModel.products, isNotEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
    });

    test('fetchProducts should load 20 products per page', () async {
      await viewModel.fetchProducts();

      expect(viewModel.products.length, 20);
      expect(viewModel.hasMore, true);
    });

    test('loadMoreProducts should append products', () async {
      await viewModel.fetchProducts();
      final initialCount = viewModel.products.length;

      await viewModel.loadMoreProducts();

      expect(viewModel.products.length, greaterThan(initialCount));
      expect(viewModel.isLoadingMore, false);
    });

    test('loadMoreProducts should not duplicate when called rapidly', () async {
      await viewModel.fetchProducts();

      final future1 = viewModel.loadMoreProducts();
      final future2 = viewModel.loadMoreProducts();
      await Future.wait([future1, future2]);

      expect(viewModel.products.length, 40);
    });

    test('searchProducts should update search query', () {
      viewModel.onSearchChanged('phone');

      expect(viewModel.searchQuery, 'phone');
    });

    test('clearing search should reset to normal products', () async {
      await viewModel.fetchProducts();
      viewModel.onSearchChanged('');

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.searchQuery, '');
      expect(viewModel.products, isNotEmpty);
    });

    test('refreshProducts should reload from beginning', () async {
      await viewModel.fetchProducts();
      await viewModel.loadMoreProducts();
      final countBefore = viewModel.products.length;

      await viewModel.refreshProducts();

      expect(viewModel.products.length, lessThan(countBefore));
      expect(viewModel.products.length, 20);
    });

    test('fetchCategories should load categories', () async {
      await viewModel.fetchCategories();

      expect(viewModel.categories, isNotEmpty);
    });

    test('selectCategory should filter products', () async {
      await viewModel.fetchProducts();
      await viewModel.fetchCategories();

      await viewModel.selectCategory('smartphones');

      expect(viewModel.selectedCategory, 'smartphones');
      expect(viewModel.products, isNotEmpty);
      expect(viewModel.isLoading, false);
    });

    test('selectCategory null should reset to all products', () async {
      await viewModel.selectCategory('smartphones');
      await viewModel.selectCategory(null);

      expect(viewModel.selectedCategory, isNull);
      expect(viewModel.products.length, 20);
    });
  });
}