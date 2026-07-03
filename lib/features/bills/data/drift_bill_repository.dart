import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/bill.dart';
import '../domain/bill_repository.dart';

class DriftBillRepository implements BillRepository {
  final AppDatabase db;
  DriftBillRepository(this.db);

  @override
  Stream<List<Bill>> watchAll() {
    final query = db.select(db.bills)
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<List<Bill>> getAll() async {
    final rows = await db.select(db.bills).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> add(Bill bill) => db.into(db.bills).insert(_toRow(bill));

  @override
  Future<void> update(Bill bill) => db.update(db.bills).replace(_toRow(bill));

  @override
  Future<void> delete(String id) =>
      (db.delete(db.bills)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> markPaid(Bill bill) {
    final next = bill.nextDueDate;
    if (next == null) {
      return update(bill.copyWith(paid: true));
    }
    return update(bill.copyWith(dueDate: next, paid: false));
  }

  @override
  Future<void> clearAll() => db.delete(db.bills).go();

  @override
  Future<void> restoreAll(List<Bill> bills) => db.transaction(() async {
        await db.delete(db.bills).go();
        await db.batch((batch) {
          batch.insertAll(db.bills, bills.map(_toRow));
        });
      });

  static Bill _toDomain(BillRow row) => Bill(
        id: row.id,
        title: row.title,
        amount: row.amount,
        dueDate: row.dueDate,
        recurrence: BillRecurrence.values.byName(row.recurrence),
        paid: row.paid,
      );

  static BillRow _toRow(Bill b) => BillRow(
        id: b.id,
        title: b.title,
        amount: b.amount,
        dueDate: b.dueDate,
        recurrence: b.recurrence.name,
        paid: b.paid,
      );
}
