import '../../../core/database/app_database.dart';
import '../domain/budget.dart';
import '../domain/budget_repository.dart';

class DriftBudgetRepository implements BudgetRepository {
  final AppDatabase db;
  DriftBudgetRepository(this.db);

  @override
  Stream<List<Budget>> watchAll() =>
      db.select(db.budgets).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<List<Budget>> getAll() async {
    final rows = await db.select(db.budgets).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> upsert(Budget budget) =>
      db.into(db.budgets).insertOnConflictUpdate(_toRow(budget));

  @override
  Future<void> delete(String id) =>
      (db.delete(db.budgets)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> clearAll() => db.delete(db.budgets).go();

  @override
  Future<void> restoreAll(List<Budget> budgets) => db.transaction(() async {
        await db.delete(db.budgets).go();
        await db.batch((batch) {
          batch.insertAll(db.budgets, budgets.map(_toRow));
        });
      });

  static Budget _toDomain(BudgetRow row) =>
      Budget(id: row.id, categoryId: row.categoryId, amount: row.amount);

  static BudgetRow _toRow(Budget b) =>
      BudgetRow(id: b.id, categoryId: b.categoryId, amount: b.amount);
}
