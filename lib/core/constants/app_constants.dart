import 'package:flutter/material.dart';

/// Global constants: currencies, category icon/color palettes, misc sizing.
abstract final class AppConstants {
  static const String appName = 'Verda';
  static const double cardRadius = 24;
  static const double sheetRadius = 28;
  static const double controlRadius = 16;

  /// Demo OTP accepted by the placeholder verification flow.
  static const String demoOtp = '123456';

  static const List<Currency> currencies = [
    Currency('INR', '₹', 'Indian Rupee'),
    Currency('USD', '\$', 'US Dollar'),
    Currency('EUR', '€', 'Euro'),
    Currency('GBP', '£', 'British Pound'),
    Currency('JPY', '¥', 'Japanese Yen'),
    Currency('AED', 'د.إ', 'UAE Dirham'),
    Currency('SGD', 'S\$', 'Singapore Dollar'),
    Currency('AUD', 'A\$', 'Australian Dollar'),
    Currency('CAD', 'C\$', 'Canadian Dollar'),
  ];

  static String currencySymbol(String code) => currencies
      .firstWhere((c) => c.code == code,
          orElse: () => const Currency('INR', '₹', 'Indian Rupee'))
      .symbol;
}

class Currency {
  final String code;
  final String symbol;
  final String name;
  const Currency(this.code, this.symbol, this.name);
}

/// Icon registry for categories. Icons are referenced by a stable string key
/// so they can be persisted in the database and remain tree-shake friendly.
const Map<String, IconData> categoryIcons = {
  'food': Icons.restaurant_rounded,
  'grocery': Icons.local_grocery_store_rounded,
  'fuel': Icons.local_gas_station_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'travel': Icons.flight_takeoff_rounded,
  'medical': Icons.medical_services_rounded,
  'education': Icons.school_rounded,
  'entertainment': Icons.movie_rounded,
  'utilities': Icons.lightbulb_rounded,
  'bills': Icons.receipt_long_rounded,
  'salary': Icons.payments_rounded,
  'investments': Icons.trending_up_rounded,
  'other': Icons.category_rounded,
  'coffee': Icons.local_cafe_rounded,
  'gift': Icons.card_giftcard_rounded,
  'pets': Icons.pets_rounded,
  'home': Icons.home_rounded,
  'fitness': Icons.fitness_center_rounded,
  'kids': Icons.child_care_rounded,
  'car': Icons.directions_car_rounded,
  'phone': Icons.smartphone_rounded,
  'internet': Icons.wifi_rounded,
  'insurance': Icons.shield_rounded,
  'beauty': Icons.spa_rounded,
};

IconData iconForKey(String key) => categoryIcons[key] ?? Icons.category_rounded;

/// Curated palette for category colors.
const List<Color> categoryPalette = [
  Color(0xFFF97316), // orange
  Color(0xFF22C55E), // green
  Color(0xFF3B82F6), // blue
  Color(0xFFA855F7), // purple
  Color(0xFFEC4899), // pink
  Color(0xFFEF4444), // red
  Color(0xFF14B8A6), // teal
  Color(0xFFF59E0B), // amber
  Color(0xFF6366F1), // indigo
  Color(0xFF84CC16), // lime
  Color(0xFF06B6D4), // cyan
  Color(0xFF8B5CF6), // violet
  Color(0xFF64748B), // slate
  Color(0xFFD946EF), // fuchsia
];
