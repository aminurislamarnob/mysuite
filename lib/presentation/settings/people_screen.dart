import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../core/database/app_database.dart';
import '../../core/people/avatar_picker.dart';
import '../../core/people/person_avatar.dart';
import '../../core/people/people_repository.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';

/// The one list of people the whole app draws on: the household doubles as
/// medicine profiles and who an expense was for, contacts are who money is
/// lent to or borrowed from.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider).valueOrNull ?? const [];
    final household = people
        .where((p) => p.type == PersonType.household)
        .toList();
    final contacts = people.where((p) => p.type == PersonType.contact).toList();

    return BrandScaffold(
      header: BrandTopBar(
        title: 'People',
        leadingIcon: AppIcons.back,
        actions: [
          CircleIconButton(
            icon: AppIcons.personAdd,
            tooltip: 'Add person',
            size: 40,
            onPressed: () => PersonEditor.show(context, ref),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const SectionHeader('Household'),
          TintCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [for (final p in household) _PersonRow(person: p)],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Contacts'),
          if (contacts.isEmpty)
            const EmptyState(
              icon: AppIcons.people,
              title: 'No contacts yet',
              message: 'People you lend to or borrow from land here.',
            )
          else
            TintCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [for (final p in contacts) _PersonRow(person: p)],
              ),
            ),
        ],
      ),
    );
  }
}

class _PersonRow extends ConsumerWidget {
  final Person person;
  const _PersonRow({required this.person});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = Theme.of(context).colorScheme.outline;
    final color = Color(person.color);

    return BrandTile(
      dense: true,
      leading: PersonAvatar(
        photoPath: person.photoPath,
        color: color,
        size: 36,
      ),
      title: Text(
        person.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        person.relation,
        style: TextStyle(fontSize: 11, color: muted),
      ),
      // Self is what everything falls back to, so it can be renamed but
      // never removed.
      trailing: person.isSelf
          ? null
          : CircleIconButton(
              icon: AppIcons.delete,
              tooltip: 'Delete',
              size: 40,
              onPressed: () => _delete(context, ref),
            ),
      onTap: () => PersonEditor.show(context, ref, person: person),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(peopleRepositoryProvider);
    final count = await repo.referenceCount(person.id);
    if (!context.mounted) return;

    final ok = await brandConfirm(
      context,
      title: 'Delete ${person.name}?',
      message: count == 0
          ? null
          : 'Their $count ${count == 1 ? 'record' : 'records'} move to Self.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok) await repo.deletePerson(person.id);
  }
}

/// The create / edit dialog, shared with the loan sheet's quick-add.
class PersonEditor {
  PersonEditor._();

  /// Returns the id of the created or edited person, or null if dismissed.
  static Future<int?> show(
    BuildContext context,
    WidgetRef ref, {
    Person? person,
    String type = PersonType.household,
  }) async {
    final name = TextEditingController(text: person?.name ?? '');
    final relation = TextEditingController(
      text:
          person?.relation ??
          (type == PersonType.contact ? 'Friend' : 'Family'),
    );
    var kind = person?.type ?? type;
    var color = person?.color ?? 0xFFFF6547;
    final isSelf = person?.isSelf ?? false;

    // The photo is only committed on Save: a new person has no id to attach it
    // to until then, and Cancel should leave the stored one untouched.
    File? picked;
    var cleared = false;

    final saved = await brandDialog<bool>(
      context,
      title: person == null ? 'New person' : 'Edit person',
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _PhotoWell(
                // A fresh pick wins over the stored photo; clearing hides both.
                file: picked,
                photoPath: cleared ? null : person?.photoPath,
                color: Color(color),
                onTap: () async {
                  final choice = await pickAvatar(
                    dialogContext,
                    hasPhoto:
                        picked != null ||
                        (!cleared && person?.photoPath != null),
                  );
                  if (choice == null) return;
                  setState(() {
                    switch (choice) {
                      case AvatarPicked(:final file):
                        picked = file;
                        cleared = false;
                      case AvatarCleared():
                        picked = null;
                        cleared = true;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 18),
            BrandField(controller: name, label: 'Name', autofocus: true),
            const SizedBox(height: 12),
            BrandField(
              controller: relation,
              label: 'Relation',
              hint: 'Wife, son, friend',
            ),
            // Self is the household by definition.
            if (!isSelf) ...[
              const SizedBox(height: 16),
              BrandSegmented<String>(
                options: const {
                  PersonType.household: 'Household',
                  PersonType.contact: 'Contact',
                },
                selected: kind,
                onSelected: (v) => setState(() => kind = v),
              ),
            ],
            const SizedBox(height: 16),
            ColorPickerRow(
              selected: color,
              onChanged: (c) => setState(() => color = c),
            ),
            const SizedBox(height: 20),
            BrandButton(
              label: person == null ? 'Create' : 'Save',
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
            const SizedBox(height: 8),
            BrandButton(
              label: 'Cancel',
              kind: BrandButtonKind.ghost,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
          ],
        ),
      ),
    );

    if (saved != true || name.text.trim().isEmpty) return null;
    final repo = ref.read(peopleRepositoryProvider);
    if (person == null) {
      final id = await repo.createPerson(
        name: name.text.trim(),
        relation: relation.text.trim(),
        color: color,
        type: kind,
      );
      // Only now is there a row to hang the photo on.
      if (picked != null) await repo.setPhoto(id, picked!);
      return id;
    }
    await repo.updatePerson(
      person.id,
      name: name.text.trim(),
      relation: relation.text.trim(),
      color: color,
      type: isSelf ? null : kind,
      // setPhoto handles a replacement, so only an explicit clear is written
      // through here.
      photoPath: cleared && picked == null
          ? const Value(null)
          : const Value.absent(),
    );
    if (picked != null) await repo.setPhoto(person.id, picked!);
    return person.id;
  }
}

/// The editor's photo control: the avatar with a camera badge, so it reads as
/// something to press rather than a picture of the person.
class _PhotoWell extends StatelessWidget {
  final File? file;
  final String? photoPath;
  final Color color;
  final VoidCallback onTap;

  const _PhotoWell({
    required this.file,
    required this.photoPath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FTappable(
      onPress: onTap,
      semanticsLabel: 'Change photo',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A file just picked has no stored path yet, so it is drawn directly.
          if (file != null)
            ClipOval(
              child: Image.file(
                file!,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            )
          else
            PersonAvatar(photoPath: photoPath, color: color, size: 84),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: const AppIcon(
                AppIcons.camera,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
