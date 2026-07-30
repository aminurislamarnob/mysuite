import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:forui/forui.dart';

import '../../core/database/app_database.dart';
import '../../core/services/export_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/security_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../tasks/repository/task_repository.dart';
import 'repository/note_repository.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final int? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  quill.QuillController? _controller;
  final _titleController = TextEditingController();
  final _editorFocus = FocusNode();
  final _speech = stt.SpeechToText();

  Note? _note;
  bool _loading = true;
  bool _unlocked = false;
  bool _listening = false;
  bool _dirty = false;
  List<String> _tags = [];
  int? _folderId;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(noteRepositoryProvider);
    quill.Document document;

    if (widget.noteId != null) {
      _note = await repo.getNote(widget.noteId!);
      if (_note != null) {
        _titleController.text = _note!.title;
        _folderId = _note!.folderId;
        _reminderAt = _note!.reminderAt;
        _tags = (await repo.tagsForNote(_note!.id)).map((t) => t.name).toList();
        document = _parseDelta(_note!.content);
        _unlocked = !_note!.isLocked;
      } else {
        document = quill.Document();
      }
    } else {
      document = quill.Document();
      _unlocked = true;
    }

    _controller =
        quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        )..addListener(() {
          if (!_dirty && mounted) setState(() => _dirty = true);
        });

    if (mounted) setState(() => _loading = false);

    if (_note?.isLocked == true) await _requestUnlock();
  }

  quill.Document _parseDelta(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List && decoded.isNotEmpty) {
        return quill.Document.fromJson(decoded);
      }
    } catch (_) {
      // Corrupt or legacy content falls back to an empty document rather than
      // crashing the editor and stranding the user.
    }
    return quill.Document();
  }

  Future<void> _requestUnlock() async {
    final ok = await ref
        .read(securityServiceProvider)
        .authenticate(reason: 'Unlock "${_note?.title ?? 'this note'}"');
    if (!mounted) return;
    if (ok) {
      setState(() => _unlocked = true);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _titleController.dispose();
    _editorFocus.dispose();
    _speech.stop();
    super.dispose();
  }

  String get _contentJson =>
      jsonEncode(_controller!.document.toDelta().toJson());

  Future<void> _save({bool pop = true}) async {
    final repo = ref.read(noteRepositoryProvider);
    final title = _titleController.text.trim().isEmpty
        ? 'Untitled'
        : _titleController.text.trim();

    int id;
    if (_note == null) {
      id = await repo.createNote(
        title: title,
        contentJson: _contentJson,
        folderId: _folderId,
      );
      _note = await repo.getNote(id);
    } else {
      id = _note!.id;
      await repo.updateNote(
        id,
        title: title,
        contentJson: _contentJson,
        folderId: _folderId,
        clearFolder: _folderId == null,
        reminderAt: _reminderAt,
        clearReminder: _reminderAt == null,
      );
    }
    await repo.setNoteTags(id, _tags);

    final notifier = ref.read(notificationServiceProvider);
    if (_reminderAt != null) {
      await notifier.scheduleNoteReminder(
        noteId: id,
        title: title,
        when: _reminderAt!,
      );
    } else {
      await notifier.cancelNoteReminder(id);
    }

    _dirty = false;
    if (pop && mounted) Navigator.of(context).pop();
  }

  /// Pulls unchecked checklist lines out of the note and creates tasks.
  ///
  /// Quill stores list formatting on the newline op that *terminates* a line,
  /// so the text of the item is whatever preceded that newline.
  Future<void> _convertChecklistToTasks() async {
    final ops = _controller!.document.toDelta().toJson();
    final items = <String>[];
    final buffer = StringBuffer();

    for (final op in ops) {
      final insert = op['insert'];
      if (insert is! String) continue;
      final attrs = op['attributes'] as Map?;

      for (var i = 0; i < insert.length; i++) {
        final ch = insert[i];
        if (ch == '\n') {
          // A newline carrying an `unchecked` list attribute closes a to-do.
          if (attrs != null && attrs['list'] == 'unchecked') {
            final text = buffer.toString().trim();
            if (text.isNotEmpty) items.add(text);
          }
          buffer.clear();
        } else {
          buffer.write(ch);
        }
      }
    }

    if (items.isEmpty) {
      _toast('No unchecked checklist items found in this note.');
      return;
    }

    final repo = ref.read(taskRepositoryProvider);
    for (final title in items) {
      await repo.createTask(title: title);
    }
    _toast('Added ${items.length} task${items.length == 1 ? '' : 's'}.');
  }

  Future<void> _toggleDictation() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final available = await _speech.initialize();
    if (!available) {
      _toast('Speech recognition is not available on this device.');
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        if (!r.finalResult) return;
        final index = _controller!.selection.baseOffset.clamp(
          0,
          _controller!.document.length - 1,
        );
        _controller!.document.insert(index, '${r.recognizedWords} ');
        _controller!.updateSelection(
          TextSelection.collapsed(offset: index + r.recognizedWords.length + 1),
          quill.ChangeSource.local,
        );
      },
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    brandToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _controller == null) {
      return BrandScaffold(child: Center(child: FCircularProgress()));
    }
    if (_note?.isLocked == true && !_unlocked) {
      return BrandScaffold(
        header: BrandTopBar(title: '', leadingIcon: AppIcons.back),
        child: EmptyState(
          icon: AppIcons.lock,
          title: 'Note locked',
          message: 'Authenticate to view this note.',
          actionLabel: 'Unlock',
          onAction: _requestUnlock,
        ),
      );
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _save();
      },
      child: BrandScaffold(
        header: BrandTopBar(
          title: _note == null ? 'New note' : 'Edit note',
          leadingIcon: AppIcons.back,
          actions: [
            CircleIconButton(
              icon: _listening ? AppIcons.mic : AppIcons.mic,
              tooltip: _listening ? 'Stop dictation' : 'Dictate',
              color: _listening ? AppColors.dangerLight : null,
              size: 40,
              onPressed: _toggleDictation,
            ),
            CircleIconButton(
              icon: AppIcons.moreVertical,
              tooltip: 'More',
              size: 40,
              onPressed: _showMoreSheet,
            ),
            CircleIconButton(
              icon: AppIcons.check,
              tooltip: 'Save',
              size: 40,
              onPressed: _save,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: BrandField(
                controller: _titleController,
                hint: 'Title',
                bare: true,
                onChanged: (_) => _dirty = true,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (_tags.isNotEmpty || _reminderAt != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (_reminderAt != null)
                      BrandChip(
                        icon: AppIcons.alarm,
                        label: Fmt.due(_reminderAt!, withTime: true),
                        onRemove: () => setState(() => _reminderAt = null),
                      ),
                    ..._tags.map(
                      (t) => BrandChip(
                        label: '#$t',
                        onRemove: () => setState(() => _tags.remove(t)),
                      ),
                    ),
                  ],
                ),
              ),
            FDivider(),
            quill.QuillSimpleToolbar(
              controller: _controller!,
              config: const quill.QuillSimpleToolbarConfig(
                multiRowsDisplay: false,
                showFontFamily: false,
                showFontSize: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showAlignmentButtons: true,
                showCodeBlock: true,
                showInlineCode: true,
                showListCheck: true,
                showQuote: true,
                showIndent: true,
                showDividers: true,
                showLink: true,
              ),
            ),
            FDivider(),
            Expanded(
              child: quill.QuillEditor.basic(
                controller: _controller!,
                focusNode: _editorFocus,
                config: const quill.QuillEditorConfig(
                  placeholder: 'Start writing…',
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                  expands: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreSheet() {
    brandSheet(
      context: context,
      builder: (sheetContext) => SheetScaffold(
        title: 'Note options',
        child: Column(
          children: [
            BrandTile(
              leading: const AppIcon(AppIcons.tag),
              title: const Text('Tags'),
              subtitle: Text(_tags.isEmpty ? 'None' : _tags.join(', ')),
              onTap: () {
                Navigator.pop(sheetContext);
                _editTags();
              },
            ),
            BrandTile(
              leading: const AppIcon(AppIcons.folder),
              title: const Text('Move to folder'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFolder();
              },
            ),
            BrandTile(
              leading: const AppIcon(AppIcons.alarmAdd),
              title: const Text('Set reminder'),
              subtitle: _reminderAt == null
                  ? null
                  : Text(Fmt.due(_reminderAt!, withTime: true)),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickReminder();
              },
            ),
            FDivider(),
            BrandTile(
              leading: const AppIcon(AppIcons.checklist),
              title: const Text('Convert checklist to tasks'),
              onTap: () {
                Navigator.pop(sheetContext);
                _convertChecklistToTasks();
              },
            ),
            BrandTile(
              leading: const AppIcon(AppIcons.pdf),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _save(pop: false);
                await ref
                    .read(exportServiceProvider)
                    .shareNoteAsPdf(
                      title: _titleController.text.trim(),
                      body: NoteRepository.plainTextOf(_contentJson),
                    );
              },
            ),
            BrandTile(
              leading: const AppIcon(AppIcons.share),
              title: const Text('Share as text'),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref
                    .read(exportServiceProvider)
                    .shareText(
                      '${_titleController.text}\n\n'
                      '${NoteRepository.plainTextOf(_contentJson)}',
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTags() async {
    final controller = TextEditingController(text: _tags.join(', '));
    final result = await brandDialog<String>(
      context,
      title: 'Tags',
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandField(
            controller: controller,
            hint: 'work, ideas, urgent',
            helper: 'Separate with commas',
            autofocus: true,
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: 'Save',
            onPressed: () => Navigator.pop(dialogContext, controller.text),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() {
      _tags = result
          .split(',')
          .map((e) => e.trim().replaceAll('#', ''))
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      _dirty = true;
    });
  }

  Future<void> _pickFolder() async {
    final folders = await ref.read(noteRepositoryProvider).watchFolders().first;
    if (!mounted) return;
    final picked = await brandSheet<int?>(
      context: context,
      builder: (_) => SheetScaffold(
        title: 'Move to folder',
        child: Column(
          children: [
            BrandTile(
              leading: const AppIcon(AppIcons.clear),
              title: const Text('No folder'),
              onTap: () => Navigator.pop(context, -1),
            ),
            ...folders.map(
              (f) => BrandTile(
                leading: const AppIcon(AppIcons.folder),
                title: Text(f.name),
                selected: f.id == _folderId,
                onTap: () => Navigator.pop(context, f.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _folderId = picked == -1 ? null : picked;
      _dirty = true;
    });
  }

  Future<void> _pickReminder() async {
    final fallback = DateTime.now().add(const Duration(hours: 1));
    final date = await brandDatePicker(
      context,
      initial: _reminderAt ?? fallback,
      first: DateTime.now().subtract(const Duration(days: 1)),
      last: DateTime.now().add(const Duration(days: 3650)),
      title: 'Reminder date',
    );
    if (date == null || !mounted) return;
    final at = _reminderAt ?? fallback;
    final minutes = await brandTimePicker(
      context,
      initialMinutes: at.hour * 60 + at.minute,
      title: 'Reminder time',
    );
    if (minutes == null) return;
    setState(() {
      _reminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        minutes ~/ 60,
        minutes % 60,
      );
      _dirty = true;
    });
  }
}
