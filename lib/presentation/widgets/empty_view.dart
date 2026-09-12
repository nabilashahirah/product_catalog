// lib/presentation/widgets/empty_view.dart

import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String searchQuery;

  const EmptyView({
    super.key,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isSearch = searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                size: 48,
                color: scheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'No matches' : 'Nothing here yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearch
                  ? 'We couldn\'t find products for "$searchQuery".'
                  : 'No products are available right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
