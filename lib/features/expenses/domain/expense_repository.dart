import 'expense.dart';

/// Storage-agnostic contract. The app ships with a Drift (SQLite) offline
/// implementation; a synced remote implementation can be swapped in later.
abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchAll();
  Future<List<Expense>> getAll();
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<void> restoreAll(List<Expense> expenses);
}
