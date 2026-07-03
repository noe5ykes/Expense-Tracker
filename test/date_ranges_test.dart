import 'package:expense_tracker/core/utils/date_ranges.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateRanges', () {
    test('startOfDay strips time', () {
      final d = DateTime(2026, 7, 2, 14, 35, 12);
      expect(DateRanges.startOfDay(d), DateTime(2026, 7, 2));
    });

    test('startOfWeek returns Monday', () {
      // 2026-07-02 is a Thursday → week starts Monday 2026-06-29.
      expect(DateRanges.startOfWeek(DateTime(2026, 7, 2, 10)),
          DateTime(2026, 6, 29));
      // A Monday maps to itself.
      expect(DateRanges.startOfWeek(DateTime(2026, 6, 29, 5)),
          DateTime(2026, 6, 29));
    });

    test('endOfMonth handles year rollover', () {
      final end = DateRanges.endOfMonth(DateTime(2026, 12, 10));
      expect(end.month, 12);
      expect(end.day, 31);
      expect(end.isBefore(DateTime(2027)), isTrue);
    });

    test('sameDay / sameMonth', () {
      expect(
          DateRanges.sameDay(
              DateTime(2026, 7, 2, 1), DateTime(2026, 7, 2, 23)),
          isTrue);
      expect(DateRanges.sameDay(DateTime(2026, 7, 2), DateTime(2026, 7, 3)),
          isFalse);
      expect(
          DateRanges.sameMonth(DateTime(2026, 7, 1), DateTime(2026, 7, 31)),
          isTrue);
      expect(DateRanges.sameMonth(DateTime(2026, 7, 1), DateTime(2025, 7, 1)),
          isFalse);
    });

    test('daysInMonth', () {
      expect(DateRanges.daysInMonth(DateTime(2026, 2)), 28);
      expect(DateRanges.daysInMonth(DateTime(2028, 2)), 29);
      expect(DateRanges.daysInMonth(DateTime(2026, 7)), 31);
    });
  });
}
