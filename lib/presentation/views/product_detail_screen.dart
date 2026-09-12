import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/data/repositories/product_repository.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _repository = ProductRepository();
  late Product _product;
  bool _isRefreshing = true;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });

    try {
      final fresh = await _repository.getProductById(widget.product.id);
      if (!mounted) return;
      setState(() {
        _product = fresh;
        _isRefreshing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _refreshError = 'Failed to load latest details.';
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_refreshError != null)
              Container(
                width: double.infinity,
                color: Colors.orange.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 20, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _refreshError!,
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadDetail,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            Hero(
              tag: 'product-image-${_product.id}',
              child: Container(
                width: double.infinity,
                height: 320,
                color: scheme.surfaceContainerHighest,
                child: CachedNetworkImage(
                  imageUrl: _product.images.isNotEmpty
                      ? _product.images[0]
                      : _product.thumbnail,
                  memCacheWidth: 900,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.primary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 64,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '\$${_product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.amber.shade700, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              _product.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _SectionHeader(icon: Icons.description_outlined, label: 'Description'),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),

                  if (_product.images.length > 1) ...[
                    const SizedBox(height: 24),
                    _SectionHeader(icon: Icons.photo_library_outlined, label: 'Gallery'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _product.images.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 110,
                              height: 110,
                              color: scheme.surfaceContainerHighest,
                              child: CachedNetworkImage(
                                imageUrl: _product.images[index],
                                memCacheWidth: 330,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.broken_image_outlined,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
