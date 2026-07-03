import 'bill.dart';

abstract interface class BillRepository {
  Stream<List<Bill>> watchAll();
  Future<List<Bill>> getAll();
  Future<void> add(Bill bill);
  Future<void> update(Bill bill);
  Future<void> delete(String id);

  /// Marks a bill paid. Recurring bills roll forward to their next due date.
  Future<void> markPaid(Bill bill);
  Future<void> clearAll();
  Future<void> restoreAll(List<Bill> bills);
}
