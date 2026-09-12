// lib/presentation/widgets/loading_view.dart

import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1200
        ? 5
        : width >= 900
            ? 4
            : width >= 600
                ? 3
                : 2;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: columns * 3,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: scheme.surfaceContainerHighest,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(
                      width: double.infinity,
                      height: 12,
                      color: scheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 6),
                    _SkeletonBox(
                      width: 90,
                      height: 12,
                      color: scheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 12),
                    _SkeletonBox(
                      width: 60,
                      height: 16,
                      color: scheme.surfaceContainerHighest,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
