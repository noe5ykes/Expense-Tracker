import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Default categories inserted on first launch. Ids are stable so budgets and
/// dummy data can reference them.
const defaultCategorySeeds = [
  ('food', 0xFFF97316, 'food', false),
  ('grocery', 0xFF84CC16, 'grocery', false),
  ('fuel', 0xFF64748B, 'fuel', false),
  ('shopping', 0xFFEC4899, 'shopping', false),
  ('travel', 0xFF3B82F6, 'travel', false),
  ('medical', 0xFFEF4444, 'medical', false),
  ('education', 0xFF6366F1, 'education', false),
  ('entertainment', 0xFFA855F7, 'entertainment', false),
  ('utilities', 0xFFF59E0B, 'utilities', false),
  ('bills', 0xFF06B6D4, 'bills', false),
  ('salary', 0xFF22C55E, 'salary', true),
  ('investments', 0xFF14B8A6, 'investments', true),
  ('other', 0xFF8B5CF6, 'other', false),
];

Future<void> seedDefaultCategories(AppDatabase db) async {
  await db.batch((batch) {
    for (final (id, color, icon, isIncome) in defaultCategorySeeds) {
      batch.insert(
        db.categories,
        CategoriesCompanion.insert(
          id: id,
          // `name` is an English fallback; the UI shows the localized string
          // resolved from `nameKey`.
          name: id[0].toUpperCase() + id.substring(1),
          nameKey: Value(id),
          icon: Value(icon),
          color: color,
          isIncome: Value(isIncome),
          isDefault: const Value(true),
        ),
      );
    }
  });
}

/// Deterministic dummy data so the app is explorable on first run: ~3 months
/// of expenses, monthly salary, budgets and upcoming bills.
Future<void> seedDemoExpenses(AppDatabase db) async {
  final random = Random(42);
  final now = DateTime.now();

  const samples = <String, List<(String, double, double)>>{
    // categoryId: [(title, minAmount, maxAmount)]
    'food': [
      ('Lunch at cafe', 150, 600),
      ('Dinner out', 400, 1400),
      ('Coffee', 80, 250),
      ('Breakfast', 60, 200),
    ],
    'grocery': [
      ('Weekly groceries', 800, 2500),
      ('Vegetables & fruits', 200, 700),
      ('Supermarket run', 500, 1800),
    ],
    'fuel': [('Petrol refill', 500, 2000)],
    'shopping': [
      ('New shoes', 1200, 4000),
      ('Clothes', 800, 3500),
      ('Electronics', 1500, 8000),
    ],
    'travel': [('Cab ride', 120, 500), ('Metro card top-up', 200, 500)],
    'medical': [('Pharmacy', 150, 900), ('Doctor visit', 500, 1500)],
    'entertainment': [
      ('Movie night', 300, 900),
      ('Streaming subscription', 149, 649),
    ],
    'utilities': [('Electricity bill', 800, 2200), ('Water bill', 200, 500)],
    'education': [('Online course', 500, 2500), ('Books', 300, 1200)],
    'other': [('Miscellaneous', 100, 800)],
  };
  final methods = ['upi', 'card', 'cash', 'wallet'];
  final tagPool = [
    ['family'],
    ['office'],
    ['weekend'],
    ['friends'],
    <String>[],
    <String>[],
  ];

  var counter = 0;
  await db.batch((batch) {
    // Expenses over the last ~90 days.
    for (var dayOffset = 0; dayOffset < 90; dayOffset++) {
      final entriesToday = random.nextInt(3); // 0..2 per day
      for (var i = 0; i < entriesToday; i++) {
        final categoryId =
            samples.keys.elementAt(random.nextInt(samples.length));
        final options = samples[categoryId]!;
        final (title, minA, maxA) = options[random.nextInt(options.length)];
        final amount =
            (minA + random.nextDouble() * (maxA - minA)).roundToDouble();
        final date = now.subtract(Duration(
            days: dayOffset, hours: random.nextInt(12), minutes: random.nextInt(60)));
        batch.insert(
          db.expenses,
          ExpensesCompanion.insert(
            id: 'demo-e${counter++}',
            title: title,
            amount: amount,
            categoryId: categoryId,
            date: date,
            paymentMethod: Value(methods[random.nextInt(methods.length)]),
            tags: Value(jsonEncode(tagPool[random.nextInt(tagPool.length)])),
          ),
        );
      }
    }

    // Monthly salary for the last 3 months.
    for (var m = 0; m < 3; m++) {
      final date = DateTime(now.year, now.month - m, 1, 9);
      batch.insert(
        db.expenses,
        ExpensesCompanion.insert(
          id: 'demo-s$m',
          title: 'Monthly salary',
          amount: 65000,
          categoryId: 'salary',
          date: date,
          type: const Value('income'),
          paymentMethod: const Value('bankTransfer'),
        ),
      );
    }

    // Budgets.
    const budgets = <(String?, double)>[
      (null, 40000),
      ('food', 8000),
      ('grocery', 7000),
      ('shopping', 6000),
      ('fuel', 3500),
      ('entertainment', 2500),
    ];
    for (var i = 0; i < budgets.length; i++) {
      final (categoryId, amount) = budgets[i];
      batch.insert(
        db.budgets,
        BudgetsCompanion.insert(
          id: 'demo-b$i',
          categoryId: Value(categoryId),
          amount: amount,
        ),
      );
    }

    // Upcoming bills.
    final bills = <(String, double, int, String)>[
      ('House rent', 18000, 3, 'monthly'),
      ('Internet', 799, 6, 'monthly'),
      ('Electricity', 1450, 10, 'monthly'),
      ('Car insurance', 12500, 40, 'yearly'),
    ];
    for (var i = 0; i < bills.length; i++) {
      final (title, amount, inDays, recurrence) = bills[i];
      batch.insert(
        db.bills,
        BillsCompanion.insert(
          id: 'demo-bill$i',
          title: title,
          amount: amount,
          dueDate: DateTime(now.year, now.month, now.day + inDays, 9),
          recurrence: Value(recurrence),
        ),
      );
    }
  });
}
