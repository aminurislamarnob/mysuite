import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart' show DataClass;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';
import '../providers/database_provider.dart';
import '../utils/formatters.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(databaseProvider));
});

/// CSV, JSON and PDF export plus OS share-sheet integration.
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  static const _csv = CsvEncoder();

  Future<File> _write(String name, String contents) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(contents);
    return file;
  }

  Future<void> _share(File file, {String? text}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );
  }

  Future<void> shareText(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  // --- CSV -----------------------------------------------------------------

  Future<File> tasksCsv() async {
    final tasks = await _db.select(_db.tasks).get();
    final rows = <List<dynamic>>[
      ['ID', 'Title', 'Description', 'Priority', 'Due', 'Completed', 'Project'],
      ...tasks.map(
        (t) => [
          t.id,
          t.title,
          t.description ?? '',
          'P${t.priority}',
          t.dueDate?.toIso8601String() ?? '',
          t.isCompleted ? 'yes' : 'no',
          t.projectId ?? '',
        ],
      ),
    ];
    return _write('mysuite_tasks.csv', _csv.convert(rows));
  }

  Future<File> expensesCsv({DateTime? from, DateTime? to}) async {
    final all = await _db.select(_db.expenses).get();
    final categories = {
      for (final c in await _db.select(_db.expenseCategories).get())
        c.id: c.name,
    };
    final accounts = {
      for (final a in await _db.select(_db.accounts).get()) a.id: a.name,
    };

    final filtered = all.where((e) {
      if (from != null && e.date.isBefore(from)) return false;
      if (to != null && e.date.isAfter(to)) return false;
      return true;
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Amount', 'Category', 'Account', 'Note'],
      ...filtered.map(
        (e) => [
          Fmt.iso(e.date),
          switch (e.kind) {
            1 => 'Income',
            2 => 'Transfer',
            3 => 'Lent',
            4 => 'Borrowed',
            5 => 'Repayment',
            _ => 'Expense',
          },
          e.amount,
          categories[e.categoryId] ?? '',
          accounts[e.accountId] ?? '',
          e.note ?? '',
        ],
      ),
    ];
    return _write('mysuite_expenses.csv', _csv.convert(rows));
  }

  Future<File> medicineCsv() async {
    final doses = await _db.select(_db.medicineDoses).get();
    final meds = {
      for (final m in await _db.select(_db.medicines).get()) m.id: m,
    };
    final rows = <List<dynamic>>[
      ['Date', 'Time', 'Medicine', 'Dosage', 'Status'],
      ...(doses..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime)))
          .map((d) {
            final m = meds[d.medicineId];
            return [
              Fmt.iso(d.scheduledTime),
              Fmt.time(d.scheduledTime),
              m?.name ?? '',
              m == null ? '' : '${m.dosage} ${m.dosageUnit}',
              switch (d.status) {
                1 => 'Taken',
                2 => 'Skipped',
                _ => 'Pending',
              },
            ];
          }),
    ];
    return _write('mysuite_medicine.csv', _csv.convert(rows));
  }

  Future<File> habitsCsv() async {
    final logs = await _db.select(_db.habitLogs).get();
    final habits = {
      for (final h in await _db.select(_db.habits).get()) h.id: h,
    };
    final rows = <List<dynamic>>[
      ['Date', 'Habit', 'Amount', 'Unit', 'Note'],
      ...(logs..sort((a, b) => a.date.compareTo(b.date))).map(
        (l) => [
          Fmt.iso(l.date),
          habits[l.habitId]?.name ?? '',
          l.amount,
          habits[l.habitId]?.unit ?? '',
          l.note ?? '',
        ],
      ),
    ];
    return _write('mysuite_habits.csv', _csv.convert(rows));
  }

  // --- JSON (full backup) --------------------------------------------------

  /// A complete, restorable snapshot of every table, written to a file.
  Future<File> fullJsonBackup() async => _write(
    'mysuite_backup_${Fmt.iso(DateTime.now())}.json',
    const JsonEncoder.withIndent('  ').convert(await fullBackupData()),
  );

  /// What a backup contains, separate from where it is written.
  ///
  /// This is the shape a future restore has to read, so it is kept apart from
  /// the file writing — which needs a documents directory, and with it a
  /// platform channel the tests have no business standing up.
  Future<Map<String, dynamic>> fullBackupData() async {
    return <String, dynamic>{
      'version': _db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'folders': (await _db.select(_db.folders).get()).map(_json).toList(),
      'notes': (await _db.select(_db.notes).get()).map(_json).toList(),
      'tags': (await _db.select(_db.tags).get()).map(_json).toList(),
      'noteTags': (await _db.select(_db.noteTags).get()).map(_json).toList(),
      'projects': (await _db.select(_db.projects).get()).map(_json).toList(),
      'tasks': (await _db.select(_db.tasks).get()).map(_json).toList(),
      'taskTags': (await _db.select(_db.taskTags).get()).map(_json).toList(),
      'habits': (await _db.select(_db.habits).get()).map(_json).toList(),
      'habitLogs': (await _db.select(_db.habitLogs).get()).map(_json).toList(),
      'accounts': (await _db.select(_db.accounts).get()).map(_json).toList(),
      'categories': (await _db.select(_db.expenseCategories).get())
          .map(_json)
          .toList(),
      'expenses': (await _db.select(_db.expenses).get()).map(_json).toList(),
      'budgets': (await _db.select(_db.budgets).get()).map(_json).toList(),
      'recurringExpenses': (await _db.select(_db.recurringExpenses).get())
          .map(_json)
          .toList(),
      'people': await _peopleJson(),
      'loans': (await _db.select(_db.loans).get()).map(_json).toList(),
      'medicines': (await _db.select(_db.medicines).get()).map(_json).toList(),
      'medicineDoses': (await _db.select(_db.medicineDoses).get())
          .map(_json)
          .toList(),
      'symptomLogs': (await _db.select(_db.symptomLogs).get())
          .map(_json)
          .toList(),
      'focusSessions': (await _db.select(_db.focusSessions).get())
          .map(_json)
          .toList(),
    };
  }

  Map<String, dynamic> _json(DataClass row) => row.toJson();

  /// People, with each avatar carried as base64 rather than the path it lives
  /// at.
  ///
  /// A stored path is meaningless once restored: it names a directory on the
  /// device that wrote it, and iOS rewrites that directory on every reinstall,
  /// so even the same phone would not find the file. Embedding the bytes keeps
  /// the backup true to its own label. A 512px avatar is around 50KB, which is
  /// nothing beside the note and expense history alongside it.
  Future<List<Map<String, dynamic>>> _peopleJson() async {
    final rows = await _db.select(_db.people).get();
    return [
      for (final row in rows)
        {
          ..._json(row),
          'photoPath': null,
          'photoData': await _photoData(row.photoPath),
        },
    ];
  }

  /// The avatar's bytes, or null when there is none or it has gone missing —
  /// an unreadable file should cost the backup a photo, not the whole export.
  Future<String?> _photoData(String? path) async {
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      return base64Encode(await file.readAsBytes());
    } on IOException {
      return null;
    }
  }

  // --- PDF -----------------------------------------------------------------

  Future<File> _savePdf(String name, pw.Document doc) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  /// Printable dose schedule for a doctor's visit.
  Future<File> medicineSchedulePdf({
    required String profileName,
    required List<
      ({String medicine, String dosage, String meal, DateTime at, int status})
    >
    doses,
    double? adherence,
  }) async {
    final doc = pw.Document();
    final byDay = <String, List<int>>{};
    for (var i = 0; i < doses.length; i++) {
      byDay.putIfAbsent(Fmt.iso(doses[i].at), () => []).add(i);
    }
    final days = byDay.keys.toList()..sort();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Medicine Schedule',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Profile: $profileName'),
              if (adherence != null)
                pw.Text('Adherence: ${Fmt.percent(adherence)}'),
              pw.Text(
                'Generated ${Fmt.dayMonthYear(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Divider(),
            ],
          ),
        ),
        build: (_) => [
          for (final day in days) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              Fmt.fullDate(DateTime.parse(day)),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.SizedBox(height: 4),
            pw.TableHelper.fromTextArray(
              headers: const [
                'Time',
                'Medicine',
                'Dosage',
                'Instruction',
                'Status',
              ],
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              data: byDay[day]!.map((i) {
                final d = doses[i];
                return [
                  Fmt.time(d.at),
                  d.medicine,
                  d.dosage,
                  d.meal,
                  switch (d.status) {
                    1 => 'Taken',
                    2 => 'Skipped',
                    _ => 'Pending',
                  },
                ];
              }).toList(),
            ),
          ],
        ],
      ),
    );
    return _savePdf('medicine_schedule.pdf', doc);
  }

  Future<File> expenseReportPdf({
    required String title,
    required String currency,
    required double totalIncome,
    required double totalExpense,
    required Map<String, double> byCategory,
    required List<
      ({DateTime date, String category, String note, double amount, int kind})
    >
    rows,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated ${Fmt.dayMonthYear(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfStat('Income', '$currency${totalIncome.toStringAsFixed(0)}'),
              _pdfStat(
                'Expense',
                '$currency${totalExpense.toStringAsFixed(0)}',
              ),
              _pdfStat(
                'Net',
                '$currency${(totalIncome - totalExpense).toStringAsFixed(0)}',
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'By category',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const ['Category', 'Amount', 'Share'],
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            data: byCategory.entries.map((e) {
              final share = totalExpense == 0 ? 0.0 : e.value / totalExpense;
              return [
                e.key,
                '$currency${e.value.toStringAsFixed(0)}',
                Fmt.percent(share),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Transactions',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Category', 'Note', 'Amount'],
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            data: rows
                .map(
                  (r) => [
                    Fmt.dayMonth(r.date),
                    r.category,
                    r.note,
                    '${r.kind == 1 ? '+' : '-'}$currency'
                        '${r.amount.toStringAsFixed(0)}',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return _savePdf('expense_report.pdf', doc);
  }

  static pw.Widget _pdfStat(String label, String value) => pw.Column(
    children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 2),
      pw.Text(
        value,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    ],
  );

  Future<File> noteAsPdf({required String title, required String body}) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            body,
            style: const pw.TextStyle(fontSize: 11, lineSpacing: 3),
          ),
        ],
      ),
    );
    return _savePdf('note.pdf', doc);
  }

  // --- Share convenience ---------------------------------------------------

  Future<void> shareNoteAsPdf({
    required String title,
    required String body,
  }) async {
    await _share(
      await noteAsPdf(title: title, body: body),
      text: title,
    );
  }

  Future<void> shareFile(File file, {String? text}) => _share(file, text: text);
}
