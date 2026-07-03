import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../features/expenses/domain/expense.dart';

/// Localized column headers / labels passed in from the UI layer so reports
/// honor the selected app language.
typedef ReportLabels = ({
  String reportTitle,
  String period,
  String colDate,
  String colTitle,
  String colCategory,
  String colType,
  String colMethod,
  String colAmount,
  String byCategory,
  String total,
  String income,
  String expense,
});

/// Generates PDF/CSV/Excel reports and hands them to the platform share sheet.
class ReportService {
  Future<void> sharePdf({
    required List<Expense> expenses,
    required Map<String, String> categoryNames,
    required ReportLabels labels,
    required String currencySymbol,
  }) async {
    final doc = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final totals = _categoryTotals(expenses, categoryNames);
    final totalSpent = _totalSpent(expenses);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(labels.reportTitle,
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(labels.period,
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('${labels.total}: $currencySymbol${totalSpent.toStringAsFixed(2)}',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text(labels.byCategory,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: [labels.colCategory, labels.colAmount],
            data: [
              for (final entry in totals.entries)
                [entry.key, '$currencySymbol${entry.value.toStringAsFixed(2)}'],
            ],
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellAlignments: {1: pw.Alignment.centerRight},
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: [
              labels.colDate,
              labels.colTitle,
              labels.colCategory,
              labels.colType,
              labels.colAmount,
            ],
            data: [
              for (final e in expenses)
                [
                  dateFormat.format(e.date),
                  e.title,
                  categoryNames[e.categoryId] ?? e.categoryId,
                  e.type == TransactionType.income
                      ? labels.income
                      : labels.expense,
                  '$currencySymbol${e.amount.toStringAsFixed(2)}',
                ],
            ],
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {4: pw.Alignment.centerRight},
          ),
        ],
      ),
    );

    final file = await _tempFile('pdf');
    await file.writeAsBytes(await doc.save());
    await _share(file.path, labels.reportTitle);
  }

  Future<void> shareCsv({
    required List<Expense> expenses,
    required Map<String, String> categoryNames,
    required ReportLabels labels,
  }) async {
    final rows = <List<dynamic>>[
      [
        labels.colDate,
        labels.colTitle,
        labels.colCategory,
        labels.colType,
        labels.colMethod,
        labels.colAmount,
        'Currency',
        'Tags',
        'Notes',
      ],
      for (final e in expenses)
        [
          DateFormat('yyyy-MM-dd HH:mm').format(e.date),
          e.title,
          categoryNames[e.categoryId] ?? e.categoryId,
          e.type.name,
          e.paymentMethod.name,
          e.amount,
          e.currency,
          e.tags.join('|'),
          e.notes,
        ],
    ];
    final file = await _tempFile('csv');
    await file.writeAsString(const ListToCsvConverter().convert(rows));
    await _share(file.path, labels.reportTitle);
  }

  Future<void> shareExcel({
    required List<Expense> expenses,
    required Map<String, String> categoryNames,
    required ReportLabels labels,
  }) async {
    final excel = xls.Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];
    sheet.appendRow([
      xls.TextCellValue(labels.colDate),
      xls.TextCellValue(labels.colTitle),
      xls.TextCellValue(labels.colCategory),
      xls.TextCellValue(labels.colType),
      xls.TextCellValue(labels.colMethod),
      xls.TextCellValue(labels.colAmount),
    ]);
    for (final e in expenses) {
      sheet.appendRow([
        xls.TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(e.date)),
        xls.TextCellValue(e.title),
        xls.TextCellValue(categoryNames[e.categoryId] ?? e.categoryId),
        xls.TextCellValue(e.type.name),
        xls.TextCellValue(e.paymentMethod.name),
        xls.DoubleCellValue(e.amount),
      ]);
    }
    final bytes = excel.encode();
    if (bytes == null) throw StateError('Excel encoding failed');
    final file = await _tempFile('xlsx');
    await file.writeAsBytes(bytes);
    await _share(file.path, labels.reportTitle);
  }

  Map<String, double> _categoryTotals(
      List<Expense> expenses, Map<String, String> categoryNames) {
    final totals = <String, double>{};
    for (final e in expenses.where((e) => e.type == TransactionType.expense)) {
      final name = categoryNames[e.categoryId] ?? e.categoryId;
      totals[name] = (totals[name] ?? 0) + e.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in sorted) e.key: e.value};
  }

  double _totalSpent(List<Expense> expenses) => expenses
      .where((e) => e.type == TransactionType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  Future<File> _tempFile(String extension) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyy-MM-dd-HHmmss').format(DateTime.now());
    return File(p.join(dir.path, 'verda-report-$stamp.$extension'));
  }

  Future<void> _share(String path, String subject) => SharePlus.instance
      .share(ShareParams(files: [XFile(path)], subject: subject));
}
