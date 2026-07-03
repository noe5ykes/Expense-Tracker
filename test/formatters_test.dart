import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('currency uses the right symbol', () {
      expect(Formatters.currency(1500, code: 'INR', locale: 'en'),
          contains('₹'));
      expect(Formatters.currency(1500, code: 'USD', locale: 'en'),
          contains('\$'));
    });

    test('whole amounts have no decimals, fractional keep two', () {
      expect(Formatters.currency(1500, code: 'INR', locale: 'en'), '₹1,500');
      expect(Formatters.currency(1500.5, code: 'INR', locale: 'en'),
          '₹1,500.50');
    });

    test('unknown currency falls back to INR symbol', () {
      expect(
          Formatters.currency(10, code: 'XXX', locale: 'en'), contains('₹'));
    });

    test('percent clamps and rounds', () {
      expect(Formatters.percent(0.256), '26%');
      expect(Formatters.percent(-1), '0%');
      expect(Formatters.percent(0), '0%');
    });
  });
}
