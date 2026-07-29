import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/database_provider.dart';
import '../../core/settings/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';

enum ResultKind { note, task, habit, medicine, expense, focus }

extension ResultKindX on ResultKind {
  String get label => switch (this) {
        ResultKind.note => 'Note',
        ResultKind.task => 'Task',
        ResultKind.habit => 'Habit',
        ResultKind.medicine => 'Medicine',
        ResultKind.expense => 'Expense',
        ResultKind.focus => 'Focus',
      };

  HugeIconData get icon => switch (this) {
        ResultKind.note => AppIcons.notes,
        ResultKind.task => AppIcons.tasks,
        ResultKind.habit => AppIcons.habits,
        ResultKind.medicine => AppIcons.medicine,
        ResultKind.expense => AppIcons.expenses,
        ResultKind.focus => AppIcons.focus,
      };

  Color get color => switch (this) {
        ResultKind.note => AppColors.noteAccent,
        ResultKind.task => AppColors.taskAccent,
        ResultKind.habit => AppColors.habitAccent,
        ResultKind.medicine => AppColors.medicineAccent,
        ResultKind.expense => AppColors.expenseAccent,
        ResultKind.focus => AppColors.focusAccent,
      };

  AppModule get module => switch (this) {
        ResultKind.note => AppModule.notes,
        ResultKind.task => AppModule.tasks,
        ResultKind.habit => AppModule.habits,
        ResultKind.medicine => AppModule.medicine,
        ResultKind.expense => AppModule.expenses,
        ResultKind.focus => AppModule.focus,
      };
}

class SearchHit {
  final String title;
  final String subtitle;
  final ResultKind kind;
  final int id;

  const SearchHit({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.id,
  });
}

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Restricts results to one module; null shows everything.
final searchKindFilterProvider = StateProvider<ResultKind?>((ref) => null);

/// Searches every enabled module. Notes match on their flattened plain text
/// as well as the title, so body content is findable.
final searchResultsProvider = FutureProvider<List<SearchHit>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.length < 2) return const [];

  final db = ref.watch(databaseProvider);
  final settings = ref.watch(settingsProvider);
  final filter = ref.watch(searchKindFilterProvider);
  final like = '%$query%';
  final hits = <SearchHit>[];

  bool wants(ResultKind kind) =>
      settings.isEnabled(kind.module) && (filter == null || filter == kind);

  if (wants(ResultKind.note)) {
    final rows = await (db.select(db.notes)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.title.lower().like(like) | t.plainText.lower().like(like))))
        .get();
    hits.addAll(rows.map((n) => SearchHit(
          title: n.title,
          subtitle: n.plainText.isEmpty
              ? Fmt.relativeDay(n.updatedAt)
              : n.plainText.length > 70
                  ? '${n.plainText.substring(0, 70)}…'
                  : n.plainText,
          kind: ResultKind.note,
          id: n.id,
        )));
  }

  if (wants(ResultKind.task)) {
    final rows = await (db.select(db.tasks)
          ..where((t) =>
              t.title.lower().like(like) | t.description.lower().like(like)))
        .get();
    hits.addAll(rows.map((t) => SearchHit(
          title: t.title,
          subtitle: t.dueDate == null
              ? (t.isCompleted ? 'Completed' : 'No due date')
              : Fmt.due(t.dueDate!, withTime: t.hasDueTime),
          kind: ResultKind.task,
          id: t.id,
        )));
  }

  if (wants(ResultKind.habit)) {
    final rows = await (db.select(db.habits)
          ..where((t) => t.name.lower().like(like)))
        .get();
    hits.addAll(rows.map((h) => SearchHit(
          title: h.name,
          subtitle: h.goalType == 0
              ? 'Build · target ${h.targetAmount.toStringAsFixed(0)} ${h.unit ?? ''}'
              : 'Reduce · limit ${h.targetAmount.toStringAsFixed(0)} ${h.unit ?? ''}',
          kind: ResultKind.habit,
          id: h.id,
        )));
  }

  if (wants(ResultKind.medicine)) {
    final rows = await (db.select(db.medicines)
          ..where((t) =>
              t.name.lower().like(like) |
              t.doctorName.lower().like(like) |
              t.notes.lower().like(like)))
        .get();
    hits.addAll(rows.map((m) => SearchHit(
          title: m.name,
          subtitle: '${m.dosage.toStringAsFixed(0)} ${m.dosageUnit} · '
              'until ${Fmt.dayMonth(m.endDate)}',
          kind: ResultKind.medicine,
          id: m.id,
        )));
  }

  if (wants(ResultKind.expense)) {
    final rows = await (db.select(db.expenses)
          ..where((t) => t.note.lower().like(like)))
        .get();
    hits.addAll(rows.map((e) => SearchHit(
          title: e.note ?? 'Transaction',
          subtitle:
              '${settings.currencySymbol}${e.amount.toStringAsFixed(0)} · ${Fmt.relativeDay(e.date)}',
          kind: ResultKind.expense,
          id: e.id,
        )));
  }

  if (wants(ResultKind.focus)) {
    final rows = await (db.select(db.focusSessions)
          ..where((t) => t.note.lower().like(like)))
        .get();
    hits.addAll(rows.map((s) => SearchHit(
          title: s.note ?? 'Focus session',
          subtitle:
              '${Fmt.duration(Duration(seconds: s.actualSeconds))} · ${Fmt.relativeDay(s.startTime)}',
          kind: ResultKind.focus,
          id: s.id,
        )));
  }

  // Exact title matches first, then everything else alphabetically.
  hits.sort((a, b) {
    final aExact = a.title.toLowerCase().startsWith(query) ? 0 : 1;
    final bExact = b.title.toLowerCase().startsWith(query) ? 0 : 1;
    if (aExact != bExact) return aExact - bExact;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  });

  return hits;
});
