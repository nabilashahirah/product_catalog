import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('should correctly parse a product from JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'A test product description',
        'price': 29.99,
        'rating': 4.5,
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
        ],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'A test product description');
      expect(product.price, 29.99);
      expect(product.rating, 4.5);
      expect(product.thumbnail, 'https://example.com/thumb.jpg');
      expect(product.images.length, 2);
      expect(product.images[0], 'https://example.com/img1.jpg');
    });

    test('should handle integer price as double', () {
      final json = {
        'id': 2,
        'title': 'Integer Price Product',
        'description': 'Description',
        'price': 10,
        'rating': 4,
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/img1.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.price, 10.0);
      expect(product.rating, 4.0);
    });

    test('should handle single image in images list', () {
      final json = {
        'id': 3,
        'title': 'Single Image Product',
        'description': 'Description',
        'price': 5.99,
        'rating': 3.2,
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/img1.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.images.length, 1);
    });
  });

  group('ProductResponse.fromJson', () {
    test('should correctly parse product response with pagination', () {
      final json = {
        'products': [
          {
            'id': 1,
            'title': 'Product 1',
            'description': 'Description 1',
            'price': 9.99,
            'rating': 4.5,
            'thumbnail': 'https://example.com/thumb1.jpg',
            'images': ['https://example.com/img1.jpg'],
          },
          {
            'id': 2,
            'title': 'Product 2',
            'description': 'Description 2',
            'price': 19.99,
            'rating': 3.8,
            'thumbnail': 'https://example.com/thumb2.jpg',
            'images': ['https://example.com/img2.jpg'],
          },
        ],
        'total': 194,
        'skip': 0,
        'limit': 20,
      };

      final response = ProductResponse.fromJson(json);

      expect(response.products.length, 2);
      expect(response.total, 194);
      expect(response.skip, 0);
      expect(response.limit, 20);
      expect(response.products[0].title, 'Product 1');
      expect(response.products[1].title, 'Product 2');
    });

    test('should handle empty product list', () {
      final json = {
        'products': [],
        'total': 0,
        'skip': 0,
        'limit': 20,
      };

      final response = ProductResponse.fromJson(json);

      expect(response.products.isEmpty, true);
      expect(response.total, 0);
    });
  });
}