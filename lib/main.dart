// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:product_catalog/presentation/viewmodels/product_view_model.dart';
import 'package:product_catalog/presentation/views/product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Custom pastel palette
  static const _primary = Color(0xFFF791A9);           // rose
  static const _primaryContainer = Color(0xFFFFDBDF);  // light pink
  static const _onPrimaryContainer = Color(0xFF7A2A3D);
  static const _secondary = Color(0xFFBAD6DA);         // light blue
  static const _secondaryContainer = Color(0xFFE0F2F4);
  static const _onSecondaryContainer = Color(0xFF1F3D42);
  static const _tertiary = Color(0xFFDDDD7B);          // olive
  static const _tertiaryContainer = Color(0xFFFFE797); // butter
  static const _onTertiaryContainer = Color(0xFF574200);
  static const _scaffoldBg = Color(0xFFFDF7F8);        // warm cream

  @override
  Widget build(BuildContext context) {
    final base = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    );

    final scheme = base.copyWith(
      primary: _primary,
      onPrimary: Colors.white,
      primaryContainer: _primaryContainer,
      onPrimaryContainer: _onPrimaryContainer,
      secondary: _secondary,
      onSecondary: const Color(0xFF1F3D42),
      secondaryContainer: _secondaryContainer,
      onSecondaryContainer: _onSecondaryContainer,
      tertiary: _tertiary,
      onTertiary: const Color(0xFF3D3D10),
      tertiaryContainer: _tertiaryContainer,
      onTertiaryContainer: _onTertiaryContainer,
    );

    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(),
      child: MaterialApp(
        title: 'Product Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: scheme,
          useMaterial3: true,
          scaffoldBackgroundColor: _scaffoldBg,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: scheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.white,
            selectedColor: scheme.primary,
            labelStyle: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            secondaryLabelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(color: scheme.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            showCheckmark: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(color: scheme.onSurfaceVariant),
            prefixIconColor: scheme.primary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
          ),
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}
