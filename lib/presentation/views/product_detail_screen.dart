// lib/presentation/views/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:product_catalog/data/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: Text(product.title),
      ),
    );
  }
}