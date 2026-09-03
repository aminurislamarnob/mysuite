import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import 'providers/notes_provider.dart';
import 'repository/note_repository.dart';
import 'utils/note_templates.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);
    final filter = ref.watch(noteFilterProvider);
    final repo = ref.read(noteRepositoryProvider);

    return BrandScaffold(
      header: BrandTopBar(
        title: filter.title,
        // The folder list was a Scaffold drawer opened by the AppBar hamburger;
        // FScaffold has neither, so it is now an explicit left-hand sheet.
        leadingIcon: AppIcons.folder,
        onLeading: () => brandSideSheet(
          context: context,
          builder: (_) => const _NotesDrawer(),
        ),
        actions: [
          CircleIconButton(
            icon: AppIcons.search,
            tooltip: 'Search',
            size: 40,
            onPressed: () => context.push('/search'),
          ),
          CircleIconButton(
            icon: AppIcons.journal,
            tooltip: "Today's journal",
            size: 40,
            onPressed: () async {
              final note = await repo.journalNoteFor(DateTime.now());
              if (context.mounted) context.push('/note_editor', extra: note.id);
            },
          ),
          if (filter.scope == NoteScope.trash)
            CircleIconButton(
              icon: AppIcons.deleteForever,
              tooltip: 'Empty trash',
              size: 40,
              onPressed: () async {
                final ok = await confirmDialog(
                  context,
                  'Empty trash?',
                  'Every note in the trash will be permanently deleted.',
                );
                if (ok) await repo.emptyTrash();
              },
            ),
        ],
      ),
      floatingAction: filter.scope == NoteScope.trash
          ? null
          : BrandFab(
              icon: AppIcons.add,
              tooltip: 'New note',
              onPressed: () => newNoteFlow(context, ref),
            ),
      child: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return EmptyState(
              icon: AppIcons.notes,
              title: switch (filter.scope) {
                NoteScope.trash => 'Trash is empty',
                NoteScope.archived => 'Nothing archived',
                NoteScope.favorites => 'No favorites yet',
                NoteScope.active => 'No notes yet',
              },
              message: filter.scope == NoteScope.active
                  ? 'Create your first note to get started.'
                  : null,
              actionLabel: filter.scope == NoteScope.active ? 'New note' : null,
              onAction: () => newNoteFlow(context, ref),
            );
          }
          return MasonryGridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: notes.length,
            itemBuilder: (context, i) =>
                _NoteCard(note: notes[i], scope: filter.scope),
          );
        },
        loading: () => const Center(child: BrandSpinner()),
        error: (e, _) => EmptyState(
          icon: AppIcons.error,
          title: 'Could not load notes',
          message: '$e',
        ),
      ),
    );
  }
}

/// Presents the template picker, creates the note and opens the editor.
Future<void> newNoteFlow(
  BuildContext context,
  WidgetRef ref, {
  int? folderId,
}) async {
  final template = await brandSheet<NoteTemplate>(
    context: context,
    builder: (_) => SheetScaffold(
      title: 'New note',
      child: TileColumn(
        children: NoteTemplate.all
            .map(
              (t) => BrandTile(
                leading: AppIcon(t.icon, color: AppColors.noteAccent),
                title: Text(t.name),
                onTap: () => Navigator.pop(context, t),
              ),
            )
            .toList(),
      ),
    ),
  );
  if (template == null || !context.mounted) return;

  final id = await ref
      .read(noteRepositoryProvider)
      .createNote(
        title: template.title,
        contentJson: template.contentJson,
        folderId: folderId ?? ref.read(noteFilterProvider).folderId,
      );
  if (context.mounted) context.push('/note_editor', extra: id);
}

/// Kept as a positional shorthand for this screen's two call sites; the dialog
/// itself is the shared [brandConfirm].
Future<bool> confirmDialog(
  BuildContext context,
  String title,
  String body,
) => brandConfirm(
  context,
  title: title,
  message: body,
  confirmLabel: 'Confirm',
);

class _NoteCard extends ConsumerWidget {
  final Note note;
  final NoteScope scope;

  const _NoteCard({required this.note, required this.scope});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(noteRepositoryProvider);
    final muted = Theme.of(context).colorScheme.outline;
    final preview = note.isLocked
        ? 'This note is locked.'
        : NoteRepository.previewOf(note.content);
    final tagsAsync = ref.watch(tagsForNoteProvider(note.id));

    return TintCard(
      padding: EdgeInsets.zero,
      onTap: () {
        if (scope == NoteScope.trash) return;
        context.push('/note_editor', extra: note.id);
      },
      onLongPress: () => _showActions(context, repo),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const AppIcon(
                      AppIcons.pin,
                      size: 14,
                      color: AppColors.noteAccent,
                    ),
                  if (note.isLocked)
                    AppIcon(AppIcons.lock, size: 14, color: muted),
                ],
              ),
              if (preview.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  preview,
                  style: TextStyle(color: muted, fontSize: 13, height: 1.35),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              tagsAsync.maybeWhen(
                data: (tags) => tags.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: tags
                              .map(
                                (t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      t.color,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '#${t.name}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(t.color),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 10),
              Text(
                scope == NoteScope.trash && note.deletedAt != null
                    ? 'Deleted ${Fmt.relativeDay(note.deletedAt!)}'
                    : Fmt.relativeDay(note.updatedAt),
                style: TextStyle(fontSize: 11, color: muted),
              ),
            ],
          ),
      ),
    );
  }

  void _showActions(BuildContext context, NoteRepository repo) {
    brandSheet(
      context: context,
      builder: (_) => SheetScaffold(
        title: note.title,
        child: TileColumn(
          children: scope == NoteScope.trash
              ? [
                  BrandTile(
                    leading: const AppIcon(AppIcons.restore),
                    title: const Text('Restore'),
                    onTap: () {
                      repo.restoreFromTrash(note.id);
                      Navigator.pop(context);
                    },
                  ),
                  BrandTile(
                    leading: const AppIcon(AppIcons.deleteForever),
                    title: const Text('Delete forever'),
                    onTap: () {
                      repo.deleteForever(note.id);
                      Navigator.pop(context);
                    },
                  ),
                ]
              : [
                  BrandTile(
                    leading: AppIcon(
                      note.isPinned ? AppIcons.pin : AppIcons.pin,
                    ),
                    title: Text(note.isPinned ? 'Unpin' : 'Pin to top'),
                    onTap: () {
                      repo.updateNote(note.id, isPinned: !note.isPinned);
                      Navigator.pop(context);
                    },
                  ),
                  BrandTile(
                    leading: AppIcon(
                      note.isFavorite ? AppIcons.star : AppIcons.star,
                    ),
                    title: Text(
                      note.isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                    ),
                    onTap: () {
                      repo.updateNote(note.id, isFavorite: !note.isFavorite);
                      Navigator.pop(context);
                    },
                  ),
                  BrandTile(
                    leading: AppIcon(
                      note.isArchived ? AppIcons.unarchive : AppIcons.archive,
                    ),
                    title: Text(note.isArchived ? 'Unarchive' : 'Archive'),
                    onTap: () {
                      repo.updateNote(note.id, isArchived: !note.isArchived);
                      Navigator.pop(context);
                    },
                  ),
                  BrandTile(
                    leading: AppIcon(
                      note.isLocked ? AppIcons.unlock : AppIcons.lock,
                    ),
                    title: Text(note.isLocked ? 'Remove lock' : 'Lock note'),
                    onTap: () {
                      repo.updateNote(note.id, isLocked: !note.isLocked);
                      Navigator.pop(context);
                    },
                  ),
                  BrandTile(
                    leading: const AppIcon(AppIcons.delete),
                    title: const Text('Move to trash'),
                    onTap: () {
                      repo.moveToTrash(note.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
        ),
      ),
    );
  }
}

class _NotesDrawer extends ConsumerWidget {
  const _NotesDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider);
    final tags = ref.watch(noteTagsProvider);
    final trashCount = ref.watch(trashCountProvider).valueOrNull ?? 0;
    final filter = ref.watch(noteFilterProvider);

    void apply(NoteFilter f) {
      ref.read(noteFilterProvider.notifier).state = f;
      Navigator.pop(context);
    }

    // Stays a Material `Drawer` body, not an `FSidebar`: the rows are already
    // branded (`_DrawerItem`, `Pill`), and FSidebar's own item model would
    // reimpose forui's neutral styling on them. The panel itself is a
    // `brandSideSheet`, so nothing Material-looking reaches the screen.
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.noteAccent),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _DrawerItem(
            icon: AppIcons.notes,
            label: 'All Notes',
            selected: filter == const NoteFilter(),
            onTap: () => apply(const NoteFilter()),
          ),
          _DrawerItem(
            icon: AppIcons.star,
            label: 'Favorites',
            selected: filter.scope == NoteScope.favorites,
            onTap: () => apply(const NoteFilter(scope: NoteScope.favorites)),
          ),
          _DrawerItem(
            icon: AppIcons.archive,
            label: 'Archive',
            selected: filter.scope == NoteScope.archived,
            onTap: () => apply(const NoteFilter(scope: NoteScope.archived)),
          ),
          _DrawerItem(
            icon: AppIcons.delete,
            label: 'Trash',
            trailing: trashCount > 0 ? '$trashCount' : null,
            selected: filter.scope == NoteScope.trash,
            onTap: () => apply(const NoteFilter(scope: NoteScope.trash)),
          ),
          BrandDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Folders',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                CircleIconButton(
                  icon: AppIcons.add,
                  size: 40,
                  onPressed: () => _createFolder(context, ref),
                ),
              ],
            ),
          ),
          folders.maybeWhen(
            data: (list) => Column(
              children: list
                  .map(
                    (f) => _DrawerItem(
                      icon: AppIcons.folder,
                      label: f.name,
                      selected: filter.folderId == f.id,
                      onTap: () =>
                          apply(NoteFilter(folderId: f.id, label: f.name)),
                      onLongPress: () async {
                        Navigator.pop(context);
                        final ok = await confirmDialog(
                          context,
                          'Delete folder?',
                          'Notes inside will be kept and moved to All Notes.',
                        );
                        if (ok) {
                          await ref
                              .read(noteRepositoryProvider)
                              .deleteFolder(f.id);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          BrandDivider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Tags', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          tags.maybeWhen(
            data: (list) => list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Text(
                      'Tags you add to notes appear here.',
                      style: TextStyle(fontSize: 12),
                    ),
                  )
                : Column(
                    children: list
                        .map(
                          (t) => _DrawerItem(
                            icon: AppIcons.tag,
                            iconColor: Color(t.color),
                            label: '#${t.name}',
                            selected: filter.tagId == t.id,
                            onTap: () => apply(
                              NoteFilter(tagId: t.id, label: '#${t.name}'),
                            ),
                          ),
                        )
                        .toList(),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await brandDialog<String>(
      context,
      title: 'New folder',
      builder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BrandField(
            controller: controller,
            hint: 'Folder name',
            autofocus: true,
            onSubmit: (v) => Navigator.pop(dialogContext, v),
          ),
          const SizedBox(height: 20),
          BrandButton(
            label: 'Create',
            onPressed: () => Navigator.pop(dialogContext, controller.text),
          ),
          const SizedBox(height: 8),
          BrandButton(
            label: 'Cancel',
            kind: BrandButtonKind.ghost,
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(noteRepositoryProvider).createFolder(name.trim());
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final HugeIconData icon;
  final Color? iconColor;
  final String label;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconColor,
    this.trailing,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: cardGap),
      child: BrandTile(
        selected: selected,
        leading: AppIcon(icon, size: 20, color: iconColor),
        title: Text(label, overflow: TextOverflow.ellipsis),
        trailing: trailing == null
            ? null
            : Text(trailing!, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
