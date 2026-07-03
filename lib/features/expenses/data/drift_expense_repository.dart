import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/expense.dart';
import '../domain/expense_repository.dart';

class DriftExpenseRepository implements ExpenseRepository {
  final AppDatabase db;
  DriftExpenseRepository(this.db);

  @override
  Stream<List<Expense>> watchAll() {
    final query = db.select(db.expenses)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Expense>> getAll() async {
    final rows = await (db.select(db.expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> add(Expense expense) =>
      db.into(db.expenses).insert(_toRow(expense));

  @override
  Future<void> update(Expense expense) =>
      db.update(db.expenses).replace(_toRow(expense));

  @override
  Future<void> delete(String id) =>
      (db.delete(db.expenses)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> clearAll() => db.delete(db.expenses).go();

  @override
  Future<void> restoreAll(List<Expense> expenses) => db.transaction(() async {
        await db.delete(db.expenses).go();
        await db.batch((batch) {
          batch.insertAll(db.expenses, expenses.map(_toRow));
        });
      });

  static Expense _toDomain(ExpenseRow row) => Expense(
        id: row.id,
        title: row.title,
        amount: row.amount,
        categoryId: row.categoryId,
        date: row.date,
        type: TransactionType.values.byName(row.type),
        paymentMethod: PaymentMethod.values.byName(row.paymentMethod),
        notes: row.notes,
        tags: (jsonDecode(row.tags) as List).cast<String>(),
        currency: row.currency,
        receiptPaths: (jsonDecode(row.receiptPaths) as List).cast<String>(),
        location: row.location,
      );

  static ExpenseRow _toRow(Expense e) => ExpenseRow(
        id: e.id,
        title: e.title,
        amount: e.amount,
        categoryId: e.categoryId,
        date: e.date,
        type: e.type.name,
        paymentMethod: e.paymentMethod.name,
        notes: e.notes,
        tags: jsonEncode(e.tags),
        currency: e.currency,
        receiptPaths: jsonEncode(e.receiptPaths),
        location: e.location,
      );
}
