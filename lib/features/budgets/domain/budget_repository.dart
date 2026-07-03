import 'budget.dart';

abstract interface class BudgetRepository {
  Stream<List<Budget>> watchAll();
  Future<List<Budget>> getAll();
  Future<void> upsert(Budget budget);
  Future<void> delete(String id);
  Future<void> clearAll();
  Future<void> restoreAll(List<Budget> budgets);
}
