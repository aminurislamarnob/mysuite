import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/note.dart';
import '../../state/notes_controller.dart';

/// Create/edit a note. Saves on back via [WillPopScope]-style interception so
/// quick captures are never lost. Markdown is supported as raw text (MVP).
class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key, this.note});

  final Note? note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late Note _working;
  bool _isNew = false;

  static const _palette = [
    null,
    AppColors.notes,
    AppColors.habits,
    AppColors.tasks,
    AppColors.expenses,
    AppColors.focus,
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.note;
    if (existing != null) {
      _working = existing;
    } else {
      _isNew = true;
      final now = DateTime.now();
      _working = Note(
        id: 'draft',
        title: '',
        body: '',
        createdAt: now,
        updatedAt: now,
      );
    }
    _title = TextEditingController(text: _working.title);
    _body = TextEditingController(text: _working.body);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _persist() {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty && body.isEmpty) {
      // Nothing worth saving; drop empty drafts.
      if (!_isNew) context.read<NotesController>().delete(_working.id);
      return;
    }
    final controller = context.read<NotesController>();
    if (_isNew) {
      final created = controller.create(title: title, body: body);
      created.tags = _working.tags;
      created.color = _working.color;
      controller.save(created);
      _working = created;
      _isNew = false;
    } else {
      _working
        ..title = title
        ..body = body;
      controller.save(_working);
    }
  }

  Future<void> _addTag() async {
    final ctrl = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add tag'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. journal'),
          onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
              child: const Text('Add')),
        ],
      ),
    );
    if (tag != null && tag.isNotEmpty) {
      setState(() => _working.tags = {..._working.tags, tag}.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) => _persist(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'New note' : 'Edit note'),
          actions: [
            IconButton(
              tooltip: 'Pin',
              icon: Icon(_working.pinned ? LucideIcons.pinOff : LucideIcons.pin),
              onPressed: () => setState(() => _working.pinned = !_working.pinned),
            ),
            if (!_isNew)
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(LucideIcons.trash2),
                onPressed: () {
                  context.read<NotesController>().delete(_working.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _title,
              style:
                  context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in _palette)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _working.color = c?.toARGB32()),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: c ?? context.colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _working.color == c?.toARGB32()
                                ? context.colors.primary
                                : context.muted.withValues(alpha: 0.4),
                            width: _working.color == c?.toARGB32() ? 2 : 1,
                          ),
                        ),
                        child: c == null
                            ? Icon(LucideIcons.ban,
                                size: 14, color: context.muted)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final t in _working.tags)
                  Chip(
                    label: Text('#$t'),
                    onDeleted: () => setState(() =>
                        _working.tags = _working.tags.where((x) => x != t).toList()),
                  ),
                ActionChip(
                  avatar: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Tag'),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _body,
              maxLines: null,
              minLines: 12,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Start writing… markdown supported',
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
