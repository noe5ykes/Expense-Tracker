import 'category.dart';

abstract interface class CategoryRepository {
  Stream<List<Category>> watchAll();
  Future<List<Category>> getAll();
  Future<void> add(Category category);
  Future<void> update(Category category);

  /// Deletes [id] and reassigns its expenses to the fallback "other" category.
  Future<void> delete(String id);
  Future<void> restoreAll(List<Category> categories);
}
