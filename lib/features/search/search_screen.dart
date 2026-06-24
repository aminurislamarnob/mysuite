import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/constants/modules.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/expenses_controller.dart';
import '../../state/habits_controller.dart';
import '../../state/medicine_controller.dart';
import '../../state/notes_controller.dart';
import '../../state/tasks_controller.dart';
import '../../widgets/common.dart';
import '../medicine/medicine_screen.dart';
import '../notes/note_editor_screen.dart';
import '../tasks/task_detail_sheet.dart';

class _Hit {
  _Hit(this.module, this.title, this.subtitle, this.onTap);
  final ModuleId module;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

/// Global search across notes, tasks, habits, medicines and expenses (spec 5).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';

  List<_Hit> _search(BuildContext context) {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return [];
    final hits = <_Hit>[];

    for (final n in context.read<NotesController>().notes) {
      if (n.title.toLowerCase().contains(q) ||
          n.body.toLowerCase().contains(q)) {
        hits.add(_Hit(
          ModuleId.notes,
          n.title.isEmpty ? n.preview : n.title,
          'Note',
          () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NoteEditorScreen(note: n))),
        ));
      }
    }
    for (final t in context.read<TasksController>().tasks) {
      if (t.title.toLowerCase().contains(q) ||
          t.notes.toLowerCase().contains(q)) {
        hits.add(_Hit(ModuleId.tasks, t.title,
            'Task · ${t.project}', () => TaskDetailSheet.show(context, t)));
      }
    }
    for (final h in context.read<HabitsController>().habits) {
      if (h.name.toLowerCase().contains(q)) {
        hits.add(_Hit(ModuleId.habits, h.name, 'Habit', () {}));
      }
    }
    for (final m in context.read<MedicineController>().medicines) {
      if (m.name.toLowerCase().contains(q)) {
        hits.add(_Hit(
            ModuleId.medicine,
            m.name,
            'Medicine · ${m.dosage}',
            () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MedicineScreen()))));
      }
    }
    for (final e in context.read<ExpensesController>().all) {
      if (e.category.toLowerCase().contains(q) ||
          e.note.toLowerCase().contains(q)) {
        hits.add(_Hit(ModuleId.expenses, '${e.category} · ${Fmt.money(e.amount)}',
            'Expense · ${Fmt.relativeDay(e.date)}', () {}));
      }
    }
    return hits;
  }

  @override
  Widget build(BuildContext context) {
    final hits = _search(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search everything…',
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: (v) => setState(() => _q = v),
        ),
      ),
      body: _q.trim().isEmpty
          ? const EmptyState(
              icon: LucideIcons.search,
              title: 'Search mySuite',
              message:
                  'Find notes, tasks, habits, medicines and expenses in one place.',
            )
          : hits.isEmpty
              ? EmptyState(
                  icon: LucideIcons.searchX,
                  title: 'No results',
                  message: 'Nothing matches "$_q".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hits.length,
                  itemBuilder: (_, i) {
                    final h = hits[i];
                    final info = moduleInfo(h.module);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: h.onTap,
                        child: Row(
                          children: [
                            IconBadge(info.icon, color: info.accent, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  Text(h.subtitle,
                                      style: context.text.bodySmall
                                          ?.copyWith(color: context.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
