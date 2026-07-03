import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/seed.dart';
import '../domain/category.dart' as domain;
import '../domain/category_repository.dart';

class DriftCategoryRepository implements CategoryRepository {
  final AppDatabase db;
  DriftCategoryRepository(this.db);

  @override
  Stream<List<domain.Category>> watchAll() {
    final query = db.select(db.categories)
      ..orderBy([
        (t) => OrderingTerm.desc(t.isDefault),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Category>> getAll() async {
    final rows = await db.select(db.categories).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> add(domain.Category category) =>
      db.into(db.categories).insert(_toRow(category));

  @override
  Future<void> update(domain.Category category) =>
      db.update(db.categories).replace(_toRow(category));

  @override
  Future<void> delete(String id) => db.transaction(() async {
        // Keep referential integrity: move orphaned expenses to "other".
        await (db.update(db.expenses)..where((t) => t.categoryId.equals(id)))
            .write(const ExpensesCompanion(categoryId: Value('other')));
        await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
      });

  @override
  Future<void> restoreAll(List<domain.Category> categories) =>
      db.transaction(() async {
        await db.delete(db.categories).go();
        if (categories.isEmpty) {
          await seedDefaultCategories(db);
          return;
        }
        await db.batch((batch) {
          batch.insertAll(db.categories, categories.map(_toRow));
        });
      });

  static domain.Category _toDomain(CategoryRow row) => domain.Category(
        id: row.id,
        name: row.name,
        nameKey: row.nameKey,
        icon: row.icon,
        color: row.color,
        isIncome: row.isIncome,
        isDefault: row.isDefault,
      );

  static CategoryRow _toRow(domain.Category c) => CategoryRow(
        id: c.id,
        name: c.name,
        nameKey: c.nameKey,
        icon: c.icon,
        color: c.color,
        isIncome: c.isIncome,
        isDefault: c.isDefault,
      );
}
