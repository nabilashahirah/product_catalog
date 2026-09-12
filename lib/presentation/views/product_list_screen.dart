import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog/data/models/product.dart';
import 'package:product_catalog/presentation/viewmodels/product_view_model.dart';
import 'package:product_catalog/presentation/views/product_detail_screen.dart';
import 'package:product_catalog/presentation/widgets/product_card.dart';
import 'package:product_catalog/presentation/widgets/loading_view.dart';
import 'package:product_catalog/presentation/widgets/error_view.dart';
import 'package:product_catalog/presentation/widgets/empty_view.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        final viewModel = context.read<ProductViewModel>();
        viewModel.fetchProducts();
        viewModel.fetchCategories();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductViewModel>().loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openCategorySheet(ProductViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _CategorySheet(viewModel: viewModel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();
    final scheme = Theme.of(context).colorScheme;

    final activeCategory = viewModel.selectedCategory == null
        ? null
        : viewModel.categories.firstWhere(
            (c) => c.slug == viewModel.selectedCategory,
            orElse: () => Category(
              slug: viewModel.selectedCategory!,
              name: viewModel.selectedCategory!,
            ),
          );

    final canFilter =
        viewModel.categories.isNotEmpty && viewModel.searchQuery.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: viewModel.onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search products…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: viewModel.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                viewModel.onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _FilterButton(
                  active: activeCategory != null,
                  enabled: canFilter,
                  onTap: () => _openCategorySheet(viewModel),
                ),
              ],
            ),
          ),

          if (activeCategory != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text('Category: ${activeCategory.name}'),
                  labelStyle: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: scheme.primaryContainer,
                  side: BorderSide.none,
                  deleteIcon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                  onDeleted: () => viewModel.selectCategory(null),
                ),
              ),
            ),

          Expanded(child: _buildContent(viewModel)),
        ],
      ),
    );
  }

  Widget _buildContent(ProductViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingView();
    }

    if (viewModel.errorMessage != null && viewModel.products.isEmpty) {
      return ErrorView(
        message: viewModel.errorMessage!,
        onRetry: viewModel.retry,
      );
    }

    if (viewModel.isEmpty) {
      return EmptyView(searchQuery: viewModel.searchQuery);
    }

    final hasFooter =
        viewModel.hasMore || viewModel.paginationErrorMessage != null;

    return RefreshIndicator(
      onRefresh: viewModel.refreshProducts,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = viewModel.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
                childCount: viewModel.products.length,
              ),
            ),
          ),
          if (hasFooter)
            SliverToBoxAdapter(
              child: _buildFooter(viewModel),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildFooter(ProductViewModel viewModel) {
    if (viewModel.paginationErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              viewModel.paginationErrorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: viewModel.retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _FilterButton({
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active ? scheme.primary : Colors.white;
    final fg = active ? Colors.white : scheme.onSurface;
    final border = active ? scheme.primary : scheme.outlineVariant;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            child: Icon(Icons.tune_rounded, color: fg),
          ),
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  final ProductViewModel viewModel;
  const _CategorySheet({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = viewModel.selectedCategory;

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: scheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Filter by category',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    if (selected != null)
                      TextButton(
                        onPressed: () {
                          viewModel.selectCategory(null);
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _sheetChip(
                        context,
                        label: 'All',
                        isSelected: selected == null,
                        onTap: () {
                          viewModel.selectCategory(null);
                          Navigator.pop(context);
                        },
                      ),
                      ...viewModel.categories.map((c) => _sheetChip(
                            context,
                            label: c.name,
                            isSelected: selected == c.slug,
                            onTap: () {
                              viewModel.selectCategory(c.slug);
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sheetChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
