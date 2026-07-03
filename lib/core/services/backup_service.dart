import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/bills/domain/bill.dart';
import '../../features/bills/domain/bill_repository.dart';
import '../../features/budgets/domain/budget.dart';
import '../../features/budgets/domain/budget_repository.dart';
import '../../features/expenses/domain/category.dart';
import '../../features/expenses/domain/category_repository.dart';
import '../../features/expenses/domain/expense.dart';
import '../../features/expenses/domain/expense_repository.dart';

/// Full JSON export/import of the local database. The format is versioned so
/// future cloud sync can reuse it.
class BackupService {
  final ExpenseRepository expenses;
  final CategoryRepository categories;
  final BudgetRepository budgets;
  final BillRepository bills;

  BackupService({
    required this.expenses,
    required this.categories,
    required this.budgets,
    required this.bills,
  });

  Future<Map<String, dynamic>> buildBackup() async => {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'categories': (await categories.getAll()).map((c) => c.toJson()).toList(),
        'expenses': (await expenses.getAll()).map((e) => e.toJson()).toList(),
        'budgets': (await budgets.getAll()).map((b) => b.toJson()).toList(),
        'bills': (await bills.getAll()).map((b) => b.toJson()).toList(),
      };

  Future<void> exportAndShare() async {
    final backup = await buildBackup();
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyy-MM-dd-HHmm').format(DateTime.now());
    final file = File(p.join(dir.path, 'verda-backup-$stamp.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(backup));
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'Verda backup'),
    );
  }

  /// Lets the user pick a backup file and restores it. Returns false when the
  /// user cancels; throws [FormatException] on invalid files.
  Future<bool> pickAndRestore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return false;
    final raw = await File(path).readAsString();
    await restoreFromJson(raw);
    return true;
  }

  Future<void> restoreFromJson(String raw) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['version'] == null) {
      throw const FormatException('Not a Verda backup file');
    }
    final restoredCategories = [
      for (final json in decoded['categories'] as List? ?? [])
        Category.fromJson(json as Map<String, dynamic>)
    ];
    final restoredExpenses = [
      for (final json in decoded['expenses'] as List? ?? [])
        Expense.fromJson(json as Map<String, dynamic>)
    ];
    final restoredBudgets = [
      for (final json in decoded['budgets'] as List? ?? [])
        Budget.fromJson(json as Map<String, dynamic>)
    ];
    final restoredBills = [
      for (final json in decoded['bills'] as List? ?? [])
        Bill.fromJson(json as Map<String, dynamic>)
    ];
    await categories.restoreAll(restoredCategories);
    await expenses.restoreAll(restoredExpenses);
    await budgets.restoreAll(restoredBudgets);
    await bills.restoreAll(restoredBills);
  }
}
