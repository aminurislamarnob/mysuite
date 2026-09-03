// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String name;
  final int? parentId;
  final DateTime createdAt;
  const Folder({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      createdAt: Value(createdAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<int?>(parentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Folder copyWith({
    int? id,
    String? name,
    Value<int?> parentId = const Value.absent(),
    DateTime? createdAt,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    createdAt: createdAt ?? this.createdAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.createdAt == this.createdAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> parentId;
  final Value<DateTime> createdAt;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.parentId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? parentId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? parentId,
    Value<DateTime>? createdAt,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Untitled'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id)',
    ),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journalDateMeta = const VerificationMeta(
    'journalDate',
  );
  @override
  late final GeneratedColumn<DateTime> journalDate = GeneratedColumn<DateTime>(
    'journal_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderAtMeta = const VerificationMeta(
    'reminderAt',
  );
  @override
  late final GeneratedColumn<DateTime> reminderAt = GeneratedColumn<DateTime>(
    'reminder_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    content,
    plainText,
    folderId,
    isPinned,
    isFavorite,
    isArchived,
    isLocked,
    deletedAt,
    journalDate,
    reminderAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('journal_date')) {
      context.handle(
        _journalDateMeta,
        journalDate.isAcceptableOrUnknown(
          data['journal_date']!,
          _journalDateMeta,
        ),
      );
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
        _reminderAtMeta,
        reminderAt.isAcceptableOrUnknown(data['reminder_at']!, _reminderAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      journalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}journal_date'],
      ),
      reminderAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String title;
  final String content;
  final String plainText;
  final int? folderId;
  final bool isPinned;
  final bool isFavorite;
  final bool isArchived;
  final bool isLocked;

  /// Set when the note is moved to trash; purged 30 days later.
  final DateTime? deletedAt;

  /// Marks a note created by journal mode, keyed to a single calendar day.
  final DateTime? journalDate;
  final DateTime? reminderAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.plainText,
    this.folderId,
    required this.isPinned,
    required this.isFavorite,
    required this.isArchived,
    required this.isLocked,
    this.deletedAt,
    this.journalDate,
    this.reminderAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['content'] = Variable<String>(content);
    map['plain_text'] = Variable<String>(plainText);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || journalDate != null) {
      map['journal_date'] = Variable<DateTime>(journalDate);
    }
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<DateTime>(reminderAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      content: Value(content),
      plainText: Value(plainText),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      isPinned: Value(isPinned),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      isLocked: Value(isLocked),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      journalDate: journalDate == null && nullToAbsent
          ? const Value.absent()
          : Value(journalDate),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String>(json['content']),
      plainText: serializer.fromJson<String>(json['plainText']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      journalDate: serializer.fromJson<DateTime?>(json['journalDate']),
      reminderAt: serializer.fromJson<DateTime?>(json['reminderAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String>(content),
      'plainText': serializer.toJson<String>(plainText),
      'folderId': serializer.toJson<int?>(folderId),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'isLocked': serializer.toJson<bool>(isLocked),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'journalDate': serializer.toJson<DateTime?>(journalDate),
      'reminderAt': serializer.toJson<DateTime?>(reminderAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? plainText,
    Value<int?> folderId = const Value.absent(),
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isLocked,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> journalDate = const Value.absent(),
    Value<DateTime?> reminderAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    plainText: plainText ?? this.plainText,
    folderId: folderId.present ? folderId.value : this.folderId,
    isPinned: isPinned ?? this.isPinned,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    isLocked: isLocked ?? this.isLocked,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    journalDate: journalDate.present ? journalDate.value : this.journalDate,
    reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      journalDate: data.journalDate.present
          ? data.journalDate.value
          : this.journalDate,
      reminderAt: data.reminderAt.present
          ? data.reminderAt.value
          : this.reminderAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('plainText: $plainText, ')
          ..write('folderId: $folderId, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('isLocked: $isLocked, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('journalDate: $journalDate, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    content,
    plainText,
    folderId,
    isPinned,
    isFavorite,
    isArchived,
    isLocked,
    deletedAt,
    journalDate,
    reminderAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.plainText == this.plainText &&
          other.folderId == this.folderId &&
          other.isPinned == this.isPinned &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.isLocked == this.isLocked &&
          other.deletedAt == this.deletedAt &&
          other.journalDate == this.journalDate &&
          other.reminderAt == this.reminderAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> content;
  final Value<String> plainText;
  final Value<int?> folderId;
  final Value<bool> isPinned;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<bool> isLocked;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> journalDate;
  final Value<DateTime?> reminderAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.plainText = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.journalDate = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    required String content,
    this.plainText = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.journalDate = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : content = Value(content);
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? plainText,
    Expression<int>? folderId,
    Expression<bool>? isPinned,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<bool>? isLocked,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? journalDate,
    Expression<DateTime>? reminderAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (plainText != null) 'plain_text': plainText,
      if (folderId != null) 'folder_id': folderId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (isLocked != null) 'is_locked': isLocked,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (journalDate != null) 'journal_date': journalDate,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? content,
    Value<String>? plainText,
    Value<int?>? folderId,
    Value<bool>? isPinned,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<bool>? isLocked,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? journalDate,
    Value<DateTime?>? reminderAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      plainText: plainText ?? this.plainText,
      folderId: folderId ?? this.folderId,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isLocked: isLocked ?? this.isLocked,
      deletedAt: deletedAt ?? this.deletedAt,
      journalDate: journalDate ?? this.journalDate,
      reminderAt: reminderAt ?? this.reminderAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (journalDate.present) {
      map['journal_date'] = Variable<DateTime>(journalDate.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<DateTime>(reminderAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('plainText: $plainText, ')
          ..write('folderId: $folderId, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('isLocked: $isLocked, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('journalDate: $journalDate, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF6C6C6C),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final int color;
  const Tag({required this.id, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name), color: Value(color));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
    };
  }

  Tag copyWith({int? id, String? name, int? color}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags with TableInfo<$NoteTagsTable, NoteTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<int> noteId = GeneratedColumn<int>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES notes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [noteId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, tagId};
  @override
  NoteTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTag(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}note_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }
}

class NoteTag extends DataClass implements Insertable<NoteTag> {
  final int noteId;
  final int tagId;
  const NoteTag({required this.noteId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<int>(noteId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  NoteTagsCompanion toCompanion(bool nullToAbsent) {
    return NoteTagsCompanion(noteId: Value(noteId), tagId: Value(tagId));
  }

  factory NoteTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTag(
      noteId: serializer.fromJson<int>(json['noteId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<int>(noteId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  NoteTag copyWith({int? noteId, int? tagId}) =>
      NoteTag(noteId: noteId ?? this.noteId, tagId: tagId ?? this.tagId);
  NoteTag copyWithCompanion(NoteTagsCompanion data) {
    return NoteTag(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTag(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTag &&
          other.noteId == this.noteId &&
          other.tagId == this.tagId);
}

class NoteTagsCompanion extends UpdateCompanion<NoteTag> {
  final Value<int> noteId;
  final Value<int> tagId;
  final Value<int> rowid;
  const NoteTagsCompanion({
    this.noteId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTagsCompanion.insert({
    required int noteId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       tagId = Value(tagId);
  static Insertable<NoteTag> custom({
    Expression<int>? noteId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTagsCompanion copyWith({
    Value<int>? noteId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return NoteTagsCompanion(
      noteId: noteId ?? this.noteId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<int>(noteId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagsCompanion(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF5B7CE0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, icon, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final int color;
  final String icon;
  final int sortOrder;
  const Project({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['icon'] = Variable<String>(icon);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'icon': serializer.toJson<String>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    int? color,
    String? icon,
    int? sortOrder,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, icon, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<String> icon;
  final Value<int> sortOrder;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? color,
    Value<String>? icon,
    Value<int>? sortOrder,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasDueTimeMeta = const VerificationMeta(
    'hasDueTime',
  );
  @override
  late final GeneratedColumn<bool> hasDueTime = GeneratedColumn<bool>(
    'has_due_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_due_time" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<DateTime> reminderTime = GeneratedColumn<DateTime>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _parentTaskIdMeta = const VerificationMeta(
    'parentTaskId',
  );
  @override
  late final GeneratedColumn<int> parentTaskId = GeneratedColumn<int>(
    'parent_task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta(
    'recurrenceRule',
  );
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardStatusMeta = const VerificationMeta(
    'boardStatus',
  );
  @override
  late final GeneratedColumn<int> boardStatus = GeneratedColumn<int>(
    'board_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _estimateMinutesMeta = const VerificationMeta(
    'estimateMinutes',
  );
  @override
  late final GeneratedColumn<int> estimateMinutes = GeneratedColumn<int>(
    'estimate_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedMinutesMeta = const VerificationMeta(
    'loggedMinutes',
  );
  @override
  late final GeneratedColumn<int> loggedMinutes = GeneratedColumn<int>(
    'logged_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    dueDate,
    hasDueTime,
    reminderTime,
    priority,
    projectId,
    parentTaskId,
    recurrenceRule,
    boardStatus,
    estimateMinutes,
    loggedMinutes,
    isCompleted,
    completedAt,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('has_due_time')) {
      context.handle(
        _hasDueTimeMeta,
        hasDueTime.isAcceptableOrUnknown(
          data['has_due_time']!,
          _hasDueTimeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(
        _parentTaskIdMeta,
        parentTaskId.isAcceptableOrUnknown(
          data['parent_task_id']!,
          _parentTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(
          data['recurrence_rule']!,
          _recurrenceRuleMeta,
        ),
      );
    }
    if (data.containsKey('board_status')) {
      context.handle(
        _boardStatusMeta,
        boardStatus.isAcceptableOrUnknown(
          data['board_status']!,
          _boardStatusMeta,
        ),
      );
    }
    if (data.containsKey('estimate_minutes')) {
      context.handle(
        _estimateMinutesMeta,
        estimateMinutes.isAcceptableOrUnknown(
          data['estimate_minutes']!,
          _estimateMinutesMeta,
        ),
      );
    }
    if (data.containsKey('logged_minutes')) {
      context.handle(
        _loggedMinutesMeta,
        loggedMinutes.isAcceptableOrUnknown(
          data['logged_minutes']!,
          _loggedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      hasDueTime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_due_time'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_time'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      ),
      parentTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_task_id'],
      ),
      recurrenceRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence_rule'],
      ),
      boardStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}board_status'],
      )!,
      estimateMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimate_minutes'],
      ),
      loggedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}logged_minutes'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String? description;
  final DateTime? dueDate;

  /// True when [dueDate] carries a meaningful time-of-day, false for all-day.
  final bool hasDueTime;
  final DateTime? reminderTime;
  final int priority;
  final int? projectId;

  /// Parent task for subtasks; null for top-level tasks.
  final int? parentTaskId;

  /// Simple recurrence token: daily | weekly | monthly | yearly | weekdays
  final String? recurrenceRule;

  /// Kanban column: 0=To Do, 1=Doing, 2=Done
  final int boardStatus;

  /// Minutes estimated, used by the Focus timer bridge.
  final int? estimateMinutes;

  /// Minutes actually focused against this task.
  final int loggedMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sortOrder;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.hasDueTime,
    this.reminderTime,
    required this.priority,
    this.projectId,
    this.parentTaskId,
    this.recurrenceRule,
    required this.boardStatus,
    this.estimateMinutes,
    required this.loggedMinutes,
    required this.isCompleted,
    this.completedAt,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['has_due_time'] = Variable<bool>(hasDueTime);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<DateTime>(reminderTime);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<int>(parentTaskId);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    map['board_status'] = Variable<int>(boardStatus);
    if (!nullToAbsent || estimateMinutes != null) {
      map['estimate_minutes'] = Variable<int>(estimateMinutes);
    }
    map['logged_minutes'] = Variable<int>(loggedMinutes);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      hasDueTime: Value(hasDueTime),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      priority: Value(priority),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      parentTaskId: parentTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentTaskId),
      recurrenceRule: recurrenceRule == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRule),
      boardStatus: Value(boardStatus),
      estimateMinutes: estimateMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimateMinutes),
      loggedMinutes: Value(loggedMinutes),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      hasDueTime: serializer.fromJson<bool>(json['hasDueTime']),
      reminderTime: serializer.fromJson<DateTime?>(json['reminderTime']),
      priority: serializer.fromJson<int>(json['priority']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      parentTaskId: serializer.fromJson<int?>(json['parentTaskId']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      boardStatus: serializer.fromJson<int>(json['boardStatus']),
      estimateMinutes: serializer.fromJson<int?>(json['estimateMinutes']),
      loggedMinutes: serializer.fromJson<int>(json['loggedMinutes']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'hasDueTime': serializer.toJson<bool>(hasDueTime),
      'reminderTime': serializer.toJson<DateTime?>(reminderTime),
      'priority': serializer.toJson<int>(priority),
      'projectId': serializer.toJson<int?>(projectId),
      'parentTaskId': serializer.toJson<int?>(parentTaskId),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'boardStatus': serializer.toJson<int>(boardStatus),
      'estimateMinutes': serializer.toJson<int?>(estimateMinutes),
      'loggedMinutes': serializer.toJson<int>(loggedMinutes),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    bool? hasDueTime,
    Value<DateTime?> reminderTime = const Value.absent(),
    int? priority,
    Value<int?> projectId = const Value.absent(),
    Value<int?> parentTaskId = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
    int? boardStatus,
    Value<int?> estimateMinutes = const Value.absent(),
    int? loggedMinutes,
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    hasDueTime: hasDueTime ?? this.hasDueTime,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    priority: priority ?? this.priority,
    projectId: projectId.present ? projectId.value : this.projectId,
    parentTaskId: parentTaskId.present ? parentTaskId.value : this.parentTaskId,
    recurrenceRule: recurrenceRule.present
        ? recurrenceRule.value
        : this.recurrenceRule,
    boardStatus: boardStatus ?? this.boardStatus,
    estimateMinutes: estimateMinutes.present
        ? estimateMinutes.value
        : this.estimateMinutes,
    loggedMinutes: loggedMinutes ?? this.loggedMinutes,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      hasDueTime: data.hasDueTime.present
          ? data.hasDueTime.value
          : this.hasDueTime,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      priority: data.priority.present ? data.priority.value : this.priority,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      parentTaskId: data.parentTaskId.present
          ? data.parentTaskId.value
          : this.parentTaskId,
      recurrenceRule: data.recurrenceRule.present
          ? data.recurrenceRule.value
          : this.recurrenceRule,
      boardStatus: data.boardStatus.present
          ? data.boardStatus.value
          : this.boardStatus,
      estimateMinutes: data.estimateMinutes.present
          ? data.estimateMinutes.value
          : this.estimateMinutes,
      loggedMinutes: data.loggedMinutes.present
          ? data.loggedMinutes.value
          : this.loggedMinutes,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('hasDueTime: $hasDueTime, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('priority: $priority, ')
          ..write('projectId: $projectId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('boardStatus: $boardStatus, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('loggedMinutes: $loggedMinutes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    dueDate,
    hasDueTime,
    reminderTime,
    priority,
    projectId,
    parentTaskId,
    recurrenceRule,
    boardStatus,
    estimateMinutes,
    loggedMinutes,
    isCompleted,
    completedAt,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.hasDueTime == this.hasDueTime &&
          other.reminderTime == this.reminderTime &&
          other.priority == this.priority &&
          other.projectId == this.projectId &&
          other.parentTaskId == this.parentTaskId &&
          other.recurrenceRule == this.recurrenceRule &&
          other.boardStatus == this.boardStatus &&
          other.estimateMinutes == this.estimateMinutes &&
          other.loggedMinutes == this.loggedMinutes &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> dueDate;
  final Value<bool> hasDueTime;
  final Value<DateTime?> reminderTime;
  final Value<int> priority;
  final Value<int?> projectId;
  final Value<int?> parentTaskId;
  final Value<String?> recurrenceRule;
  final Value<int> boardStatus;
  final Value<int?> estimateMinutes;
  final Value<int> loggedMinutes;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.hasDueTime = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.priority = const Value.absent(),
    this.projectId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.boardStatus = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.loggedMinutes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.hasDueTime = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.priority = const Value.absent(),
    this.projectId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.boardStatus = const Value.absent(),
    this.estimateMinutes = const Value.absent(),
    this.loggedMinutes = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<bool>? hasDueTime,
    Expression<DateTime>? reminderTime,
    Expression<int>? priority,
    Expression<int>? projectId,
    Expression<int>? parentTaskId,
    Expression<String>? recurrenceRule,
    Expression<int>? boardStatus,
    Expression<int>? estimateMinutes,
    Expression<int>? loggedMinutes,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (hasDueTime != null) 'has_due_time': hasDueTime,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (priority != null) 'priority': priority,
      if (projectId != null) 'project_id': projectId,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (boardStatus != null) 'board_status': boardStatus,
      if (estimateMinutes != null) 'estimate_minutes': estimateMinutes,
      if (loggedMinutes != null) 'logged_minutes': loggedMinutes,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? dueDate,
    Value<bool>? hasDueTime,
    Value<DateTime?>? reminderTime,
    Value<int>? priority,
    Value<int?>? projectId,
    Value<int?>? parentTaskId,
    Value<String?>? recurrenceRule,
    Value<int>? boardStatus,
    Value<int?>? estimateMinutes,
    Value<int>? loggedMinutes,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      hasDueTime: hasDueTime ?? this.hasDueTime,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      boardStatus: boardStatus ?? this.boardStatus,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      loggedMinutes: loggedMinutes ?? this.loggedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (hasDueTime.present) {
      map['has_due_time'] = Variable<bool>(hasDueTime.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<DateTime>(reminderTime.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<int>(parentTaskId.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (boardStatus.present) {
      map['board_status'] = Variable<int>(boardStatus.value);
    }
    if (estimateMinutes.present) {
      map['estimate_minutes'] = Variable<int>(estimateMinutes.value);
    }
    if (loggedMinutes.present) {
      map['logged_minutes'] = Variable<int>(loggedMinutes.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('hasDueTime: $hasDueTime, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('priority: $priority, ')
          ..write('projectId: $projectId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('boardStatus: $boardStatus, ')
          ..write('estimateMinutes: $estimateMinutes, ')
          ..write('loggedMinutes: $loggedMinutes, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TaskTagsTable extends TaskTags with TableInfo<$TaskTagsTable, TaskTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, tagId};
  @override
  TaskTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTag(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $TaskTagsTable createAlias(String alias) {
    return $TaskTagsTable(attachedDatabase, alias);
  }
}

class TaskTag extends DataClass implements Insertable<TaskTag> {
  final int taskId;
  final int tagId;
  const TaskTag({required this.taskId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<int>(taskId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  TaskTagsCompanion toCompanion(bool nullToAbsent) {
    return TaskTagsCompanion(taskId: Value(taskId), tagId: Value(tagId));
  }

  factory TaskTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTag(
      taskId: serializer.fromJson<int>(json['taskId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<int>(taskId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  TaskTag copyWith({int? taskId, int? tagId}) =>
      TaskTag(taskId: taskId ?? this.taskId, tagId: tagId ?? this.tagId);
  TaskTag copyWithCompanion(TaskTagsCompanion data) {
    return TaskTag(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTag(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTag &&
          other.taskId == this.taskId &&
          other.tagId == this.tagId);
}

class TaskTagsCompanion extends UpdateCompanion<TaskTag> {
  final Value<int> taskId;
  final Value<int> tagId;
  final Value<int> rowid;
  const TaskTagsCompanion({
    this.taskId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTagsCompanion.insert({
    required int taskId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       tagId = Value(tagId);
  static Insertable<TaskTag> custom({
    Expression<int>? taskId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTagsCompanion copyWith({
    Value<int>? taskId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return TaskTagsCompanion(
      taskId: taskId ?? this.taskId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('coffee'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF3BB273),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<int> goalType = GeneratedColumn<int>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _frequencyTypeMeta = const VerificationMeta(
    'frequencyType',
  );
  @override
  late final GeneratedColumn<int> frequencyType = GeneratedColumn<int>(
    'frequency_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _timesPerWeekMeta = const VerificationMeta(
    'timesPerWeek',
  );
  @override
  late final GeneratedColumn<int> timesPerWeek = GeneratedColumn<int>(
    'times_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _costPerUnitMeta = const VerificationMeta(
    'costPerUnit',
  );
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
    'cost_per_unit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caffeineMgPerUnitMeta = const VerificationMeta(
    'caffeineMgPerUnit',
  );
  @override
  late final GeneratedColumn<double> caffeineMgPerUnit =
      GeneratedColumn<double>(
        'caffeine_mg_per_unit',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderMinutesMeta = const VerificationMeta(
    'reminderMinutes',
  );
  @override
  late final GeneratedColumn<int> reminderMinutes = GeneratedColumn<int>(
    'reminder_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    unit,
    goalType,
    targetAmount,
    frequencyType,
    weekdayMask,
    timesPerWeek,
    costPerUnit,
    caffeineMgPerUnit,
    reminderMinutes,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
        _frequencyTypeMeta,
        frequencyType.isAcceptableOrUnknown(
          data['frequency_type']!,
          _frequencyTypeMeta,
        ),
      );
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('times_per_week')) {
      context.handle(
        _timesPerWeekMeta,
        timesPerWeek.isAcceptableOrUnknown(
          data['times_per_week']!,
          _timesPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
        _costPerUnitMeta,
        costPerUnit.isAcceptableOrUnknown(
          data['cost_per_unit']!,
          _costPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('caffeine_mg_per_unit')) {
      context.handle(
        _caffeineMgPerUnitMeta,
        caffeineMgPerUnit.isAcceptableOrUnknown(
          data['caffeine_mg_per_unit']!,
          _caffeineMgPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minutes')) {
      context.handle(
        _reminderMinutesMeta,
        reminderMinutes.isAcceptableOrUnknown(
          data['reminder_minutes']!,
          _reminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_type'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      frequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_type'],
      )!,
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      )!,
      timesPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_week'],
      )!,
      costPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_per_unit'],
      ),
      caffeineMgPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}caffeine_mg_per_unit'],
      ),
      reminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minutes'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final String icon;
  final int color;
  final String? unit;

  /// 0 = build (do more), 1 = reduce (do less / stay under target)
  final int goalType;
  final double targetAmount;

  /// 0 = daily, 1 = specific weekdays, 2 = X times per week
  final int frequencyType;

  /// Bitmask, bit 0 = Monday … bit 6 = Sunday. Used when frequencyType == 1.
  final int weekdayMask;

  /// Used when frequencyType == 2.
  final int timesPerWeek;

  /// Optional per-unit cost, flows into the Expense module.
  final double? costPerUnit;

  /// Optional per-unit caffeine in mg, used for the daily estimate.
  final double? caffeineMgPerUnit;

  /// Minutes from midnight for the daily nudge; null disables it.
  final int? reminderMinutes;
  final bool isArchived;
  final DateTime createdAt;
  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.unit,
    required this.goalType,
    required this.targetAmount,
    required this.frequencyType,
    required this.weekdayMask,
    required this.timesPerWeek,
    this.costPerUnit,
    this.caffeineMgPerUnit,
    this.reminderMinutes,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['goal_type'] = Variable<int>(goalType);
    map['target_amount'] = Variable<double>(targetAmount);
    map['frequency_type'] = Variable<int>(frequencyType);
    map['weekday_mask'] = Variable<int>(weekdayMask);
    map['times_per_week'] = Variable<int>(timesPerWeek);
    if (!nullToAbsent || costPerUnit != null) {
      map['cost_per_unit'] = Variable<double>(costPerUnit);
    }
    if (!nullToAbsent || caffeineMgPerUnit != null) {
      map['caffeine_mg_per_unit'] = Variable<double>(caffeineMgPerUnit);
    }
    if (!nullToAbsent || reminderMinutes != null) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      goalType: Value(goalType),
      targetAmount: Value(targetAmount),
      frequencyType: Value(frequencyType),
      weekdayMask: Value(weekdayMask),
      timesPerWeek: Value(timesPerWeek),
      costPerUnit: costPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(costPerUnit),
      caffeineMgPerUnit: caffeineMgPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(caffeineMgPerUnit),
      reminderMinutes: reminderMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutes),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      unit: serializer.fromJson<String?>(json['unit']),
      goalType: serializer.fromJson<int>(json['goalType']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      frequencyType: serializer.fromJson<int>(json['frequencyType']),
      weekdayMask: serializer.fromJson<int>(json['weekdayMask']),
      timesPerWeek: serializer.fromJson<int>(json['timesPerWeek']),
      costPerUnit: serializer.fromJson<double?>(json['costPerUnit']),
      caffeineMgPerUnit: serializer.fromJson<double?>(
        json['caffeineMgPerUnit'],
      ),
      reminderMinutes: serializer.fromJson<int?>(json['reminderMinutes']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'unit': serializer.toJson<String?>(unit),
      'goalType': serializer.toJson<int>(goalType),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'frequencyType': serializer.toJson<int>(frequencyType),
      'weekdayMask': serializer.toJson<int>(weekdayMask),
      'timesPerWeek': serializer.toJson<int>(timesPerWeek),
      'costPerUnit': serializer.toJson<double?>(costPerUnit),
      'caffeineMgPerUnit': serializer.toJson<double?>(caffeineMgPerUnit),
      'reminderMinutes': serializer.toJson<int?>(reminderMinutes),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    Value<String?> unit = const Value.absent(),
    int? goalType,
    double? targetAmount,
    int? frequencyType,
    int? weekdayMask,
    int? timesPerWeek,
    Value<double?> costPerUnit = const Value.absent(),
    Value<double?> caffeineMgPerUnit = const Value.absent(),
    Value<int?> reminderMinutes = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    unit: unit.present ? unit.value : this.unit,
    goalType: goalType ?? this.goalType,
    targetAmount: targetAmount ?? this.targetAmount,
    frequencyType: frequencyType ?? this.frequencyType,
    weekdayMask: weekdayMask ?? this.weekdayMask,
    timesPerWeek: timesPerWeek ?? this.timesPerWeek,
    costPerUnit: costPerUnit.present ? costPerUnit.value : this.costPerUnit,
    caffeineMgPerUnit: caffeineMgPerUnit.present
        ? caffeineMgPerUnit.value
        : this.caffeineMgPerUnit,
    reminderMinutes: reminderMinutes.present
        ? reminderMinutes.value
        : this.reminderMinutes,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      unit: data.unit.present ? data.unit.value : this.unit,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      timesPerWeek: data.timesPerWeek.present
          ? data.timesPerWeek.value
          : this.timesPerWeek,
      costPerUnit: data.costPerUnit.present
          ? data.costPerUnit.value
          : this.costPerUnit,
      caffeineMgPerUnit: data.caffeineMgPerUnit.present
          ? data.caffeineMgPerUnit.value
          : this.caffeineMgPerUnit,
      reminderMinutes: data.reminderMinutes.present
          ? data.reminderMinutes.value
          : this.reminderMinutes,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('unit: $unit, ')
          ..write('goalType: $goalType, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('caffeineMgPerUnit: $caffeineMgPerUnit, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    icon,
    color,
    unit,
    goalType,
    targetAmount,
    frequencyType,
    weekdayMask,
    timesPerWeek,
    costPerUnit,
    caffeineMgPerUnit,
    reminderMinutes,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.unit == this.unit &&
          other.goalType == this.goalType &&
          other.targetAmount == this.targetAmount &&
          other.frequencyType == this.frequencyType &&
          other.weekdayMask == this.weekdayMask &&
          other.timesPerWeek == this.timesPerWeek &&
          other.costPerUnit == this.costPerUnit &&
          other.caffeineMgPerUnit == this.caffeineMgPerUnit &&
          other.reminderMinutes == this.reminderMinutes &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<String?> unit;
  final Value<int> goalType;
  final Value<double> targetAmount;
  final Value<int> frequencyType;
  final Value<int> weekdayMask;
  final Value<int> timesPerWeek;
  final Value<double?> costPerUnit;
  final Value<double?> caffeineMgPerUnit;
  final Value<int?> reminderMinutes;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.unit = const Value.absent(),
    this.goalType = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.caffeineMgPerUnit = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.unit = const Value.absent(),
    this.goalType = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.caffeineMgPerUnit = const Value.absent(),
    this.reminderMinutes = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<String>? unit,
    Expression<int>? goalType,
    Expression<double>? targetAmount,
    Expression<int>? frequencyType,
    Expression<int>? weekdayMask,
    Expression<int>? timesPerWeek,
    Expression<double>? costPerUnit,
    Expression<double>? caffeineMgPerUnit,
    Expression<int>? reminderMinutes,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (unit != null) 'unit': unit,
      if (goalType != null) 'goal_type': goalType,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (timesPerWeek != null) 'times_per_week': timesPerWeek,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (caffeineMgPerUnit != null) 'caffeine_mg_per_unit': caffeineMgPerUnit,
      if (reminderMinutes != null) 'reminder_minutes': reminderMinutes,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<String?>? unit,
    Value<int>? goalType,
    Value<double>? targetAmount,
    Value<int>? frequencyType,
    Value<int>? weekdayMask,
    Value<int>? timesPerWeek,
    Value<double?>? costPerUnit,
    Value<double?>? caffeineMgPerUnit,
    Value<int?>? reminderMinutes,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      unit: unit ?? this.unit,
      goalType: goalType ?? this.goalType,
      targetAmount: targetAmount ?? this.targetAmount,
      frequencyType: frequencyType ?? this.frequencyType,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      caffeineMgPerUnit: caffeineMgPerUnit ?? this.caffeineMgPerUnit,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<int>(goalType.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<int>(frequencyType.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (timesPerWeek.present) {
      map['times_per_week'] = Variable<int>(timesPerWeek.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (caffeineMgPerUnit.present) {
      map['caffeine_mg_per_unit'] = Variable<double>(caffeineMgPerUnit.value);
    }
    if (reminderMinutes.present) {
      map['reminder_minutes'] = Variable<int>(reminderMinutes.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('unit: $unit, ')
          ..write('goalType: $goalType, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('caffeineMgPerUnit: $caffeineMgPerUnit, ')
          ..write('reminderMinutes: $reminderMinutes, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, date, amount, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, date},
  ];
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final int id;
  final int habitId;

  /// Date-only (midnight local) so a day has at most one row per habit.
  final DateTime date;
  final double amount;
  final String? note;
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.amount,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String?>(note),
    };
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    double? amount,
    Value<String?> note = const Value.absent(),
  }) => HabitLog(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
  );
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, date, amount, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.note == this.note);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<String?> note;
  const HabitLogsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime date,
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
  }) : habitId = Value(habitId),
       date = Value(date);
  static Insertable<HabitLog> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
    });
  }

  HabitLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? date,
    Value<double>? amount,
    Value<String?>? note,
  }) {
    return HabitLogsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Self'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFFFF6547),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('household'),
  );
  static const VerificationMeta _isSelfMeta = const VerificationMeta('isSelf');
  @override
  late final GeneratedColumn<bool> isSelf = GeneratedColumn<bool>(
    'is_self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_self" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    relation,
    color,
    type,
    isSelf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<Person> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('is_self')) {
      context.handle(
        _isSelfMeta,
        isSelf.isAcceptableOrUnknown(data['is_self']!, _isSelfMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Person(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_self'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class Person extends DataClass implements Insertable<Person> {
  final int id;
  final String name;
  final String relation;
  final int color;

  /// household | contact
  final String type;

  /// The seeded row for the user, which every module falls back to and no
  /// screen may delete.
  final bool isSelf;
  const Person({
    required this.id,
    required this.name,
    required this.relation,
    required this.color,
    required this.type,
    required this.isSelf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['relation'] = Variable<String>(relation);
    map['color'] = Variable<int>(color);
    map['type'] = Variable<String>(type);
    map['is_self'] = Variable<bool>(isSelf);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      name: Value(name),
      relation: Value(relation),
      color: Value(color),
      type: Value(type),
      isSelf: Value(isSelf),
    );
  }

  factory Person.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      relation: serializer.fromJson<String>(json['relation']),
      color: serializer.fromJson<int>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      isSelf: serializer.fromJson<bool>(json['isSelf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'relation': serializer.toJson<String>(relation),
      'color': serializer.toJson<int>(color),
      'type': serializer.toJson<String>(type),
      'isSelf': serializer.toJson<bool>(isSelf),
    };
  }

  Person copyWith({
    int? id,
    String? name,
    String? relation,
    int? color,
    String? type,
    bool? isSelf,
  }) => Person(
    id: id ?? this.id,
    name: name ?? this.name,
    relation: relation ?? this.relation,
    color: color ?? this.color,
    type: type ?? this.type,
    isSelf: isSelf ?? this.isSelf,
  );
  Person copyWithCompanion(PeopleCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      relation: data.relation.present ? data.relation.value : this.relation,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      isSelf: data.isSelf.present ? data.isSelf.value : this.isSelf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relation: $relation, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isSelf: $isSelf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, relation, color, type, isSelf);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.name == this.name &&
          other.relation == this.relation &&
          other.color == this.color &&
          other.type == this.type &&
          other.isSelf == this.isSelf);
}

class PeopleCompanion extends UpdateCompanion<Person> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> relation;
  final Value<int> color;
  final Value<String> type;
  final Value<bool> isSelf;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.relation = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isSelf = const Value.absent(),
  });
  PeopleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.relation = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isSelf = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Person> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? relation,
    Expression<int>? color,
    Expression<String>? type,
    Expression<bool>? isSelf,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (relation != null) 'relation': relation,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (isSelf != null) 'is_self': isSelf,
    });
  }

  PeopleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? relation,
    Value<int>? color,
    Value<String>? type,
    Value<bool>? isSelf,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      color: color ?? this.color,
      type: type ?? this.type,
      isSelf: isSelf ?? this.isSelf,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isSelf.present) {
      map['is_self'] = Variable<bool>(isSelf.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('relation: $relation, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isSelf: $isSelf')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BDT'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF9A6DD7),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    balance,
    currency,
    color,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;

  /// cash | bank | card | bkash | nagad | rocket | other
  final String type;
  final double balance;
  final String currency;
  final int color;
  final bool isArchived;
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.color,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['balance'] = Variable<double>(balance);
    map['currency'] = Variable<String>(currency);
    map['color'] = Variable<int>(color);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      balance: Value(balance),
      currency: Value(currency),
      color: Value(color),
      isArchived: Value(isArchived),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      balance: serializer.fromJson<double>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      color: serializer.fromJson<int>(json['color']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'balance': serializer.toJson<double>(balance),
      'currency': serializer.toJson<String>(currency),
      'color': serializer.toJson<int>(color),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    String? currency,
    int? color,
    bool? isArchived,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    currency: currency ?? this.currency,
    color: color ?? this.color,
    isArchived: isArchived ?? this.isArchived,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      balance: data.balance.present ? data.balance.value : this.balance,
      currency: data.currency.present ? data.currency.value : this.currency,
      color: data.color.present ? data.color.value : this.color,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, balance, currency, color, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.color == this.color &&
          other.isArchived == this.isArchived);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> balance;
  final Value<String> currency;
  final Value<int> color;
  final Value<bool> isArchived;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? balance,
    Expression<String>? currency,
    Expression<int>? color,
    Expression<bool>? isArchived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (color != null) 'color': color,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? balance,
    Value<String>? currency,
    Value<int>? color,
    Value<bool>? isArchived,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('shopping_bag'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0xFF9A6DD7),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    color,
    parentId,
    isIncome,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final int id;
  final String name;
  final String icon;
  final int color;
  final int? parentId;
  final bool isIncome;
  final int sortOrder;
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.parentId,
    required this.isIncome,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['is_income'] = Variable<bool>(isIncome);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      color: Value(color),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isIncome: Value(isIncome),
      sortOrder: Value(sortOrder),
    );
  }

  factory ExpenseCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int>(color),
      'parentId': serializer.toJson<int?>(parentId),
      'isIncome': serializer.toJson<bool>(isIncome),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ExpenseCategory copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    Value<int?> parentId = const Value.absent(),
    bool? isIncome,
    int? sortOrder,
  }) => ExpenseCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    parentId: parentId.present ? parentId.value : this.parentId,
    isIncome: isIncome ?? this.isIncome,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('isIncome: $isIncome, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, color, parentId, isIncome, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.parentId == this.parentId &&
          other.isIncome == this.isIncome &&
          other.sortOrder == this.sortOrder);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> color;
  final Value<int?> parentId;
  final Value<bool> isIncome;
  final Value<int> sortOrder;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ExpenseCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<int>? parentId,
    Expression<bool>? isIncome,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentId != null) 'parent_id': parentId,
      if (isIncome != null) 'is_income': isIncome,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? color,
    Value<int?>? parentId,
    Value<bool>? isIncome,
    Value<int>? sortOrder,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isIncome: isIncome ?? this.isIncome,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentId: $parentId, ')
          ..write('isIncome: $isIncome, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _principalMeta = const VerificationMeta(
    'principal',
  );
  @override
  late final GeneratedColumn<double> principal = GeneratedColumn<double>(
    'principal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    personId,
    direction,
    principal,
    note,
    dueDate,
    createdAt,
    settledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Loan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('principal')) {
      context.handle(
        _principalMeta,
        principal.isAcceptableOrUnknown(data['principal']!, _principalMeta),
      );
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direction'],
      )!,
      principal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}principal'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final int id;
  final int personId;

  /// 0 = lent (they owe me), 1 = borrowed (I owe them)
  final int direction;
  final double principal;
  final String? note;
  final DateTime? dueDate;
  final DateTime createdAt;

  /// Set the moment repayments cover the principal; cleared if one is undone.
  final DateTime? settledAt;
  const Loan({
    required this.id,
    required this.personId,
    required this.direction,
    required this.principal,
    this.note,
    this.dueDate,
    required this.createdAt,
    this.settledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['person_id'] = Variable<int>(personId);
    map['direction'] = Variable<int>(direction);
    map['principal'] = Variable<double>(principal);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      personId: Value(personId),
      direction: Value(direction),
      principal: Value(principal),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
    );
  }

  factory Loan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<int>(json['id']),
      personId: serializer.fromJson<int>(json['personId']),
      direction: serializer.fromJson<int>(json['direction']),
      principal: serializer.fromJson<double>(json['principal']),
      note: serializer.fromJson<String?>(json['note']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'personId': serializer.toJson<int>(personId),
      'direction': serializer.toJson<int>(direction),
      'principal': serializer.toJson<double>(principal),
      'note': serializer.toJson<String?>(note),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
    };
  }

  Loan copyWith({
    int? id,
    int? personId,
    int? direction,
    double? principal,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> settledAt = const Value.absent(),
  }) => Loan(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    direction: direction ?? this.direction,
    principal: principal ?? this.principal,
    note: note.present ? note.value : this.note,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    createdAt: createdAt ?? this.createdAt,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
  );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      personId: data.personId.present ? data.personId.value : this.personId,
      direction: data.direction.present ? data.direction.value : this.direction,
      principal: data.principal.present ? data.principal.value : this.principal,
      note: data.note.present ? data.note.value : this.note,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('direction: $direction, ')
          ..write('principal: $principal, ')
          ..write('note: $note, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    direction,
    principal,
    note,
    dueDate,
    createdAt,
    settledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.personId == this.personId &&
          other.direction == this.direction &&
          other.principal == this.principal &&
          other.note == this.note &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.settledAt == this.settledAt);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<int> id;
  final Value<int> personId;
  final Value<int> direction;
  final Value<double> principal;
  final Value<String?> note;
  final Value<DateTime?> dueDate;
  final Value<DateTime> createdAt;
  final Value<DateTime?> settledAt;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.personId = const Value.absent(),
    this.direction = const Value.absent(),
    this.principal = const Value.absent(),
    this.note = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settledAt = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required int personId,
    this.direction = const Value.absent(),
    required double principal,
    this.note = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settledAt = const Value.absent(),
  }) : personId = Value(personId),
       principal = Value(principal);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<int>? personId,
    Expression<int>? direction,
    Expression<double>? principal,
    Expression<String>? note,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? settledAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (personId != null) 'person_id': personId,
      if (direction != null) 'direction': direction,
      if (principal != null) 'principal': principal,
      if (note != null) 'note': note,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (settledAt != null) 'settled_at': settledAt,
    });
  }

  LoansCompanion copyWith({
    Value<int>? id,
    Value<int>? personId,
    Value<int>? direction,
    Value<double>? principal,
    Value<String?>? note,
    Value<DateTime?>? dueDate,
    Value<DateTime>? createdAt,
    Value<DateTime?>? settledAt,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      direction: direction ?? this.direction,
      principal: principal ?? this.principal,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (principal.present) {
      map['principal'] = Variable<double>(principal.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('personId: $personId, ')
          ..write('direction: $direction, ')
          ..write('principal: $principal, ')
          ..write('note: $note, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expense_categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _transferAccountIdMeta = const VerificationMeta(
    'transferAccountId',
  );
  @override
  late final GeneratedColumn<int> transferAccountId = GeneratedColumn<int>(
    'transfer_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<int> personId = GeneratedColumn<int>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id)',
    ),
  );
  static const VerificationMeta _loanIdMeta = const VerificationMeta('loanId');
  @override
  late final GeneratedColumn<int> loanId = GeneratedColumn<int>(
    'loan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES loans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    categoryId,
    accountId,
    transferAccountId,
    kind,
    personId,
    loanId,
    note,
    receiptPath,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('transfer_account_id')) {
      context.handle(
        _transferAccountIdMeta,
        transferAccountId.isAcceptableOrUnknown(
          data['transfer_account_id']!,
          _transferAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('loan_id')) {
      context.handle(
        _loanIdMeta,
        loanId.isAcceptableOrUnknown(data['loan_id']!, _loanIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      transferAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_account_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}person_id'],
      )!,
      loanId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}loan_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final double amount;
  final int? categoryId;
  final int accountId;

  /// Destination account for transfers; null for ordinary income/expense.
  final int? transferAccountId;

  /// 0 = expense, 1 = income, 2 = transfer, 3 = lend, 4 = borrow,
  /// 5 = loan repayment. Only 0 and 1 count as spending or earning.
  final int kind;

  /// Who the money was for. Never null: the repository falls back to Self.
  final int personId;

  /// Set on the principal and every repayment of a loan.
  final int? loanId;
  final String? note;
  final String? receiptPath;
  final DateTime date;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.amount,
    this.categoryId,
    required this.accountId,
    this.transferAccountId,
    required this.kind,
    required this.personId,
    this.loanId,
    this.note,
    this.receiptPath,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || transferAccountId != null) {
      map['transfer_account_id'] = Variable<int>(transferAccountId);
    }
    map['kind'] = Variable<int>(kind);
    map['person_id'] = Variable<int>(personId);
    if (!nullToAbsent || loanId != null) {
      map['loan_id'] = Variable<int>(loanId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: Value(accountId),
      transferAccountId: transferAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferAccountId),
      kind: Value(kind),
      personId: Value(personId),
      loanId: loanId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      transferAccountId: serializer.fromJson<int?>(json['transferAccountId']),
      kind: serializer.fromJson<int>(json['kind']),
      personId: serializer.fromJson<int>(json['personId']),
      loanId: serializer.fromJson<int?>(json['loanId']),
      note: serializer.fromJson<String?>(json['note']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<int?>(categoryId),
      'accountId': serializer.toJson<int>(accountId),
      'transferAccountId': serializer.toJson<int?>(transferAccountId),
      'kind': serializer.toJson<int>(kind),
      'personId': serializer.toJson<int>(personId),
      'loanId': serializer.toJson<int?>(loanId),
      'note': serializer.toJson<String?>(note),
      'receiptPath': serializer.toJson<String?>(receiptPath),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    int? id,
    double? amount,
    Value<int?> categoryId = const Value.absent(),
    int? accountId,
    Value<int?> transferAccountId = const Value.absent(),
    int? kind,
    int? personId,
    Value<int?> loanId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId ?? this.accountId,
    transferAccountId: transferAccountId.present
        ? transferAccountId.value
        : this.transferAccountId,
    kind: kind ?? this.kind,
    personId: personId ?? this.personId,
    loanId: loanId.present ? loanId.value : this.loanId,
    note: note.present ? note.value : this.note,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      transferAccountId: data.transferAccountId.present
          ? data.transferAccountId.value
          : this.transferAccountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      personId: data.personId.present ? data.personId.value : this.personId,
      loanId: data.loanId.present ? data.loanId.value : this.loanId,
      note: data.note.present ? data.note.value : this.note,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('transferAccountId: $transferAccountId, ')
          ..write('kind: $kind, ')
          ..write('personId: $personId, ')
          ..write('loanId: $loanId, ')
          ..write('note: $note, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    categoryId,
    accountId,
    transferAccountId,
    kind,
    personId,
    loanId,
    note,
    receiptPath,
    date,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.transferAccountId == this.transferAccountId &&
          other.kind == this.kind &&
          other.personId == this.personId &&
          other.loanId == this.loanId &&
          other.note == this.note &&
          other.receiptPath == this.receiptPath &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<double> amount;
  final Value<int?> categoryId;
  final Value<int> accountId;
  final Value<int?> transferAccountId;
  final Value<int> kind;
  final Value<int> personId;
  final Value<int?> loanId;
  final Value<String?> note;
  final Value<String?> receiptPath;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.transferAccountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.personId = const Value.absent(),
    this.loanId = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    this.categoryId = const Value.absent(),
    required int accountId,
    this.transferAccountId = const Value.absent(),
    this.kind = const Value.absent(),
    required int personId,
    this.loanId = const Value.absent(),
    this.note = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : amount = Value(amount),
       accountId = Value(accountId),
       personId = Value(personId);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<int>? categoryId,
    Expression<int>? accountId,
    Expression<int>? transferAccountId,
    Expression<int>? kind,
    Expression<int>? personId,
    Expression<int>? loanId,
    Expression<String>? note,
    Expression<String>? receiptPath,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (transferAccountId != null) 'transfer_account_id': transferAccountId,
      if (kind != null) 'kind': kind,
      if (personId != null) 'person_id': personId,
      if (loanId != null) 'loan_id': loanId,
      if (note != null) 'note': note,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<int?>? categoryId,
    Value<int>? accountId,
    Value<int?>? transferAccountId,
    Value<int>? kind,
    Value<int>? personId,
    Value<int?>? loanId,
    Value<String?>? note,
    Value<String?>? receiptPath,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      transferAccountId: transferAccountId ?? this.transferAccountId,
      kind: kind ?? this.kind,
      personId: personId ?? this.personId,
      loanId: loanId ?? this.loanId,
      note: note ?? this.note,
      receiptPath: receiptPath ?? this.receiptPath,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (transferAccountId.present) {
      map['transfer_account_id'] = Variable<int>(transferAccountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<int>(personId.value);
    }
    if (loanId.present) {
      map['loan_id'] = Variable<int>(loanId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('transferAccountId: $transferAccountId, ')
          ..write('kind: $kind, ')
          ..write('personId: $personId, ')
          ..write('loanId: $loanId, ')
          ..write('note: $note, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES expense_categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _monthStartMeta = const VerificationMeta(
    'monthStart',
  );
  @override
  late final GeneratedColumn<DateTime> monthStart = GeneratedColumn<DateTime>(
    'month_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, categoryId, monthStart];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('month_start')) {
      context.handle(
        _monthStartMeta,
        monthStart.isAcceptableOrUnknown(data['month_start']!, _monthStartMeta),
      );
    } else if (isInserting) {
      context.missing(_monthStartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {categoryId, monthStart},
  ];
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      monthStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}month_start'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final double amount;

  /// null = overall budget across every category
  final int? categoryId;

  /// Midnight on the first day of the month the cap applies to.
  final DateTime monthStart;
  const Budget({
    required this.id,
    required this.amount,
    this.categoryId,
    required this.monthStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['month_start'] = Variable<DateTime>(monthStart);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      monthStart: Value(monthStart),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      monthStart: serializer.fromJson<DateTime>(json['monthStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<int?>(categoryId),
      'monthStart': serializer.toJson<DateTime>(monthStart),
    };
  }

  Budget copyWith({
    int? id,
    double? amount,
    Value<int?> categoryId = const Value.absent(),
    DateTime? monthStart,
  }) => Budget(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    monthStart: monthStart ?? this.monthStart,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      monthStart: data.monthStart.present
          ? data.monthStart.value
          : this.monthStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('monthStart: $monthStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, categoryId, monthStart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.monthStart == this.monthStart);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<double> amount;
  final Value<int?> categoryId;
  final Value<DateTime> monthStart;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.monthStart = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    this.categoryId = const Value.absent(),
    required DateTime monthStart,
  }) : amount = Value(amount),
       monthStart = Value(monthStart);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<int>? categoryId,
    Expression<DateTime>? monthStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (monthStart != null) 'month_start': monthStart,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<int?>? categoryId,
    Value<DateTime>? monthStart,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      monthStart: monthStart ?? this.monthStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (monthStart.present) {
      map['month_start'] = Variable<DateTime>(monthStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('monthStart: $monthStart')
          ..write(')'))
        .toString();
  }
}

class $RecurringExpensesTable extends RecurringExpenses
    with TableInfo<$RecurringExpensesTable, RecurringExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _dayOfPeriodMeta = const VerificationMeta(
    'dayOfPeriod',
  );
  @override
  late final GeneratedColumn<int> dayOfPeriod = GeneratedColumn<int>(
    'day_of_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSubscriptionMeta = const VerificationMeta(
    'isSubscription',
  );
  @override
  late final GeneratedColumn<bool> isSubscription = GeneratedColumn<bool>(
    'is_subscription',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_subscription" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amount,
    categoryId,
    accountId,
    period,
    dayOfPeriod,
    isSubscription,
    nextDueDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('day_of_period')) {
      context.handle(
        _dayOfPeriodMeta,
        dayOfPeriod.isAcceptableOrUnknown(
          data['day_of_period']!,
          _dayOfPeriodMeta,
        ),
      );
    }
    if (data.containsKey('is_subscription')) {
      context.handle(
        _isSubscriptionMeta,
        isSubscription.isAcceptableOrUnknown(
          data['is_subscription']!,
          _isSubscriptionMeta,
        ),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      dayOfPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_period'],
      )!,
      isSubscription: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_subscription'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RecurringExpensesTable createAlias(String alias) {
    return $RecurringExpensesTable(attachedDatabase, alias);
  }
}

class RecurringExpense extends DataClass
    implements Insertable<RecurringExpense> {
  final int id;
  final String name;
  final double amount;
  final int? categoryId;
  final int? accountId;

  /// daily | weekly | monthly | yearly
  final String period;

  /// Day of month (monthly) or weekday 1-7 (weekly).
  final int dayOfPeriod;
  final bool isSubscription;
  final DateTime nextDueDate;
  final bool isActive;
  const RecurringExpense({
    required this.id,
    required this.name,
    required this.amount,
    this.categoryId,
    this.accountId,
    required this.period,
    required this.dayOfPeriod,
    required this.isSubscription,
    required this.nextDueDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['period'] = Variable<String>(period);
    map['day_of_period'] = Variable<int>(dayOfPeriod);
    map['is_subscription'] = Variable<bool>(isSubscription);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RecurringExpensesCompanion toCompanion(bool nullToAbsent) {
    return RecurringExpensesCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      period: Value(period),
      dayOfPeriod: Value(dayOfPeriod),
      isSubscription: Value(isSubscription),
      nextDueDate: Value(nextDueDate),
      isActive: Value(isActive),
    );
  }

  factory RecurringExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringExpense(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      period: serializer.fromJson<String>(json['period']),
      dayOfPeriod: serializer.fromJson<int>(json['dayOfPeriod']),
      isSubscription: serializer.fromJson<bool>(json['isSubscription']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<int?>(categoryId),
      'accountId': serializer.toJson<int?>(accountId),
      'period': serializer.toJson<String>(period),
      'dayOfPeriod': serializer.toJson<int>(dayOfPeriod),
      'isSubscription': serializer.toJson<bool>(isSubscription),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RecurringExpense copyWith({
    int? id,
    String? name,
    double? amount,
    Value<int?> categoryId = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    String? period,
    int? dayOfPeriod,
    bool? isSubscription,
    DateTime? nextDueDate,
    bool? isActive,
  }) => RecurringExpense(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    period: period ?? this.period,
    dayOfPeriod: dayOfPeriod ?? this.dayOfPeriod,
    isSubscription: isSubscription ?? this.isSubscription,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    isActive: isActive ?? this.isActive,
  );
  RecurringExpense copyWithCompanion(RecurringExpensesCompanion data) {
    return RecurringExpense(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      period: data.period.present ? data.period.value : this.period,
      dayOfPeriod: data.dayOfPeriod.present
          ? data.dayOfPeriod.value
          : this.dayOfPeriod,
      isSubscription: data.isSubscription.present
          ? data.isSubscription.value
          : this.isSubscription,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpense(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('period: $period, ')
          ..write('dayOfPeriod: $dayOfPeriod, ')
          ..write('isSubscription: $isSubscription, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amount,
    categoryId,
    accountId,
    period,
    dayOfPeriod,
    isSubscription,
    nextDueDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringExpense &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.period == this.period &&
          other.dayOfPeriod == this.dayOfPeriod &&
          other.isSubscription == this.isSubscription &&
          other.nextDueDate == this.nextDueDate &&
          other.isActive == this.isActive);
}

class RecurringExpensesCompanion extends UpdateCompanion<RecurringExpense> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<int?> categoryId;
  final Value<int?> accountId;
  final Value<String> period;
  final Value<int> dayOfPeriod;
  final Value<bool> isSubscription;
  final Value<DateTime> nextDueDate;
  final Value<bool> isActive;
  const RecurringExpensesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.period = const Value.absent(),
    this.dayOfPeriod = const Value.absent(),
    this.isSubscription = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  RecurringExpensesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double amount,
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.period = const Value.absent(),
    this.dayOfPeriod = const Value.absent(),
    this.isSubscription = const Value.absent(),
    required DateTime nextDueDate,
    this.isActive = const Value.absent(),
  }) : name = Value(name),
       amount = Value(amount),
       nextDueDate = Value(nextDueDate);
  static Insertable<RecurringExpense> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<int>? categoryId,
    Expression<int>? accountId,
    Expression<String>? period,
    Expression<int>? dayOfPeriod,
    Expression<bool>? isSubscription,
    Expression<DateTime>? nextDueDate,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (period != null) 'period': period,
      if (dayOfPeriod != null) 'day_of_period': dayOfPeriod,
      if (isSubscription != null) 'is_subscription': isSubscription,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (isActive != null) 'is_active': isActive,
    });
  }

  RecurringExpensesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? amount,
    Value<int?>? categoryId,
    Value<int?>? accountId,
    Value<String>? period,
    Value<int>? dayOfPeriod,
    Value<bool>? isSubscription,
    Value<DateTime>? nextDueDate,
    Value<bool>? isActive,
  }) {
    return RecurringExpensesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      period: period ?? this.period,
      dayOfPeriod: dayOfPeriod ?? this.dayOfPeriod,
      isSubscription: isSubscription ?? this.isSubscription,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (dayOfPeriod.present) {
      map['day_of_period'] = Variable<int>(dayOfPeriod.value);
    }
    if (isSubscription.present) {
      map['is_subscription'] = Variable<bool>(isSubscription.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpensesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('period: $period, ')
          ..write('dayOfPeriod: $dayOfPeriod, ')
          ..write('isSubscription: $isSubscription, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES people (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tablet'),
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<double> dosage = GeneratedColumn<double>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _dosageUnitMeta = const VerificationMeta(
    'dosageUnit',
  );
  @override
  late final GeneratedColumn<String> dosageUnit = GeneratedColumn<String>(
    'dosage_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tablet'),
  );
  static const VerificationMeta _inventoryMeta = const VerificationMeta(
    'inventory',
  );
  @override
  late final GeneratedColumn<int> inventory = GeneratedColumn<int>(
    'inventory',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
    'low_stock_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _doctorNameMeta = const VerificationMeta(
    'doctorName',
  );
  @override
  late final GeneratedColumn<String> doctorName = GeneratedColumn<String>(
    'doctor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prescriptionPathMeta = const VerificationMeta(
    'prescriptionPath',
  );
  @override
  late final GeneratedColumn<String> prescriptionPath = GeneratedColumn<String>(
    'prescription_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyTypeMeta = const VerificationMeta(
    'frequencyType',
  );
  @override
  late final GeneratedColumn<int> frequencyType = GeneratedColumn<int>(
    'frequency_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _doseTimesMeta = const VerificationMeta(
    'doseTimes',
  );
  @override
  late final GeneratedColumn<String> doseTimes = GeneratedColumn<String>(
    'dose_times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('480'),
  );
  static const VerificationMeta _intervalHoursMeta = const VerificationMeta(
    'intervalHours',
  );
  @override
  late final GeneratedColumn<int> intervalHours = GeneratedColumn<int>(
    'interval_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _weekdayMaskMeta = const VerificationMeta(
    'weekdayMask',
  );
  @override
  late final GeneratedColumn<int> weekdayMask = GeneratedColumn<int>(
    'weekday_mask',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(127),
  );
  static const VerificationMeta _mealRelationMeta = const VerificationMeta(
    'mealRelation',
  );
  @override
  late final GeneratedColumn<String> mealRelation = GeneratedColumn<String>(
    'meal_relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skipDatesMeta = const VerificationMeta(
    'skipDates',
  );
  @override
  late final GeneratedColumn<String> skipDates = GeneratedColumn<String>(
    'skip_dates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    name,
    form,
    dosage,
    dosageUnit,
    inventory,
    lowStockThreshold,
    doctorName,
    prescriptionPath,
    notes,
    frequencyType,
    doseTimes,
    intervalHours,
    weekdayMask,
    mealRelation,
    startDate,
    endDate,
    skipDates,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medicine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    }
    if (data.containsKey('dosage_unit')) {
      context.handle(
        _dosageUnitMeta,
        dosageUnit.isAcceptableOrUnknown(data['dosage_unit']!, _dosageUnitMeta),
      );
    }
    if (data.containsKey('inventory')) {
      context.handle(
        _inventoryMeta,
        inventory.isAcceptableOrUnknown(data['inventory']!, _inventoryMeta),
      );
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    }
    if (data.containsKey('doctor_name')) {
      context.handle(
        _doctorNameMeta,
        doctorName.isAcceptableOrUnknown(data['doctor_name']!, _doctorNameMeta),
      );
    }
    if (data.containsKey('prescription_path')) {
      context.handle(
        _prescriptionPathMeta,
        prescriptionPath.isAcceptableOrUnknown(
          data['prescription_path']!,
          _prescriptionPathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
        _frequencyTypeMeta,
        frequencyType.isAcceptableOrUnknown(
          data['frequency_type']!,
          _frequencyTypeMeta,
        ),
      );
    }
    if (data.containsKey('dose_times')) {
      context.handle(
        _doseTimesMeta,
        doseTimes.isAcceptableOrUnknown(data['dose_times']!, _doseTimesMeta),
      );
    }
    if (data.containsKey('interval_hours')) {
      context.handle(
        _intervalHoursMeta,
        intervalHours.isAcceptableOrUnknown(
          data['interval_hours']!,
          _intervalHoursMeta,
        ),
      );
    }
    if (data.containsKey('weekday_mask')) {
      context.handle(
        _weekdayMaskMeta,
        weekdayMask.isAcceptableOrUnknown(
          data['weekday_mask']!,
          _weekdayMaskMeta,
        ),
      );
    }
    if (data.containsKey('meal_relation')) {
      context.handle(
        _mealRelationMeta,
        mealRelation.isAcceptableOrUnknown(
          data['meal_relation']!,
          _mealRelationMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('skip_dates')) {
      context.handle(
        _skipDatesMeta,
        skipDates.isAcceptableOrUnknown(data['skip_dates']!, _skipDatesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      form: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dosage'],
      )!,
      dosageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage_unit'],
      )!,
      inventory: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inventory'],
      )!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold'],
      )!,
      doctorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doctor_name'],
      ),
      prescriptionPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      frequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_type'],
      )!,
      doseTimes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_times'],
      )!,
      intervalHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_hours'],
      )!,
      weekdayMask: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_mask'],
      )!,
      mealRelation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_relation'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      skipDates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_dates'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final int id;

  /// The household member this course belongs to.
  final int? profileId;
  final String name;

  /// tablet | capsule | syrup | injection | drops | inhaler
  final String form;
  final double dosage;
  final String dosageUnit;
  final int inventory;
  final int lowStockThreshold;
  final String? doctorName;
  final String? prescriptionPath;
  final String? notes;

  /// 0 = N times per day, 1 = every X hours, 2 = specific weekdays,
  /// 3 = alternate days
  final int frequencyType;

  /// Comma-separated minutes-from-midnight, e.g. "480,840,1200".
  final String doseTimes;
  final int intervalHours;
  final int weekdayMask;

  /// none | before | after | with
  final String mealRelation;
  final DateTime startDate;
  final DateTime endDate;

  /// Comma-separated yyyy-MM-dd dates to skip (travel/holiday mode).
  final String skipDates;
  final bool isActive;
  final DateTime createdAt;
  const Medicine({
    required this.id,
    this.profileId,
    required this.name,
    required this.form,
    required this.dosage,
    required this.dosageUnit,
    required this.inventory,
    required this.lowStockThreshold,
    this.doctorName,
    this.prescriptionPath,
    this.notes,
    required this.frequencyType,
    required this.doseTimes,
    required this.intervalHours,
    required this.weekdayMask,
    required this.mealRelation,
    required this.startDate,
    required this.endDate,
    required this.skipDates,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['name'] = Variable<String>(name);
    map['form'] = Variable<String>(form);
    map['dosage'] = Variable<double>(dosage);
    map['dosage_unit'] = Variable<String>(dosageUnit);
    map['inventory'] = Variable<int>(inventory);
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    if (!nullToAbsent || doctorName != null) {
      map['doctor_name'] = Variable<String>(doctorName);
    }
    if (!nullToAbsent || prescriptionPath != null) {
      map['prescription_path'] = Variable<String>(prescriptionPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['frequency_type'] = Variable<int>(frequencyType);
    map['dose_times'] = Variable<String>(doseTimes);
    map['interval_hours'] = Variable<int>(intervalHours);
    map['weekday_mask'] = Variable<int>(weekdayMask);
    map['meal_relation'] = Variable<String>(mealRelation);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['skip_dates'] = Variable<String>(skipDates);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      name: Value(name),
      form: Value(form),
      dosage: Value(dosage),
      dosageUnit: Value(dosageUnit),
      inventory: Value(inventory),
      lowStockThreshold: Value(lowStockThreshold),
      doctorName: doctorName == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorName),
      prescriptionPath: prescriptionPath == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriptionPath),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      frequencyType: Value(frequencyType),
      doseTimes: Value(doseTimes),
      intervalHours: Value(intervalHours),
      weekdayMask: Value(weekdayMask),
      mealRelation: Value(mealRelation),
      startDate: Value(startDate),
      endDate: Value(endDate),
      skipDates: Value(skipDates),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Medicine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      id: serializer.fromJson<int>(json['id']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      name: serializer.fromJson<String>(json['name']),
      form: serializer.fromJson<String>(json['form']),
      dosage: serializer.fromJson<double>(json['dosage']),
      dosageUnit: serializer.fromJson<String>(json['dosageUnit']),
      inventory: serializer.fromJson<int>(json['inventory']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      doctorName: serializer.fromJson<String?>(json['doctorName']),
      prescriptionPath: serializer.fromJson<String?>(json['prescriptionPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      frequencyType: serializer.fromJson<int>(json['frequencyType']),
      doseTimes: serializer.fromJson<String>(json['doseTimes']),
      intervalHours: serializer.fromJson<int>(json['intervalHours']),
      weekdayMask: serializer.fromJson<int>(json['weekdayMask']),
      mealRelation: serializer.fromJson<String>(json['mealRelation']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      skipDates: serializer.fromJson<String>(json['skipDates']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileId': serializer.toJson<int?>(profileId),
      'name': serializer.toJson<String>(name),
      'form': serializer.toJson<String>(form),
      'dosage': serializer.toJson<double>(dosage),
      'dosageUnit': serializer.toJson<String>(dosageUnit),
      'inventory': serializer.toJson<int>(inventory),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'doctorName': serializer.toJson<String?>(doctorName),
      'prescriptionPath': serializer.toJson<String?>(prescriptionPath),
      'notes': serializer.toJson<String?>(notes),
      'frequencyType': serializer.toJson<int>(frequencyType),
      'doseTimes': serializer.toJson<String>(doseTimes),
      'intervalHours': serializer.toJson<int>(intervalHours),
      'weekdayMask': serializer.toJson<int>(weekdayMask),
      'mealRelation': serializer.toJson<String>(mealRelation),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'skipDates': serializer.toJson<String>(skipDates),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Medicine copyWith({
    int? id,
    Value<int?> profileId = const Value.absent(),
    String? name,
    String? form,
    double? dosage,
    String? dosageUnit,
    int? inventory,
    int? lowStockThreshold,
    Value<String?> doctorName = const Value.absent(),
    Value<String?> prescriptionPath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? frequencyType,
    String? doseTimes,
    int? intervalHours,
    int? weekdayMask,
    String? mealRelation,
    DateTime? startDate,
    DateTime? endDate,
    String? skipDates,
    bool? isActive,
    DateTime? createdAt,
  }) => Medicine(
    id: id ?? this.id,
    profileId: profileId.present ? profileId.value : this.profileId,
    name: name ?? this.name,
    form: form ?? this.form,
    dosage: dosage ?? this.dosage,
    dosageUnit: dosageUnit ?? this.dosageUnit,
    inventory: inventory ?? this.inventory,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    doctorName: doctorName.present ? doctorName.value : this.doctorName,
    prescriptionPath: prescriptionPath.present
        ? prescriptionPath.value
        : this.prescriptionPath,
    notes: notes.present ? notes.value : this.notes,
    frequencyType: frequencyType ?? this.frequencyType,
    doseTimes: doseTimes ?? this.doseTimes,
    intervalHours: intervalHours ?? this.intervalHours,
    weekdayMask: weekdayMask ?? this.weekdayMask,
    mealRelation: mealRelation ?? this.mealRelation,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    skipDates: skipDates ?? this.skipDates,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Medicine copyWithCompanion(MedicinesCompanion data) {
    return Medicine(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      form: data.form.present ? data.form.value : this.form,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      dosageUnit: data.dosageUnit.present
          ? data.dosageUnit.value
          : this.dosageUnit,
      inventory: data.inventory.present ? data.inventory.value : this.inventory,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      doctorName: data.doctorName.present
          ? data.doctorName.value
          : this.doctorName,
      prescriptionPath: data.prescriptionPath.present
          ? data.prescriptionPath.value
          : this.prescriptionPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      doseTimes: data.doseTimes.present ? data.doseTimes.value : this.doseTimes,
      intervalHours: data.intervalHours.present
          ? data.intervalHours.value
          : this.intervalHours,
      weekdayMask: data.weekdayMask.present
          ? data.weekdayMask.value
          : this.weekdayMask,
      mealRelation: data.mealRelation.present
          ? data.mealRelation.value
          : this.mealRelation,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      skipDates: data.skipDates.present ? data.skipDates.value : this.skipDates,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('form: $form, ')
          ..write('dosage: $dosage, ')
          ..write('dosageUnit: $dosageUnit, ')
          ..write('inventory: $inventory, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('doctorName: $doctorName, ')
          ..write('prescriptionPath: $prescriptionPath, ')
          ..write('notes: $notes, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('doseTimes: $doseTimes, ')
          ..write('intervalHours: $intervalHours, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('mealRelation: $mealRelation, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('skipDates: $skipDates, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    profileId,
    name,
    form,
    dosage,
    dosageUnit,
    inventory,
    lowStockThreshold,
    doctorName,
    prescriptionPath,
    notes,
    frequencyType,
    doseTimes,
    intervalHours,
    weekdayMask,
    mealRelation,
    startDate,
    endDate,
    skipDates,
    isActive,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.form == this.form &&
          other.dosage == this.dosage &&
          other.dosageUnit == this.dosageUnit &&
          other.inventory == this.inventory &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.doctorName == this.doctorName &&
          other.prescriptionPath == this.prescriptionPath &&
          other.notes == this.notes &&
          other.frequencyType == this.frequencyType &&
          other.doseTimes == this.doseTimes &&
          other.intervalHours == this.intervalHours &&
          other.weekdayMask == this.weekdayMask &&
          other.mealRelation == this.mealRelation &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.skipDates == this.skipDates &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<int> id;
  final Value<int?> profileId;
  final Value<String> name;
  final Value<String> form;
  final Value<double> dosage;
  final Value<String> dosageUnit;
  final Value<int> inventory;
  final Value<int> lowStockThreshold;
  final Value<String?> doctorName;
  final Value<String?> prescriptionPath;
  final Value<String?> notes;
  final Value<int> frequencyType;
  final Value<String> doseTimes;
  final Value<int> intervalHours;
  final Value<int> weekdayMask;
  final Value<String> mealRelation;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> skipDates;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.form = const Value.absent(),
    this.dosage = const Value.absent(),
    this.dosageUnit = const Value.absent(),
    this.inventory = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.prescriptionPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.doseTimes = const Value.absent(),
    this.intervalHours = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.mealRelation = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.skipDates = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MedicinesCompanion.insert({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    required String name,
    this.form = const Value.absent(),
    this.dosage = const Value.absent(),
    this.dosageUnit = const Value.absent(),
    this.inventory = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.prescriptionPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.doseTimes = const Value.absent(),
    this.intervalHours = const Value.absent(),
    this.weekdayMask = const Value.absent(),
    this.mealRelation = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    this.skipDates = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<Medicine> custom({
    Expression<int>? id,
    Expression<int>? profileId,
    Expression<String>? name,
    Expression<String>? form,
    Expression<double>? dosage,
    Expression<String>? dosageUnit,
    Expression<int>? inventory,
    Expression<int>? lowStockThreshold,
    Expression<String>? doctorName,
    Expression<String>? prescriptionPath,
    Expression<String>? notes,
    Expression<int>? frequencyType,
    Expression<String>? doseTimes,
    Expression<int>? intervalHours,
    Expression<int>? weekdayMask,
    Expression<String>? mealRelation,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? skipDates,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (form != null) 'form': form,
      if (dosage != null) 'dosage': dosage,
      if (dosageUnit != null) 'dosage_unit': dosageUnit,
      if (inventory != null) 'inventory': inventory,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (doctorName != null) 'doctor_name': doctorName,
      if (prescriptionPath != null) 'prescription_path': prescriptionPath,
      if (notes != null) 'notes': notes,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (doseTimes != null) 'dose_times': doseTimes,
      if (intervalHours != null) 'interval_hours': intervalHours,
      if (weekdayMask != null) 'weekday_mask': weekdayMask,
      if (mealRelation != null) 'meal_relation': mealRelation,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (skipDates != null) 'skip_dates': skipDates,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MedicinesCompanion copyWith({
    Value<int>? id,
    Value<int?>? profileId,
    Value<String>? name,
    Value<String>? form,
    Value<double>? dosage,
    Value<String>? dosageUnit,
    Value<int>? inventory,
    Value<int>? lowStockThreshold,
    Value<String?>? doctorName,
    Value<String?>? prescriptionPath,
    Value<String?>? notes,
    Value<int>? frequencyType,
    Value<String>? doseTimes,
    Value<int>? intervalHours,
    Value<int>? weekdayMask,
    Value<String>? mealRelation,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<String>? skipDates,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      form: form ?? this.form,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      inventory: inventory ?? this.inventory,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      doctorName: doctorName ?? this.doctorName,
      prescriptionPath: prescriptionPath ?? this.prescriptionPath,
      notes: notes ?? this.notes,
      frequencyType: frequencyType ?? this.frequencyType,
      doseTimes: doseTimes ?? this.doseTimes,
      intervalHours: intervalHours ?? this.intervalHours,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      mealRelation: mealRelation ?? this.mealRelation,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      skipDates: skipDates ?? this.skipDates,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<double>(dosage.value);
    }
    if (dosageUnit.present) {
      map['dosage_unit'] = Variable<String>(dosageUnit.value);
    }
    if (inventory.present) {
      map['inventory'] = Variable<int>(inventory.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (doctorName.present) {
      map['doctor_name'] = Variable<String>(doctorName.value);
    }
    if (prescriptionPath.present) {
      map['prescription_path'] = Variable<String>(prescriptionPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<int>(frequencyType.value);
    }
    if (doseTimes.present) {
      map['dose_times'] = Variable<String>(doseTimes.value);
    }
    if (intervalHours.present) {
      map['interval_hours'] = Variable<int>(intervalHours.value);
    }
    if (weekdayMask.present) {
      map['weekday_mask'] = Variable<int>(weekdayMask.value);
    }
    if (mealRelation.present) {
      map['meal_relation'] = Variable<String>(mealRelation.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (skipDates.present) {
      map['skip_dates'] = Variable<String>(skipDates.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('form: $form, ')
          ..write('dosage: $dosage, ')
          ..write('dosageUnit: $dosageUnit, ')
          ..write('inventory: $inventory, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('doctorName: $doctorName, ')
          ..write('prescriptionPath: $prescriptionPath, ')
          ..write('notes: $notes, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('doseTimes: $doseTimes, ')
          ..write('intervalHours: $intervalHours, ')
          ..write('weekdayMask: $weekdayMask, ')
          ..write('mealRelation: $mealRelation, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('skipDates: $skipDates, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MedicineDosesTable extends MedicineDoses
    with TableInfo<$MedicineDosesTable, MedicineDose> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicineDosesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<int> medicineId = GeneratedColumn<int>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>(
        'scheduled_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _actionedAtMeta = const VerificationMeta(
    'actionedAt',
  );
  @override
  late final GeneratedColumn<DateTime> actionedAt = GeneratedColumn<DateTime>(
    'actioned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    scheduledTime,
    status,
    actionedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicine_doses';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicineDose> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('actioned_at')) {
      context.handle(
        _actionedAtMeta,
        actionedAt.isAcceptableOrUnknown(data['actioned_at']!, _actionedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {medicineId, scheduledTime},
  ];
  @override
  MedicineDose map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineDose(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medicine_id'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      actionedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actioned_at'],
      ),
    );
  }

  @override
  $MedicineDosesTable createAlias(String alias) {
    return $MedicineDosesTable(attachedDatabase, alias);
  }
}

class MedicineDose extends DataClass implements Insertable<MedicineDose> {
  final int id;
  final int medicineId;
  final DateTime scheduledTime;

  /// 0 = pending, 1 = taken, 2 = skipped
  final int status;
  final DateTime? actionedAt;
  const MedicineDose({
    required this.id,
    required this.medicineId,
    required this.scheduledTime,
    required this.status,
    this.actionedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medicine_id'] = Variable<int>(medicineId);
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || actionedAt != null) {
      map['actioned_at'] = Variable<DateTime>(actionedAt);
    }
    return map;
  }

  MedicineDosesCompanion toCompanion(bool nullToAbsent) {
    return MedicineDosesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      scheduledTime: Value(scheduledTime),
      status: Value(status),
      actionedAt: actionedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actionedAt),
    );
  }

  factory MedicineDose.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineDose(
      id: serializer.fromJson<int>(json['id']),
      medicineId: serializer.fromJson<int>(json['medicineId']),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      status: serializer.fromJson<int>(json['status']),
      actionedAt: serializer.fromJson<DateTime?>(json['actionedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicineId': serializer.toJson<int>(medicineId),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'status': serializer.toJson<int>(status),
      'actionedAt': serializer.toJson<DateTime?>(actionedAt),
    };
  }

  MedicineDose copyWith({
    int? id,
    int? medicineId,
    DateTime? scheduledTime,
    int? status,
    Value<DateTime?> actionedAt = const Value.absent(),
  }) => MedicineDose(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    status: status ?? this.status,
    actionedAt: actionedAt.present ? actionedAt.value : this.actionedAt,
  );
  MedicineDose copyWithCompanion(MedicineDosesCompanion data) {
    return MedicineDose(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      status: data.status.present ? data.status.value : this.status,
      actionedAt: data.actionedAt.present
          ? data.actionedAt.value
          : this.actionedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineDose(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('status: $status, ')
          ..write('actionedAt: $actionedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, medicineId, scheduledTime, status, actionedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineDose &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.scheduledTime == this.scheduledTime &&
          other.status == this.status &&
          other.actionedAt == this.actionedAt);
}

class MedicineDosesCompanion extends UpdateCompanion<MedicineDose> {
  final Value<int> id;
  final Value<int> medicineId;
  final Value<DateTime> scheduledTime;
  final Value<int> status;
  final Value<DateTime?> actionedAt;
  const MedicineDosesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.status = const Value.absent(),
    this.actionedAt = const Value.absent(),
  });
  MedicineDosesCompanion.insert({
    this.id = const Value.absent(),
    required int medicineId,
    required DateTime scheduledTime,
    this.status = const Value.absent(),
    this.actionedAt = const Value.absent(),
  }) : medicineId = Value(medicineId),
       scheduledTime = Value(scheduledTime);
  static Insertable<MedicineDose> custom({
    Expression<int>? id,
    Expression<int>? medicineId,
    Expression<DateTime>? scheduledTime,
    Expression<int>? status,
    Expression<DateTime>? actionedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (status != null) 'status': status,
      if (actionedAt != null) 'actioned_at': actionedAt,
    });
  }

  MedicineDosesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicineId,
    Value<DateTime>? scheduledTime,
    Value<int>? status,
    Value<DateTime?>? actionedAt,
  }) {
    return MedicineDosesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      actionedAt: actionedAt ?? this.actionedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<int>(medicineId.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (actionedAt.present) {
      map['actioned_at'] = Variable<DateTime>(actionedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicineDosesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('status: $status, ')
          ..write('actionedAt: $actionedAt')
          ..write(')'))
        .toString();
  }
}

class $SymptomLogsTable extends SymptomLogs
    with TableInfo<$SymptomLogsTable, SymptomLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<int> medicineId = GeneratedColumn<int>(
    'medicine_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
    'profile_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _symptomMeta = const VerificationMeta(
    'symptom',
  );
  @override
  late final GeneratedColumn<String> symptom = GeneratedColumn<String>(
    'symptom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    profileId,
    date,
    symptom,
    severity,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SymptomLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('symptom')) {
      context.handle(
        _symptomMeta,
        symptom.isAcceptableOrUnknown(data['symptom']!, _symptomMeta),
      );
    } else if (isInserting) {
      context.missing(_symptomMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SymptomLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medicine_id'],
      ),
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profile_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      symptom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptom'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $SymptomLogsTable createAlias(String alias) {
    return $SymptomLogsTable(attachedDatabase, alias);
  }
}

class SymptomLog extends DataClass implements Insertable<SymptomLog> {
  final int id;
  final int? medicineId;
  final int? profileId;
  final DateTime date;
  final String symptom;

  /// 1 (mild) … 5 (severe)
  final int severity;
  final String? note;
  const SymptomLog({
    required this.id,
    this.medicineId,
    this.profileId,
    required this.date,
    required this.symptom,
    required this.severity,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || medicineId != null) {
      map['medicine_id'] = Variable<int>(medicineId);
    }
    if (!nullToAbsent || profileId != null) {
      map['profile_id'] = Variable<int>(profileId);
    }
    map['date'] = Variable<DateTime>(date);
    map['symptom'] = Variable<String>(symptom);
    map['severity'] = Variable<int>(severity);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SymptomLogsCompanion toCompanion(bool nullToAbsent) {
    return SymptomLogsCompanion(
      id: Value(id),
      medicineId: medicineId == null && nullToAbsent
          ? const Value.absent()
          : Value(medicineId),
      profileId: profileId == null && nullToAbsent
          ? const Value.absent()
          : Value(profileId),
      date: Value(date),
      symptom: Value(symptom),
      severity: Value(severity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SymptomLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomLog(
      id: serializer.fromJson<int>(json['id']),
      medicineId: serializer.fromJson<int?>(json['medicineId']),
      profileId: serializer.fromJson<int?>(json['profileId']),
      date: serializer.fromJson<DateTime>(json['date']),
      symptom: serializer.fromJson<String>(json['symptom']),
      severity: serializer.fromJson<int>(json['severity']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicineId': serializer.toJson<int?>(medicineId),
      'profileId': serializer.toJson<int?>(profileId),
      'date': serializer.toJson<DateTime>(date),
      'symptom': serializer.toJson<String>(symptom),
      'severity': serializer.toJson<int>(severity),
      'note': serializer.toJson<String?>(note),
    };
  }

  SymptomLog copyWith({
    int? id,
    Value<int?> medicineId = const Value.absent(),
    Value<int?> profileId = const Value.absent(),
    DateTime? date,
    String? symptom,
    int? severity,
    Value<String?> note = const Value.absent(),
  }) => SymptomLog(
    id: id ?? this.id,
    medicineId: medicineId.present ? medicineId.value : this.medicineId,
    profileId: profileId.present ? profileId.value : this.profileId,
    date: date ?? this.date,
    symptom: symptom ?? this.symptom,
    severity: severity ?? this.severity,
    note: note.present ? note.value : this.note,
  );
  SymptomLog copyWithCompanion(SymptomLogsCompanion data) {
    return SymptomLog(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      date: data.date.present ? data.date.value : this.date,
      symptom: data.symptom.present ? data.symptom.value : this.symptom,
      severity: data.severity.present ? data.severity.value : this.severity,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLog(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('symptom: $symptom, ')
          ..write('severity: $severity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, medicineId, profileId, date, symptom, severity, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomLog &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.profileId == this.profileId &&
          other.date == this.date &&
          other.symptom == this.symptom &&
          other.severity == this.severity &&
          other.note == this.note);
}

class SymptomLogsCompanion extends UpdateCompanion<SymptomLog> {
  final Value<int> id;
  final Value<int?> medicineId;
  final Value<int?> profileId;
  final Value<DateTime> date;
  final Value<String> symptom;
  final Value<int> severity;
  final Value<String?> note;
  const SymptomLogsCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.date = const Value.absent(),
    this.symptom = const Value.absent(),
    this.severity = const Value.absent(),
    this.note = const Value.absent(),
  });
  SymptomLogsCompanion.insert({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.date = const Value.absent(),
    required String symptom,
    this.severity = const Value.absent(),
    this.note = const Value.absent(),
  }) : symptom = Value(symptom);
  static Insertable<SymptomLog> custom({
    Expression<int>? id,
    Expression<int>? medicineId,
    Expression<int>? profileId,
    Expression<DateTime>? date,
    Expression<String>? symptom,
    Expression<int>? severity,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (profileId != null) 'profile_id': profileId,
      if (date != null) 'date': date,
      if (symptom != null) 'symptom': symptom,
      if (severity != null) 'severity': severity,
      if (note != null) 'note': note,
    });
  }

  SymptomLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? medicineId,
    Value<int?>? profileId,
    Value<DateTime>? date,
    Value<String>? symptom,
    Value<int>? severity,
    Value<String?>? note,
  }) {
    return SymptomLogsCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      profileId: profileId ?? this.profileId,
      date: date ?? this.date,
      symptom: symptom ?? this.symptom,
      severity: severity ?? this.severity,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<int>(medicineId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (symptom.present) {
      map['symptom'] = Variable<String>(symptom.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLogsCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('profileId: $profileId, ')
          ..write('date: $date, ')
          ..write('symptom: $symptom, ')
          ..write('severity: $severity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(25),
  );
  static const VerificationMeta _actualSecondsMeta = const VerificationMeta(
    'actualSeconds',
  );
  @override
  late final GeneratedColumn<int> actualSeconds = GeneratedColumn<int>(
    'actual_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pomodoro'),
  );
  static const VerificationMeta _isBreakMeta = const VerificationMeta(
    'isBreak',
  );
  @override
  late final GeneratedColumn<bool> isBreak = GeneratedColumn<bool>(
    'is_break',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_break" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    durationMinutes,
    actualSeconds,
    startTime,
    endTime,
    taskId,
    note,
    rating,
    mode,
    isBreak,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('actual_seconds')) {
      context.handle(
        _actualSecondsMeta,
        actualSeconds.isAcceptableOrUnknown(
          data['actual_seconds']!,
          _actualSecondsMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('is_break')) {
      context.handle(
        _isBreakMeta,
        isBreak.isAcceptableOrUnknown(data['is_break']!, _isBreakMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      actualSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_seconds'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      isBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_break'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
  final int durationMinutes;

  /// Seconds actually focused, which can differ if the user stops early.
  final int actualSeconds;
  final DateTime startTime;
  final DateTime? endTime;
  final int? taskId;
  final String? note;

  /// Self-rated focus quality, 1-5.
  final int? rating;

  /// pomodoro | 52-17 | deep | flow | reverse | custom
  final String mode;

  /// False for break intervals so they are excluded from focus totals.
  final bool isBreak;
  final bool isCompleted;
  const FocusSession({
    required this.id,
    required this.durationMinutes,
    required this.actualSeconds,
    required this.startTime,
    this.endTime,
    this.taskId,
    this.note,
    this.rating,
    required this.mode,
    required this.isBreak,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['actual_seconds'] = Variable<int>(actualSeconds);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['mode'] = Variable<String>(mode);
    map['is_break'] = Variable<bool>(isBreak);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      durationMinutes: Value(durationMinutes),
      actualSeconds: Value(actualSeconds),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      mode: Value(mode),
      isBreak: Value(isBreak),
      isCompleted: Value(isCompleted),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      actualSeconds: serializer.fromJson<int>(json['actualSeconds']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      note: serializer.fromJson<String?>(json['note']),
      rating: serializer.fromJson<int?>(json['rating']),
      mode: serializer.fromJson<String>(json['mode']),
      isBreak: serializer.fromJson<bool>(json['isBreak']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'actualSeconds': serializer.toJson<int>(actualSeconds),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'taskId': serializer.toJson<int?>(taskId),
      'note': serializer.toJson<String?>(note),
      'rating': serializer.toJson<int?>(rating),
      'mode': serializer.toJson<String>(mode),
      'isBreak': serializer.toJson<bool>(isBreak),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  FocusSession copyWith({
    int? id,
    int? durationMinutes,
    int? actualSeconds,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    Value<int?> taskId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    String? mode,
    bool? isBreak,
    bool? isCompleted,
  }) => FocusSession(
    id: id ?? this.id,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    actualSeconds: actualSeconds ?? this.actualSeconds,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    taskId: taskId.present ? taskId.value : this.taskId,
    note: note.present ? note.value : this.note,
    rating: rating.present ? rating.value : this.rating,
    mode: mode ?? this.mode,
    isBreak: isBreak ?? this.isBreak,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      actualSeconds: data.actualSeconds.present
          ? data.actualSeconds.value
          : this.actualSeconds,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      note: data.note.present ? data.note.value : this.note,
      rating: data.rating.present ? data.rating.value : this.rating,
      mode: data.mode.present ? data.mode.value : this.mode,
      isBreak: data.isBreak.present ? data.isBreak.value : this.isBreak,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('taskId: $taskId, ')
          ..write('note: $note, ')
          ..write('rating: $rating, ')
          ..write('mode: $mode, ')
          ..write('isBreak: $isBreak, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    durationMinutes,
    actualSeconds,
    startTime,
    endTime,
    taskId,
    note,
    rating,
    mode,
    isBreak,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.durationMinutes == this.durationMinutes &&
          other.actualSeconds == this.actualSeconds &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.taskId == this.taskId &&
          other.note == this.note &&
          other.rating == this.rating &&
          other.mode == this.mode &&
          other.isBreak == this.isBreak &&
          other.isCompleted == this.isCompleted);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<int> durationMinutes;
  final Value<int> actualSeconds;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int?> taskId;
  final Value<String?> note;
  final Value<int?> rating;
  final Value<String> mode;
  final Value<bool> isBreak;
  final Value<bool> isCompleted;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.taskId = const Value.absent(),
    this.note = const Value.absent(),
    this.rating = const Value.absent(),
    this.mode = const Value.absent(),
    this.isBreak = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.actualSeconds = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.taskId = const Value.absent(),
    this.note = const Value.absent(),
    this.rating = const Value.absent(),
    this.mode = const Value.absent(),
    this.isBreak = const Value.absent(),
    this.isCompleted = const Value.absent(),
  }) : startTime = Value(startTime);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<int>? durationMinutes,
    Expression<int>? actualSeconds,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? taskId,
    Expression<String>? note,
    Expression<int>? rating,
    Expression<String>? mode,
    Expression<bool>? isBreak,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (actualSeconds != null) 'actual_seconds': actualSeconds,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (taskId != null) 'task_id': taskId,
      if (note != null) 'note': note,
      if (rating != null) 'rating': rating,
      if (mode != null) 'mode': mode,
      if (isBreak != null) 'is_break': isBreak,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? durationMinutes,
    Value<int>? actualSeconds,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int?>? taskId,
    Value<String?>? note,
    Value<int?>? rating,
    Value<String>? mode,
    Value<bool>? isBreak,
    Value<bool>? isCompleted,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      actualSeconds: actualSeconds ?? this.actualSeconds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      taskId: taskId ?? this.taskId,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      mode: mode ?? this.mode,
      isBreak: isBreak ?? this.isBreak,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (actualSeconds.present) {
      map['actual_seconds'] = Variable<int>(actualSeconds.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (isBreak.present) {
      map['is_break'] = Variable<bool>(isBreak.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('actualSeconds: $actualSeconds, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('taskId: $taskId, ')
          ..write('note: $note, ')
          ..write('rating: $rating, ')
          ..write('mode: $mode, ')
          ..write('isBreak: $isBreak, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskTagsTable taskTags = $TaskTagsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringExpensesTable recurringExpenses =
      $RecurringExpensesTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $MedicineDosesTable medicineDoses = $MedicineDosesTable(this);
  late final $SymptomLogsTable symptomLogs = $SymptomLogsTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    notes,
    tags,
    noteTags,
    projects,
    tasks,
    taskTags,
    habits,
    habitLogs,
    people,
    accounts,
    expenseCategories,
    loans,
    expenses,
    budgets,
    recurringExpenses,
    medicines,
    medicineDoses,
    symptomLogs,
    focusSessions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'expense_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'accounts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'loans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'expense_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('budgets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'people',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medicines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medicine_doses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('focus_sessions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> parentId,
      Value<DateTime> createdAt,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> parentId,
      Value<DateTime> createdAt,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _parentIdTable(_$AppDatabase db) =>
      db.folders.createAlias('folders__parent_id__folders__id');

  $$FoldersTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<int>('parent_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'folders__id__notes__folder_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get parentId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get parentId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get parentId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool parentId, bool notesRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                parentId: parentId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> parentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false, notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notesRefs) db.notes],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable: $$FoldersTableReferences
                                    ._parentIdTable(db),
                                referencedColumn: $$FoldersTableReferences
                                    ._parentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notesRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, Note>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences._notesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).notesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool parentId, bool notesRefs})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> title,
      required String content,
      Value<String> plainText,
      Value<int?> folderId,
      Value<bool> isPinned,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<bool> isLocked,
      Value<DateTime?> deletedAt,
      Value<DateTime?> journalDate,
      Value<DateTime?> reminderAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> content,
      Value<String> plainText,
      Value<int?> folderId,
      Value<bool> isPinned,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<bool> isLocked,
      Value<DateTime?> deletedAt,
      Value<DateTime?> journalDate,
      Value<DateTime?> reminderAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias('notes__folder_id__folders__id');

  $$FoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<int>('folder_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTag>> _noteTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'notes__id__note_tags__note_id',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager(
      $_db,
      $_db.noteTags,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get journalDate => $composableBuilder(
    column: $table.journalDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool folderId, bool noteTagsRefs})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> journalDate = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                title: title,
                content: content,
                plainText: plainText,
                folderId: folderId,
                isPinned: isPinned,
                isFavorite: isFavorite,
                isArchived: isArchived,
                isLocked: isLocked,
                deletedAt: deletedAt,
                journalDate: journalDate,
                reminderAt: reminderAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                required String content,
                Value<String> plainText = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> journalDate = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                title: title,
                content: content,
                plainText: plainText,
                folderId: folderId,
                isPinned: isPinned,
                isFavorite: isFavorite,
                isArchived: isArchived,
                isLocked: isLocked,
                deletedAt: deletedAt,
                journalDate: journalDate,
                reminderAt: reminderAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false, noteTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (noteTagsRefs) db.noteTags],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.folderId,
                                referencedTable: $$NotesTableReferences
                                    ._folderIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._folderIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (noteTagsRefs)
                    await $_getPrefetchedData<Note, $NotesTable, NoteTag>(
                      currentTable: table,
                      referencedTable: $$NotesTableReferences
                          ._noteTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NotesTableReferences(db, table, p0).noteTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.noteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool folderId, bool noteTagsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> color,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> color,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTag>> _noteTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'tags__id__note_tags__tag_id',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager(
      $_db,
      $_db.noteTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskTagsTable, List<TaskTag>> _taskTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.taskTags,
    aliasName: 'tags__id__task_tags__tag_id',
  );

  $$TaskTagsTableProcessedTableManager get taskTagsRefs {
    final manager = $$TaskTagsTableTableManager(
      $_db,
      $_db.taskTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskTagsRefs(
    Expression<bool> Function($$TaskTagsTableFilterComposer f) f,
  ) {
    final $$TaskTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTagsTableFilterComposer(
            $db: $db,
            $table: $db.taskTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskTagsRefs<T extends Object>(
    Expression<T> Function($$TaskTagsTableAnnotationComposer a) f,
  ) {
    final $$TaskTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool noteTagsRefs, bool taskTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
              }) => TagsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteTagsRefs = false, taskTagsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (noteTagsRefs) db.noteTags,
                    if (taskTagsRefs) db.taskTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, NoteTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._noteTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagsTableReferences(db, table, p0).noteTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskTagsRefs)
                        await $_getPrefetchedData<Tag, $TagsTable, TaskTag>(
                          currentTable: table,
                          referencedTable: $$TagsTableReferences
                              ._taskTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TagsTableReferences(db, table, p0).taskTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tagId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool noteTagsRefs, bool taskTagsRefs})
    >;
typedef $$NoteTagsTableCreateCompanionBuilder =
    NoteTagsCompanion Function({
      required int noteId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$NoteTagsTableUpdateCompanionBuilder =
    NoteTagsCompanion Function({
      Value<int> noteId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$NoteTagsTableReferences
    extends BaseReferences<_$AppDatabase, $NoteTagsTable, NoteTag> {
  $$NoteTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$AppDatabase db) =>
      db.notes.createAlias('note_tags__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<int>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('note_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTagsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTagsTable,
          NoteTag,
          $$NoteTagsTableFilterComposer,
          $$NoteTagsTableOrderingComposer,
          $$NoteTagsTableAnnotationComposer,
          $$NoteTagsTableCreateCompanionBuilder,
          $$NoteTagsTableUpdateCompanionBuilder,
          (NoteTag, $$NoteTagsTableReferences),
          NoteTag,
          PrefetchHooks Function({bool noteId, bool tagId})
        > {
  $$NoteTagsTableTableManager(_$AppDatabase db, $NoteTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> noteId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  NoteTagsCompanion(noteId: noteId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int noteId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => NoteTagsCompanion.insert(
                noteId: noteId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NoteTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.noteId,
                                referencedTable: $$NoteTagsTableReferences
                                    ._noteIdTable(db),
                                referencedColumn: $$NoteTagsTableReferences
                                    ._noteIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$NoteTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$NoteTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTagsTable,
      NoteTag,
      $$NoteTagsTableFilterComposer,
      $$NoteTagsTableOrderingComposer,
      $$NoteTagsTableAnnotationComposer,
      $$NoteTagsTableCreateCompanionBuilder,
      $$NoteTagsTableUpdateCompanionBuilder,
      (NoteTag, $$NoteTagsTableReferences),
      NoteTag,
      PrefetchHooks Function({bool noteId, bool tagId})
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> color,
      Value<String> icon,
      Value<int> sortOrder,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> color,
      Value<String> icon,
      Value<int> sortOrder,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'projects__id__tasks__project_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable, Task>(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProjectsTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<bool> hasDueTime,
      Value<DateTime?> reminderTime,
      Value<int> priority,
      Value<int?> projectId,
      Value<int?> parentTaskId,
      Value<String?> recurrenceRule,
      Value<int> boardStatus,
      Value<int?> estimateMinutes,
      Value<int> loggedMinutes,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<bool> hasDueTime,
      Value<DateTime?> reminderTime,
      Value<int> priority,
      Value<int?> projectId,
      Value<int?> parentTaskId,
      Value<String?> recurrenceRule,
      Value<int> boardStatus,
      Value<int?> estimateMinutes,
      Value<int> loggedMinutes,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('tasks__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<int>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TaskTagsTable, List<TaskTag>> _taskTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.taskTags,
    aliasName: 'tasks__id__task_tags__task_id',
  );

  $$TaskTagsTableProcessedTableManager get taskTagsRefs {
    final manager = $$TaskTagsTableTableManager(
      $_db,
      $_db.taskTags,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FocusSessionsTable, List<FocusSession>>
  _focusSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.focusSessions,
    aliasName: 'tasks__id__focus_sessions__task_id',
  );

  $$FocusSessionsTableProcessedTableManager get focusSessionsRefs {
    final manager = $$FocusSessionsTableTableManager(
      $_db,
      $_db.focusSessions,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDueTime => $composableBuilder(
    column: $table.hasDueTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentTaskId => $composableBuilder(
    column: $table.parentTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get boardStatus => $composableBuilder(
    column: $table.boardStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loggedMinutes => $composableBuilder(
    column: $table.loggedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskTagsRefs(
    Expression<bool> Function($$TaskTagsTableFilterComposer f) f,
  ) {
    final $$TaskTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTags,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTagsTableFilterComposer(
            $db: $db,
            $table: $db.taskTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> focusSessionsRefs(
    Expression<bool> Function($$FocusSessionsTableFilterComposer f) f,
  ) {
    final $$FocusSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableFilterComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDueTime => $composableBuilder(
    column: $table.hasDueTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentTaskId => $composableBuilder(
    column: $table.parentTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get boardStatus => $composableBuilder(
    column: $table.boardStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loggedMinutes => $composableBuilder(
    column: $table.loggedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get hasDueTime => $composableBuilder(
    column: $table.hasDueTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get parentTaskId => $composableBuilder(
    column: $table.parentTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceRule => $composableBuilder(
    column: $table.recurrenceRule,
    builder: (column) => column,
  );

  GeneratedColumn<int> get boardStatus => $composableBuilder(
    column: $table.boardStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimateMinutes => $composableBuilder(
    column: $table.estimateMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loggedMinutes => $composableBuilder(
    column: $table.loggedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskTagsRefs<T extends Object>(
    Expression<T> Function($$TaskTagsTableAnnotationComposer a) f,
  ) {
    final $$TaskTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTags,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> focusSessionsRefs<T extends Object>(
    Expression<T> Function($$FocusSessionsTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessions,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FocusSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({
            bool projectId,
            bool taskTagsRefs,
            bool focusSessionsRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> hasDueTime = const Value.absent(),
                Value<DateTime?> reminderTime = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<int?> parentTaskId = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int> boardStatus = const Value.absent(),
                Value<int?> estimateMinutes = const Value.absent(),
                Value<int> loggedMinutes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                description: description,
                dueDate: dueDate,
                hasDueTime: hasDueTime,
                reminderTime: reminderTime,
                priority: priority,
                projectId: projectId,
                parentTaskId: parentTaskId,
                recurrenceRule: recurrenceRule,
                boardStatus: boardStatus,
                estimateMinutes: estimateMinutes,
                loggedMinutes: loggedMinutes,
                isCompleted: isCompleted,
                completedAt: completedAt,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> hasDueTime = const Value.absent(),
                Value<DateTime?> reminderTime = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<int?> parentTaskId = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<int> boardStatus = const Value.absent(),
                Value<int?> estimateMinutes = const Value.absent(),
                Value<int> loggedMinutes = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                description: description,
                dueDate: dueDate,
                hasDueTime: hasDueTime,
                reminderTime: reminderTime,
                priority: priority,
                projectId: projectId,
                parentTaskId: parentTaskId,
                recurrenceRule: recurrenceRule,
                boardStatus: boardStatus,
                estimateMinutes: estimateMinutes,
                loggedMinutes: loggedMinutes,
                isCompleted: isCompleted,
                completedAt: completedAt,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                taskTagsRefs = false,
                focusSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (taskTagsRefs) db.taskTags,
                    if (focusSessionsRefs) db.focusSessions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$TasksTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn: $$TasksTableReferences
                                        ._projectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (taskTagsRefs)
                        await $_getPrefetchedData<Task, $TasksTable, TaskTag>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (focusSessionsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          FocusSession
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._focusSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).focusSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({
        bool projectId,
        bool taskTagsRefs,
        bool focusSessionsRefs,
      })
    >;
typedef $$TaskTagsTableCreateCompanionBuilder =
    TaskTagsCompanion Function({
      required int taskId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$TaskTagsTableUpdateCompanionBuilder =
    TaskTagsCompanion Function({
      Value<int> taskId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$TaskTagsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskTagsTable, TaskTag> {
  $$TaskTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_tags__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('task_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskTagsTable> {
  $$TaskTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskTagsTable,
          TaskTag,
          $$TaskTagsTableFilterComposer,
          $$TaskTagsTableOrderingComposer,
          $$TaskTagsTableAnnotationComposer,
          $$TaskTagsTableCreateCompanionBuilder,
          $$TaskTagsTableUpdateCompanionBuilder,
          (TaskTag, $$TaskTagsTableReferences),
          TaskTag,
          PrefetchHooks Function({bool taskId, bool tagId})
        > {
  $$TaskTagsTableTableManager(_$AppDatabase db, $TaskTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  TaskTagsCompanion(taskId: taskId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required int taskId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => TaskTagsCompanion.insert(
                taskId: taskId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskTagsTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$TaskTagsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$TaskTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$TaskTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskTagsTable,
      TaskTag,
      $$TaskTagsTableFilterComposer,
      $$TaskTagsTableOrderingComposer,
      $$TaskTagsTableAnnotationComposer,
      $$TaskTagsTableCreateCompanionBuilder,
      $$TaskTagsTableUpdateCompanionBuilder,
      (TaskTag, $$TaskTagsTableReferences),
      TaskTag,
      PrefetchHooks Function({bool taskId, bool tagId})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> icon,
      Value<int> color,
      Value<String?> unit,
      Value<int> goalType,
      Value<double> targetAmount,
      Value<int> frequencyType,
      Value<int> weekdayMask,
      Value<int> timesPerWeek,
      Value<double?> costPerUnit,
      Value<double?> caffeineMgPerUnit,
      Value<int?> reminderMinutes,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<int> color,
      Value<String?> unit,
      Value<int> goalType,
      Value<double> targetAmount,
      Value<int> frequencyType,
      Value<int> weekdayMask,
      Value<int> timesPerWeek,
      Value<double?> costPerUnit,
      Value<double?> caffeineMgPerUnit,
      Value<int?> reminderMinutes,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLog>>
  _habitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogs,
    aliasName: 'habits__id__habit_logs__habit_id',
  );

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get caffeineMgPerUnit => $composableBuilder(
    column: $table.caffeineMgPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitLogsRefs(
    Expression<bool> Function($$HabitLogsTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get caffeineMgPerUnit => $composableBuilder(
    column: $table.caffeineMgPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get caffeineMgPerUnit => $composableBuilder(
    column: $table.caffeineMgPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinutes => $composableBuilder(
    column: $table.reminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> habitLogsRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool habitLogsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int> goalType = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<int> frequencyType = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<double?> caffeineMgPerUnit = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                unit: unit,
                goalType: goalType,
                targetAmount: targetAmount,
                frequencyType: frequencyType,
                weekdayMask: weekdayMask,
                timesPerWeek: timesPerWeek,
                costPerUnit: costPerUnit,
                caffeineMgPerUnit: caffeineMgPerUnit,
                reminderMinutes: reminderMinutes,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int> goalType = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<int> frequencyType = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<double?> caffeineMgPerUnit = const Value.absent(),
                Value<int?> reminderMinutes = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                unit: unit,
                goalType: goalType,
                targetAmount: targetAmount,
                frequencyType: frequencyType,
                weekdayMask: weekdayMask,
                timesPerWeek: timesPerWeek,
                costPerUnit: costPerUnit,
                caffeineMgPerUnit: caffeineMgPerUnit,
                reminderMinutes: reminderMinutes,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({habitLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (habitLogsRefs) db.habitLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsRefs)
                    await $_getPrefetchedData<Habit, $HabitsTable, HabitLog>(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._habitLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).habitLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool habitLogsRefs})
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime date,
      Value<double> amount,
      Value<String?> note,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> date,
      Value<double> amount,
      Value<String?> note,
    });

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_logs__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, $$HabitLogsTableReferences),
          HabitLog,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => HabitLogsCompanion(
                id: id,
                habitId: habitId,
                date: date,
                amount: amount,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime date,
                Value<double> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                amount: amount,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, $$HabitLogsTableReferences),
      HabitLog,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      Value<int> id,
      required String name,
      Value<String> relation,
      Value<int> color,
      Value<String> type,
      Value<bool> isSelf,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> relation,
      Value<int> color,
      Value<String> type,
      Value<bool> isSelf,
    });

final class $$PeopleTableReferences
    extends BaseReferences<_$AppDatabase, $PeopleTable, Person> {
  $$PeopleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'people__id__loans__person_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'people__id__expenses__person_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.personId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicinesTable, List<Medicine>>
  _medicinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicines,
    aliasName: 'people__id__medicines__profile_id',
  );

  $$MedicinesTableProcessedTableManager get medicinesRefs {
    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicinesRefs(
    Expression<bool> Function($$MedicinesTableFilterComposer f) f,
  ) {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isSelf =>
      $composableBuilder(column: $table.isSelf, builder: (column) => column);

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.personId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicinesRefs<T extends Object>(
    Expression<T> Function($$MedicinesTableAnnotationComposer a) f,
  ) {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          Person,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (Person, $$PeopleTableReferences),
          Person,
          PrefetchHooks Function({
            bool loansRefs,
            bool expensesRefs,
            bool medicinesRefs,
          })
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                name: name,
                relation: relation,
                color: color,
                type: type,
                isSelf: isSelf,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> relation = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                name: name,
                relation: relation,
                color: color,
                type: type,
                isSelf: isSelf,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PeopleTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                loansRefs = false,
                expensesRefs = false,
                medicinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (loansRefs) db.loans,
                    if (expensesRefs) db.expenses,
                    if (medicinesRefs) db.medicines,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (loansRefs)
                        await $_getPrefetchedData<Person, $PeopleTable, Loan>(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._loansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(db, table, p0).loansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Person,
                          $PeopleTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.personId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicinesRefs)
                        await $_getPrefetchedData<
                          Person,
                          $PeopleTable,
                          Medicine
                        >(
                          currentTable: table,
                          referencedTable: $$PeopleTableReferences
                              ._medicinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PeopleTableReferences(
                                db,
                                table,
                                p0,
                              ).medicinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      Person,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (Person, $$PeopleTableReferences),
      Person,
      PrefetchHooks Function({
        bool loansRefs,
        bool expensesRefs,
        bool medicinesRefs,
      })
    >;
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> type,
      Value<double> balance,
      Value<String> currency,
      Value<int> color,
      Value<bool> isArchived,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<double> balance,
      Value<String> currency,
      Value<int> color,
      Value<bool> isArchived,
    });

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, Account> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'accounts__id__expenses__account_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, $$AccountsTableReferences),
          Account,
          PrefetchHooks Function({bool expensesRefs})
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                balance: balance,
                currency: currency,
                color: color,
                isArchived: isArchived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> type = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                balance: balance,
                currency: currency,
                color: color,
                isArchived: isArchived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<Account, $AccountsTable, Expense>(
                      currentTable: table,
                      referencedTable: $$AccountsTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AccountsTableReferences(db, table, p0).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.accountId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, $$AccountsTableReferences),
      Account,
      PrefetchHooks Function({bool expensesRefs})
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> icon,
      Value<int> color,
      Value<int?> parentId,
      Value<bool> isIncome,
      Value<int> sortOrder,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> icon,
      Value<int> color,
      Value<int?> parentId,
      Value<bool> isIncome,
      Value<int> sortOrder,
    });

final class $$ExpenseCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategory
        > {
  $$ExpenseCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'expense_categories__id__expenses__category_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BudgetsTable, List<Budget>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: 'expense_categories__id__budgets__category_id',
  );

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager(
      $_db,
      $_db.budgets,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($$BudgetsTableFilterComposer f) f,
  ) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($$BudgetsTableAnnotationComposer a) f,
  ) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BudgetsTableAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategory,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (ExpenseCategory, $$ExpenseCategoriesTableReferences),
          ExpenseCategory,
          PrefetchHooks Function({bool expensesRefs, bool budgetsRefs})
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                parentId: parentId,
                isIncome: isIncome,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                parentId: parentId,
                isIncome: isIncome,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpenseCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false, budgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expensesRefs) db.expenses,
                if (budgetsRefs) db.budgets,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<
                      ExpenseCategory,
                      $ExpenseCategoriesTable,
                      Expense
                    >(
                      currentTable: table,
                      referencedTable: $$ExpenseCategoriesTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExpenseCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                  if (budgetsRefs)
                    await $_getPrefetchedData<
                      ExpenseCategory,
                      $ExpenseCategoriesTable,
                      Budget
                    >(
                      currentTable: table,
                      referencedTable: $$ExpenseCategoriesTableReferences
                          ._budgetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExpenseCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).budgetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategory,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (ExpenseCategory, $$ExpenseCategoriesTableReferences),
      ExpenseCategory,
      PrefetchHooks Function({bool expensesRefs, bool budgetsRefs})
    >;
typedef $$LoansTableCreateCompanionBuilder =
    LoansCompanion Function({
      Value<int> id,
      required int personId,
      Value<int> direction,
      required double principal,
      Value<String?> note,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime?> settledAt,
    });
typedef $$LoansTableUpdateCompanionBuilder =
    LoansCompanion Function({
      Value<int> id,
      Value<int> personId,
      Value<int> direction,
      Value<double> principal,
      Value<String?> note,
      Value<DateTime?> dueDate,
      Value<DateTime> createdAt,
      Value<DateTime?> settledAt,
    });

final class $$LoansTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTable, Loan> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('loans__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'loans__id__expenses__loan_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.loanId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.loanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.loanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTable,
          Loan,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (Loan, $$LoansTableReferences),
          Loan,
          PrefetchHooks Function({bool personId, bool expensesRefs})
        > {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<int> direction = const Value.absent(),
                Value<double> principal = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                personId: personId,
                direction: direction,
                principal: principal,
                note: note,
                dueDate: dueDate,
                createdAt: createdAt,
                settledAt: settledAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int personId,
                Value<int> direction = const Value.absent(),
                required double principal,
                Value<String?> note = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                personId: personId,
                direction: direction,
                principal: principal,
                note: note,
                dueDate: dueDate,
                createdAt: createdAt,
                settledAt: settledAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$LoansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({personId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (personId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.personId,
                                referencedTable: $$LoansTableReferences
                                    ._personIdTable(db),
                                referencedColumn: $$LoansTableReferences
                                    ._personIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<Loan, $LoansTable, Expense>(
                      currentTable: table,
                      referencedTable: $$LoansTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LoansTableReferences(db, table, p0).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.loanId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTable,
      Loan,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (Loan, $$LoansTableReferences),
      Loan,
      PrefetchHooks Function({bool personId, bool expensesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required double amount,
      Value<int?> categoryId,
      required int accountId,
      Value<int?> transferAccountId,
      Value<int> kind,
      required int personId,
      Value<int?> loanId,
      Value<String?> note,
      Value<String?> receiptPath,
      Value<DateTime> date,
      Value<DateTime> createdAt,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<int?> categoryId,
      Value<int> accountId,
      Value<int?> transferAccountId,
      Value<int> kind,
      Value<int> personId,
      Value<int?> loanId,
      Value<String?> note,
      Value<String?> receiptPath,
      Value<DateTime> date,
      Value<DateTime> createdAt,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExpenseCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('expenses__category_id__expense_categories__id');

  $$ExpenseCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('expenses__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PeopleTable _personIdTable(_$AppDatabase db) =>
      db.people.createAlias('expenses__person_id__people__id');

  $$PeopleTableProcessedTableManager get personId {
    final $_column = $_itemColumn<int>('person_id')!;

    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_personIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LoansTable _loanIdTable(_$AppDatabase db) =>
      db.loans.createAlias('expenses__loan_id__loans__id');

  $$LoansTableProcessedTableManager? get loanId {
    final $_column = $_itemColumn<int>('loan_id');
    if ($_column == null) return null;
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_loanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transferAccountId => $composableBuilder(
    column: $table.transferAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpenseCategoriesTableFilterComposer get categoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableFilterComposer get personId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LoansTableFilterComposer get loanId {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loanId,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transferAccountId => $composableBuilder(
    column: $table.transferAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpenseCategoriesTableOrderingComposer get categoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableOrderingComposer get personId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LoansTableOrderingComposer get loanId {
    final $$LoansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loanId,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableOrderingComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get transferAccountId => $composableBuilder(
    column: $table.transferAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ExpenseCategoriesTableAnnotationComposer get categoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PeopleTableAnnotationComposer get personId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.personId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LoansTableAnnotationComposer get loanId {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.loanId,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({
            bool categoryId,
            bool accountId,
            bool personId,
            bool loanId,
          })
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> transferAccountId = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<int> personId = const Value.absent(),
                Value<int?> loanId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                transferAccountId: transferAccountId,
                kind: kind,
                personId: personId,
                loanId: loanId,
                note: note,
                receiptPath: receiptPath,
                date: date,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                Value<int?> categoryId = const Value.absent(),
                required int accountId,
                Value<int?> transferAccountId = const Value.absent(),
                Value<int> kind = const Value.absent(),
                required int personId,
                Value<int?> loanId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                transferAccountId: transferAccountId,
                kind: kind,
                personId: personId,
                loanId: loanId,
                note: note,
                receiptPath: receiptPath,
                date: date,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                accountId = false,
                personId = false,
                loanId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ExpensesTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ExpensesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (accountId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.accountId,
                                    referencedTable: $$ExpensesTableReferences
                                        ._accountIdTable(db),
                                    referencedColumn: $$ExpensesTableReferences
                                        ._accountIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (personId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.personId,
                                    referencedTable: $$ExpensesTableReferences
                                        ._personIdTable(db),
                                    referencedColumn: $$ExpensesTableReferences
                                        ._personIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (loanId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.loanId,
                                    referencedTable: $$ExpensesTableReferences
                                        ._loanIdTable(db),
                                    referencedColumn: $$ExpensesTableReferences
                                        ._loanIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({
        bool categoryId,
        bool accountId,
        bool personId,
        bool loanId,
      })
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required double amount,
      Value<int?> categoryId,
      required DateTime monthStart,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<int?> categoryId,
      Value<DateTime> monthStart,
    });

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, Budget> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExpenseCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('budgets__category_id__expense_categories__id');

  $$ExpenseCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get monthStart => $composableBuilder(
    column: $table.monthStart,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpenseCategoriesTableFilterComposer get categoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get monthStart => $composableBuilder(
    column: $table.monthStart,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpenseCategoriesTableOrderingComposer get categoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get monthStart => $composableBuilder(
    column: $table.monthStart,
    builder: (column) => column,
  );

  $$ExpenseCategoriesTableAnnotationComposer get categoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, $$BudgetsTableReferences),
          Budget,
          PrefetchHooks Function({bool categoryId})
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<DateTime> monthStart = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                amount: amount,
                categoryId: categoryId,
                monthStart: monthStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                Value<int?> categoryId = const Value.absent(),
                required DateTime monthStart,
              }) => BudgetsCompanion.insert(
                id: id,
                amount: amount,
                categoryId: categoryId,
                monthStart: monthStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BudgetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$BudgetsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$BudgetsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, $$BudgetsTableReferences),
      Budget,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$RecurringExpensesTableCreateCompanionBuilder =
    RecurringExpensesCompanion Function({
      Value<int> id,
      required String name,
      required double amount,
      Value<int?> categoryId,
      Value<int?> accountId,
      Value<String> period,
      Value<int> dayOfPeriod,
      Value<bool> isSubscription,
      required DateTime nextDueDate,
      Value<bool> isActive,
    });
typedef $$RecurringExpensesTableUpdateCompanionBuilder =
    RecurringExpensesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> amount,
      Value<int?> categoryId,
      Value<int?> accountId,
      Value<String> period,
      Value<int> dayOfPeriod,
      Value<bool> isSubscription,
      Value<DateTime> nextDueDate,
      Value<bool> isActive,
    });

class $$RecurringExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfPeriod => $composableBuilder(
    column: $table.dayOfPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfPeriod => $composableBuilder(
    column: $table.dayOfPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get dayOfPeriod => $composableBuilder(
    column: $table.dayOfPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSubscription => $composableBuilder(
    column: $table.isSubscription,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$RecurringExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringExpensesTable,
          RecurringExpense,
          $$RecurringExpensesTableFilterComposer,
          $$RecurringExpensesTableOrderingComposer,
          $$RecurringExpensesTableAnnotationComposer,
          $$RecurringExpensesTableCreateCompanionBuilder,
          $$RecurringExpensesTableUpdateCompanionBuilder,
          (
            RecurringExpense,
            BaseReferences<
              _$AppDatabase,
              $RecurringExpensesTable,
              RecurringExpense
            >,
          ),
          RecurringExpense,
          PrefetchHooks Function()
        > {
  $$RecurringExpensesTableTableManager(
    _$AppDatabase db,
    $RecurringExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringExpensesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<int> dayOfPeriod = const Value.absent(),
                Value<bool> isSubscription = const Value.absent(),
                Value<DateTime> nextDueDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RecurringExpensesCompanion(
                id: id,
                name: name,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                period: period,
                dayOfPeriod: dayOfPeriod,
                isSubscription: isSubscription,
                nextDueDate: nextDueDate,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double amount,
                Value<int?> categoryId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<int> dayOfPeriod = const Value.absent(),
                Value<bool> isSubscription = const Value.absent(),
                required DateTime nextDueDate,
                Value<bool> isActive = const Value.absent(),
              }) => RecurringExpensesCompanion.insert(
                id: id,
                name: name,
                amount: amount,
                categoryId: categoryId,
                accountId: accountId,
                period: period,
                dayOfPeriod: dayOfPeriod,
                isSubscription: isSubscription,
                nextDueDate: nextDueDate,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringExpensesTable,
      RecurringExpense,
      $$RecurringExpensesTableFilterComposer,
      $$RecurringExpensesTableOrderingComposer,
      $$RecurringExpensesTableAnnotationComposer,
      $$RecurringExpensesTableCreateCompanionBuilder,
      $$RecurringExpensesTableUpdateCompanionBuilder,
      (
        RecurringExpense,
        BaseReferences<
          _$AppDatabase,
          $RecurringExpensesTable,
          RecurringExpense
        >,
      ),
      RecurringExpense,
      PrefetchHooks Function()
    >;
typedef $$MedicinesTableCreateCompanionBuilder =
    MedicinesCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      required String name,
      Value<String> form,
      Value<double> dosage,
      Value<String> dosageUnit,
      Value<int> inventory,
      Value<int> lowStockThreshold,
      Value<String?> doctorName,
      Value<String?> prescriptionPath,
      Value<String?> notes,
      Value<int> frequencyType,
      Value<String> doseTimes,
      Value<int> intervalHours,
      Value<int> weekdayMask,
      Value<String> mealRelation,
      required DateTime startDate,
      required DateTime endDate,
      Value<String> skipDates,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$MedicinesTableUpdateCompanionBuilder =
    MedicinesCompanion Function({
      Value<int> id,
      Value<int?> profileId,
      Value<String> name,
      Value<String> form,
      Value<double> dosage,
      Value<String> dosageUnit,
      Value<int> inventory,
      Value<int> lowStockThreshold,
      Value<String?> doctorName,
      Value<String?> prescriptionPath,
      Value<String?> notes,
      Value<int> frequencyType,
      Value<String> doseTimes,
      Value<int> intervalHours,
      Value<int> weekdayMask,
      Value<String> mealRelation,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<String> skipDates,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$MedicinesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicinesTable, Medicine> {
  $$MedicinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PeopleTable _profileIdTable(_$AppDatabase db) =>
      db.people.createAlias('medicines__profile_id__people__id');

  $$PeopleTableProcessedTableManager? get profileId {
    final $_column = $_itemColumn<int>('profile_id');
    if ($_column == null) return null;
    final manager = $$PeopleTableTableManager(
      $_db,
      $_db.people,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MedicineDosesTable, List<MedicineDose>>
  _medicineDosesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicineDoses,
    aliasName: 'medicines__id__medicine_doses__medicine_id',
  );

  $$MedicineDosesTableProcessedTableManager get medicineDosesRefs {
    final manager = $$MedicineDosesTableTableManager(
      $_db,
      $_db.medicineDoses,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicineDosesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosageUnit => $composableBuilder(
    column: $table.dosageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inventory => $composableBuilder(
    column: $table.inventory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriptionPath => $composableBuilder(
    column: $table.prescriptionPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseTimes => $composableBuilder(
    column: $table.doseTimes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalHours => $composableBuilder(
    column: $table.intervalHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipDates => $composableBuilder(
    column: $table.skipDates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PeopleTableFilterComposer get profileId {
    final $$PeopleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableFilterComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> medicineDosesRefs(
    Expression<bool> Function($$MedicineDosesTableFilterComposer f) f,
  ) {
    final $$MedicineDosesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicineDoses,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicineDosesTableFilterComposer(
            $db: $db,
            $table: $db.medicineDoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosageUnit => $composableBuilder(
    column: $table.dosageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inventory => $composableBuilder(
    column: $table.inventory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriptionPath => $composableBuilder(
    column: $table.prescriptionPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseTimes => $composableBuilder(
    column: $table.doseTimes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalHours => $composableBuilder(
    column: $table.intervalHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipDates => $composableBuilder(
    column: $table.skipDates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PeopleTableOrderingComposer get profileId {
    final $$PeopleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableOrderingComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<double> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get dosageUnit => $composableBuilder(
    column: $table.dosageUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inventory =>
      $composableBuilder(column: $table.inventory, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doctorName => $composableBuilder(
    column: $table.doctorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriptionPath => $composableBuilder(
    column: $table.prescriptionPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseTimes =>
      $composableBuilder(column: $table.doseTimes, builder: (column) => column);

  GeneratedColumn<int> get intervalHours => $composableBuilder(
    column: $table.intervalHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekdayMask => $composableBuilder(
    column: $table.weekdayMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealRelation => $composableBuilder(
    column: $table.mealRelation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get skipDates =>
      $composableBuilder(column: $table.skipDates, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PeopleTableAnnotationComposer get profileId {
    final $$PeopleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.people,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PeopleTableAnnotationComposer(
            $db: $db,
            $table: $db.people,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> medicineDosesRefs<T extends Object>(
    Expression<T> Function($$MedicineDosesTableAnnotationComposer a) f,
  ) {
    final $$MedicineDosesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicineDoses,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicineDosesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicineDoses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTable,
          Medicine,
          $$MedicinesTableFilterComposer,
          $$MedicinesTableOrderingComposer,
          $$MedicinesTableAnnotationComposer,
          $$MedicinesTableCreateCompanionBuilder,
          $$MedicinesTableUpdateCompanionBuilder,
          (Medicine, $$MedicinesTableReferences),
          Medicine,
          PrefetchHooks Function({bool profileId, bool medicineDosesRefs})
        > {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<double> dosage = const Value.absent(),
                Value<String> dosageUnit = const Value.absent(),
                Value<int> inventory = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<String?> prescriptionPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> frequencyType = const Value.absent(),
                Value<String> doseTimes = const Value.absent(),
                Value<int> intervalHours = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<String> mealRelation = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<String> skipDates = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                profileId: profileId,
                name: name,
                form: form,
                dosage: dosage,
                dosageUnit: dosageUnit,
                inventory: inventory,
                lowStockThreshold: lowStockThreshold,
                doctorName: doctorName,
                prescriptionPath: prescriptionPath,
                notes: notes,
                frequencyType: frequencyType,
                doseTimes: doseTimes,
                intervalHours: intervalHours,
                weekdayMask: weekdayMask,
                mealRelation: mealRelation,
                startDate: startDate,
                endDate: endDate,
                skipDates: skipDates,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                required String name,
                Value<String> form = const Value.absent(),
                Value<double> dosage = const Value.absent(),
                Value<String> dosageUnit = const Value.absent(),
                Value<int> inventory = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<String?> doctorName = const Value.absent(),
                Value<String?> prescriptionPath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> frequencyType = const Value.absent(),
                Value<String> doseTimes = const Value.absent(),
                Value<int> intervalHours = const Value.absent(),
                Value<int> weekdayMask = const Value.absent(),
                Value<String> mealRelation = const Value.absent(),
                required DateTime startDate,
                required DateTime endDate,
                Value<String> skipDates = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MedicinesCompanion.insert(
                id: id,
                profileId: profileId,
                name: name,
                form: form,
                dosage: dosage,
                dosageUnit: dosageUnit,
                inventory: inventory,
                lowStockThreshold: lowStockThreshold,
                doctorName: doctorName,
                prescriptionPath: prescriptionPath,
                notes: notes,
                frequencyType: frequencyType,
                doseTimes: doseTimes,
                intervalHours: intervalHours,
                weekdayMask: weekdayMask,
                mealRelation: mealRelation,
                startDate: startDate,
                endDate: endDate,
                skipDates: skipDates,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({profileId = false, medicineDosesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicineDosesRefs) db.medicineDoses,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (profileId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.profileId,
                                    referencedTable: $$MedicinesTableReferences
                                        ._profileIdTable(db),
                                    referencedColumn: $$MedicinesTableReferences
                                        ._profileIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicineDosesRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          MedicineDose
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._medicineDosesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicineDosesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTable,
      Medicine,
      $$MedicinesTableFilterComposer,
      $$MedicinesTableOrderingComposer,
      $$MedicinesTableAnnotationComposer,
      $$MedicinesTableCreateCompanionBuilder,
      $$MedicinesTableUpdateCompanionBuilder,
      (Medicine, $$MedicinesTableReferences),
      Medicine,
      PrefetchHooks Function({bool profileId, bool medicineDosesRefs})
    >;
typedef $$MedicineDosesTableCreateCompanionBuilder =
    MedicineDosesCompanion Function({
      Value<int> id,
      required int medicineId,
      required DateTime scheduledTime,
      Value<int> status,
      Value<DateTime?> actionedAt,
    });
typedef $$MedicineDosesTableUpdateCompanionBuilder =
    MedicineDosesCompanion Function({
      Value<int> id,
      Value<int> medicineId,
      Value<DateTime> scheduledTime,
      Value<int> status,
      Value<DateTime?> actionedAt,
    });

final class $$MedicineDosesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicineDosesTable, MedicineDose> {
  $$MedicineDosesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias('medicine_doses__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<int>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicineDosesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicineDosesTable> {
  $$MedicineDosesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actionedAt => $composableBuilder(
    column: $table.actionedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicineDosesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicineDosesTable> {
  $$MedicineDosesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actionedAt => $composableBuilder(
    column: $table.actionedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicineDosesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicineDosesTable> {
  $$MedicineDosesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get actionedAt => $composableBuilder(
    column: $table.actionedAt,
    builder: (column) => column,
  );

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicineDosesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicineDosesTable,
          MedicineDose,
          $$MedicineDosesTableFilterComposer,
          $$MedicineDosesTableOrderingComposer,
          $$MedicineDosesTableAnnotationComposer,
          $$MedicineDosesTableCreateCompanionBuilder,
          $$MedicineDosesTableUpdateCompanionBuilder,
          (MedicineDose, $$MedicineDosesTableReferences),
          MedicineDose,
          PrefetchHooks Function({bool medicineId})
        > {
  $$MedicineDosesTableTableManager(_$AppDatabase db, $MedicineDosesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicineDosesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicineDosesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicineDosesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicineId = const Value.absent(),
                Value<DateTime> scheduledTime = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime?> actionedAt = const Value.absent(),
              }) => MedicineDosesCompanion(
                id: id,
                medicineId: medicineId,
                scheduledTime: scheduledTime,
                status: status,
                actionedAt: actionedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicineId,
                required DateTime scheduledTime,
                Value<int> status = const Value.absent(),
                Value<DateTime?> actionedAt = const Value.absent(),
              }) => MedicineDosesCompanion.insert(
                id: id,
                medicineId: medicineId,
                scheduledTime: scheduledTime,
                status: status,
                actionedAt: actionedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicineDosesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicineId,
                                referencedTable: $$MedicineDosesTableReferences
                                    ._medicineIdTable(db),
                                referencedColumn: $$MedicineDosesTableReferences
                                    ._medicineIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MedicineDosesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicineDosesTable,
      MedicineDose,
      $$MedicineDosesTableFilterComposer,
      $$MedicineDosesTableOrderingComposer,
      $$MedicineDosesTableAnnotationComposer,
      $$MedicineDosesTableCreateCompanionBuilder,
      $$MedicineDosesTableUpdateCompanionBuilder,
      (MedicineDose, $$MedicineDosesTableReferences),
      MedicineDose,
      PrefetchHooks Function({bool medicineId})
    >;
typedef $$SymptomLogsTableCreateCompanionBuilder =
    SymptomLogsCompanion Function({
      Value<int> id,
      Value<int?> medicineId,
      Value<int?> profileId,
      Value<DateTime> date,
      required String symptom,
      Value<int> severity,
      Value<String?> note,
    });
typedef $$SymptomLogsTableUpdateCompanionBuilder =
    SymptomLogsCompanion Function({
      Value<int> id,
      Value<int?> medicineId,
      Value<int?> profileId,
      Value<DateTime> date,
      Value<String> symptom,
      Value<int> severity,
      Value<String?> note,
    });

class $$SymptomLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptom => $composableBuilder(
    column: $table.symptom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SymptomLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptom => $composableBuilder(
    column: $table.symptom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SymptomLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get medicineId => $composableBuilder(
    column: $table.medicineId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get symptom =>
      $composableBuilder(column: $table.symptom, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$SymptomLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SymptomLogsTable,
          SymptomLog,
          $$SymptomLogsTableFilterComposer,
          $$SymptomLogsTableOrderingComposer,
          $$SymptomLogsTableAnnotationComposer,
          $$SymptomLogsTableCreateCompanionBuilder,
          $$SymptomLogsTableUpdateCompanionBuilder,
          (
            SymptomLog,
            BaseReferences<_$AppDatabase, $SymptomLogsTable, SymptomLog>,
          ),
          SymptomLog,
          PrefetchHooks Function()
        > {
  $$SymptomLogsTableTableManager(_$AppDatabase db, $SymptomLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> medicineId = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> symptom = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => SymptomLogsCompanion(
                id: id,
                medicineId: medicineId,
                profileId: profileId,
                date: date,
                symptom: symptom,
                severity: severity,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> medicineId = const Value.absent(),
                Value<int?> profileId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                required String symptom,
                Value<int> severity = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => SymptomLogsCompanion.insert(
                id: id,
                medicineId: medicineId,
                profileId: profileId,
                date: date,
                symptom: symptom,
                severity: severity,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SymptomLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SymptomLogsTable,
      SymptomLog,
      $$SymptomLogsTableFilterComposer,
      $$SymptomLogsTableOrderingComposer,
      $$SymptomLogsTableAnnotationComposer,
      $$SymptomLogsTableCreateCompanionBuilder,
      $$SymptomLogsTableUpdateCompanionBuilder,
      (
        SymptomLog,
        BaseReferences<_$AppDatabase, $SymptomLogsTable, SymptomLog>,
      ),
      SymptomLog,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int> durationMinutes,
      Value<int> actualSeconds,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int?> taskId,
      Value<String?> note,
      Value<int?> rating,
      Value<String> mode,
      Value<bool> isBreak,
      Value<bool> isCompleted,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<int> durationMinutes,
      Value<int> actualSeconds,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int?> taskId,
      Value<String?> note,
      Value<int?> rating,
      Value<String> mode,
      Value<bool> isBreak,
      Value<bool> isCompleted,
    });

final class $$FocusSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession> {
  $$FocusSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('focus_sessions__task_id__tasks__id');

  $$TasksTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBreak => $composableBuilder(
    column: $table.isBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBreak => $composableBuilder(
    column: $table.isBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualSeconds => $composableBuilder(
    column: $table.actualSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get isBreak =>
      $composableBuilder(column: $table.isBreak, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (FocusSession, $$FocusSessionsTableReferences),
          FocusSession,
          PrefetchHooks Function({bool taskId})
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> isBreak = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                durationMinutes: durationMinutes,
                actualSeconds: actualSeconds,
                startTime: startTime,
                endTime: endTime,
                taskId: taskId,
                note: note,
                rating: rating,
                mode: mode,
                isBreak: isBreak,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> actualSeconds = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> isBreak = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                durationMinutes: durationMinutes,
                actualSeconds: actualSeconds,
                startTime: startTime,
                endTime: endTime,
                taskId: taskId,
                note: note,
                rating: rating,
                mode: mode,
                isBreak: isBreak,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FocusSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$FocusSessionsTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$FocusSessionsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (FocusSession, $$FocusSessionsTableReferences),
      FocusSession,
      PrefetchHooks Function({bool taskId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db, _db.taskTags);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringExpensesTableTableManager get recurringExpenses =>
      $$RecurringExpensesTableTableManager(_db, _db.recurringExpenses);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$MedicineDosesTableTableManager get medicineDoses =>
      $$MedicineDosesTableTableManager(_db, _db.medicineDoses);
  $$SymptomLogsTableTableManager get symptomLogs =>
      $$SymptomLogsTableTableManager(_db, _db.symptomLogs);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
}
