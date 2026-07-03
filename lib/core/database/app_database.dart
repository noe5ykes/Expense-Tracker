import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'seed.dart';

part 'app_database.g.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameKey => text().nullable()();
  TextColumn get icon => text().withDefault(const Constant('other'))();
  IntColumn get color => integer()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text().withDefault(const Constant('expense'))();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get receiptPaths => text().withDefault(const Constant('[]'))();
  TextColumn get location => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetRow')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BillRow')
class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get recurrence => text().withDefault(const Constant('monthly'))();
  BoolColumn get paid => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline-first local database. Repositories are the only consumers, so a
/// remote (Firebase/Supabase) implementation can replace them without
/// touching the UI layer.
@DriftDatabase(tables: [Categories, Expenses, Budgets, Bills])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e) : _seedDemoData = false;

  AppDatabase.open({bool withDemoData = true})
      : _seedDemoData = withDemoData,
        super(driftDatabase(name: 'verda_db'));

  final bool _seedDemoData;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedDefaultCategories(this);
          if (_seedDemoData) await seedDemoExpenses(this);
        },
      );
}
