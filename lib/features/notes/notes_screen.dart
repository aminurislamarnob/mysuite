import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/note.dart';
import '../../state/notes_controller.dart';
import '../../widgets/common.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _query = '';
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotesController>();
    var notes = controller.notes;
    if (_tag != null) {
      notes = notes.where((n) => n.tags.contains(_tag)).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      notes = notes
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.body.toLowerCase().contains(q))
          .toList();
    }
    final tags = controller.allTags.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, null),
        icon: const Icon(LucideIcons.plus),
        label: const Text('New note'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes',
                prefixIcon: Icon(LucideIcons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (tags.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _tag == null,
                    onSelected: (_) => setState(() => _tag = null),
                  ),
                  const SizedBox(width: 8),
                  for (final t in tags) ...[
                    FilterChip(
                      label: Text('#$t'),
                      selected: _tag == t,
                      onSelected: (s) => setState(() => _tag = s ? t : null),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          Expanded(
            child: notes.isEmpty
                ? EmptyState(
                    icon: LucideIcons.notebookPen,
                    title: 'No notes yet',
                    message: 'Capture ideas, journals and lists.',
                    action: FilledButton.icon(
                      onPressed: () => _openEditor(context, null),
                      icon: const Icon(LucideIcons.plus),
                      label: const Text('New note'),
                    ),
                  )
                : MasonryGrid(notes: notes, onTap: (n) => _openEditor(context, n)),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context, Note? note) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }
}

/// Simple staggered two-column note grid.
class MasonryGrid extends StatelessWidget {
  const MasonryGrid({super.key, required this.notes, required this.onTap});

  final List<Note> notes;
  final void Function(Note) onTap;

  @override
  Widget build(BuildContext context) {
    final left = <Note>[];
    final right = <Note>[];
    for (var i = 0; i < notes.length; i++) {
      (i.isEven ? left : right).add(notes[i]);
    }
    Widget column(List<Note> items) => Column(
          children: [
            for (final n in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NoteCard(note: n, onTap: () => onTap(n)),
              ),
          ],
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: column(left)),
          const SizedBox(width: 12),
          Expanded(child: column(right)),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<NotesController>();
    return AppCard(
      onTap: onTap,
      color: note.color != null ? Color(note.color!).withValues(alpha: 0.12) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (note.title.isNotEmpty)
                Expanded(
                  child: Text(note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                )
              else
                const Spacer(),
              InkWell(
                onTap: () => controller.togglePin(note),
                child: Icon(
                  LucideIcons.pin,
                  size: 16,
                  color: note.pinned ? AppColors.notes : context.muted,
                ),
              ),
            ],
          ),
          if (note.preview.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(note.preview,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text(Fmt.relativeDay(note.updatedAt),
                  style:
                      context.text.labelSmall?.copyWith(color: context.muted)),
              const Spacer(),
              if (note.tags.isNotEmpty)
                Text('#${note.tags.first}',
                    style: context.text.labelSmall
                        ?.copyWith(color: AppColors.notes)),
            ],
          ),
        ],
      ),
    );
  }
}
