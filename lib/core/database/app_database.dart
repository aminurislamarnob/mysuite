import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Notes
// ---------------------------------------------------------------------------

class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get parentId => integer().nullable().references(Folders, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Untitled'))();
  TextColumn get content => text()(); // Quill Delta JSON
  TextColumn get plainText =>
      text().withDefault(const Constant(''))(); // for search
  IntColumn get folderId => integer().nullable().references(Folders, #id)();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();

  /// Set when the note is moved to trash; purged 30 days later.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Marks a note created by journal mode, keyed to a single calendar day.
  DateTimeColumn get journalDate => dateTime().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer().withDefault(const Constant(0xFF6C6C6C))();
}

class NoteTags extends Table {
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

// ---------------------------------------------------------------------------
// Tasks
// ---------------------------------------------------------------------------

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFF5B7CE0))();
  TextColumn get icon => text().withDefault(const Constant('folder'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();

  /// True when [dueDate] carries a meaningful time-of-day, false for all-day.
  BoolColumn get hasDueTime => boolean().withDefault(const Constant(false))();
  DateTimeColumn get reminderTime => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(4))(); // 1=P1
  IntColumn get projectId => integer().nullable().references(
    Projects,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Parent task for subtasks; null for top-level tasks.
  IntColumn get parentTaskId => integer().nullable()();

  /// Simple recurrence token: daily | weekly | monthly | yearly | weekdays
  TextColumn get recurrenceRule => text().nullable()();

  /// Kanban column: 0=To Do, 1=Doing, 2=Done
  IntColumn get boardStatus => integer().withDefault(const Constant(0))();

  /// Minutes estimated, used by the Focus timer bridge.
  IntColumn get estimateMinutes => integer().nullable()();

  /// Minutes actually focused against this task.
  IntColumn get loggedMinutes => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class TaskTags extends Table {
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

// ---------------------------------------------------------------------------
// Habits
// ---------------------------------------------------------------------------

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('coffee'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF3BB273))();
  TextColumn get unit => text().nullable()(); // cups, ml, minutes, pages
  /// 0 = build (do more), 1 = reduce (do less / stay under target)
  IntColumn get goalType => integer().withDefault(const Constant(0))();
  RealColumn get targetAmount => real().withDefault(const Constant(1.0))();

  /// 0 = daily, 1 = specific weekdays, 2 = X times per week
  IntColumn get frequencyType => integer().withDefault(const Constant(0))();

  /// Bitmask, bit 0 = Monday … bit 6 = Sunday. Used when frequencyType == 1.
  IntColumn get weekdayMask => integer().withDefault(const Constant(127))();

  /// Used when frequencyType == 2.
  IntColumn get timesPerWeek => integer().withDefault(const Constant(7))();

  /// Optional per-unit cost, flows into the Expense module.
  RealColumn get costPerUnit => real().nullable()();

  /// Optional per-unit caffeine in mg, used for the daily estimate.
  RealColumn get caffeineMgPerUnit => real().nullable()();

  /// Minutes from midnight for the daily nudge; null disables it.
  IntColumn get reminderMinutes => integer().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();

  /// Date-only (midnight local) so a day has at most one row per habit.
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real().withDefault(const Constant(1.0))();
  TextColumn get note => text().nullable()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, date},
  ];
}

// ---------------------------------------------------------------------------
// People
// ---------------------------------------------------------------------------

/// Everyone the app knows about: the household (medicine profiles, who an
/// expense was for) and contacts (loan counterparties).
@DataClassName('Person')
class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get relation => text().withDefault(const Constant('Self'))();
  IntColumn get color => integer().withDefault(const Constant(0xFFFF6547))();

  /// household | contact
  TextColumn get type => text().withDefault(const Constant('household'))();

  /// The seeded row for the user, which every module falls back to and no
  /// screen may delete.
  BoolColumn get isSelf => boolean().withDefault(const Constant(false))();

  /// An avatar under the app's documents directory, written by `AvatarStorage`.
  /// Null until one is chosen.
  TextColumn get photoPath => text().nullable()();
}

// ---------------------------------------------------------------------------
// Expenses
// ---------------------------------------------------------------------------

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// cash | bank | card | bkash | nagad | rocket | other
  TextColumn get type => text().withDefault(const Constant('cash'))();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('BDT'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF9A6DD7))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class ExpenseCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('shopping_bag'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF9A6DD7))();
  IntColumn get parentId => integer().nullable()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Money lent to or borrowed from a person. The principal and every
/// repayment are real [Expenses] rows tagged with the loan's id, so account
/// balances stay truthful; what is still owed is derived from those rows.
class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(People, #id)();

  /// 0 = lent (they owe me), 1 = borrowed (I owe them)
  IntColumn get direction => integer().withDefault(const Constant(0))();
  RealColumn get principal => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Set the moment repayments cover the principal; cleared if one is undone.
  DateTimeColumn get settledAt => dateTime().nullable()();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().nullable().references(
    ExpenseCategories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get accountId =>
      integer().references(Accounts, #id, onDelete: KeyAction.cascade)();

  /// Destination account for transfers; null for ordinary income/expense.
  IntColumn get transferAccountId => integer().nullable()();

  /// 0 = expense, 1 = income, 2 = transfer, 3 = lend, 4 = borrow,
  /// 5 = loan repayment. Only 0 and 1 count as spending or earning.
  IntColumn get kind => integer().withDefault(const Constant(0))();

  /// Who the money was for. Never null: the repository falls back to Self.
  IntColumn get personId => integer().references(People, #id)();

  /// Set on the principal and every repayment of a loan.
  IntColumn get loanId => integer().nullable().references(
    Loans,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get note => text().nullable()();
  TextColumn get receiptPath => text().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// One cap per category per month; a month with no rows has no budget.
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();

  /// null = overall budget across every category
  IntColumn get categoryId => integer().nullable().references(
    ExpenseCategories,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Midnight on the first day of the month the cap applies to.
  DateTimeColumn get monthStart => dateTime()();
  // SQLite treats NULLs as distinct, so the overall budget's uniqueness is
  // the repository's job.
  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId, monthStart},
  ];
}

/// Recurring bills and subscriptions.
class RecurringExpenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get accountId => integer().nullable()();

  /// daily | weekly | monthly | yearly
  TextColumn get period => text().withDefault(const Constant('monthly'))();

  /// Day of month (monthly) or weekday 1-7 (weekly).
  IntColumn get dayOfPeriod => integer().withDefault(const Constant(1))();
  BoolColumn get isSubscription =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

// ---------------------------------------------------------------------------
// Medicine
// ---------------------------------------------------------------------------

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The household member this course belongs to.
  IntColumn get profileId => integer().nullable().references(
    People,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get name => text()();

  /// tablet | capsule | syrup | injection | drops | inhaler
  TextColumn get form => text().withDefault(const Constant('tablet'))();
  RealColumn get dosage => real().withDefault(const Constant(1.0))();
  TextColumn get dosageUnit => text().withDefault(const Constant('tablet'))();
  IntColumn get inventory => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThreshold =>
      integer().withDefault(const Constant(10))();
  TextColumn get doctorName => text().nullable()();
  TextColumn get prescriptionPath => text().nullable()();
  TextColumn get notes => text().nullable()();

  // --- Scheduling ---
  /// 0 = N times per day, 1 = every X hours, 2 = specific weekdays,
  /// 3 = alternate days
  IntColumn get frequencyType => integer().withDefault(const Constant(0))();

  /// Comma-separated minutes-from-midnight, e.g. "480,840,1200".
  TextColumn get doseTimes => text().withDefault(const Constant('480'))();
  IntColumn get intervalHours => integer().withDefault(const Constant(8))();
  IntColumn get weekdayMask => integer().withDefault(const Constant(127))();

  /// none | before | after | with
  TextColumn get mealRelation => text().withDefault(const Constant('none'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();

  /// Comma-separated yyyy-MM-dd dates to skip (travel/holiday mode).
  TextColumn get skipDates => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class MedicineDoses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicineId =>
      integer().references(Medicines, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get scheduledTime => dateTime()();

  /// 0 = pending, 1 = taken, 2 = skipped
  IntColumn get status => integer().withDefault(const Constant(0))();
  DateTimeColumn get actionedAt => dateTime().nullable()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {medicineId, scheduledTime},
  ];
}

class SymptomLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicineId => integer().nullable()();
  IntColumn get profileId => integer().nullable()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get symptom => text()();

  /// 1 (mild) … 5 (severe)
  IntColumn get severity => integer().withDefault(const Constant(1))();
  TextColumn get note => text().nullable()();
}

// ---------------------------------------------------------------------------
// Focus
// ---------------------------------------------------------------------------

class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(25))();

  /// Seconds actually focused, which can differ if the user stops early.
  IntColumn get actualSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get taskId => integer().nullable().references(
    Tasks,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get note => text().nullable()();

  /// Self-rated focus quality, 1-5.
  IntColumn get rating => integer().nullable()();

  /// pomodoro | 52-17 | deep | flow | reverse | custom
  TextColumn get mode => text().withDefault(const Constant('pomodoro'))();

  /// False for break intervals so they are excluded from focus totals.
  BoolColumn get isBreak => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Folders,
    Notes,
    Tags,
    NoteTags,
    Projects,
    Tasks,
    TaskTags,
    Habits,
    HabitLogs,
    People,
    Accounts,
    ExpenseCategories,
    Expenses,
    Budgets,
    RecurringExpenses,
    Loans,
    Medicines,
    MedicineDoses,
    SymptomLogs,
    FocusSessions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Each future schema bump appends its own `if (from < n)` block here.
      if (from < 2) {
        await m.addColumn(people, people.photoPath);
        // Self used to be seeded under the literal name 'Self'. Blanking it
        // here means an empty name says "never named" everywhere, rather than
        // every screen having to know the seed's string — and having to nag
        // anyone who genuinely calls themselves that.
        await (update(people)..where((t) => t.isSelf & t.name.equals('Self')))
            .write(const PeopleCompanion(name: Value('')));
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await _seedDefaults();
      }
    },
  );

  /// Seeds the rows the app assumes exist so no screen has to special-case an
  /// empty database on first launch.
  Future<void> _seedDefaults() async {
    await batch((b) {
      b.insertAll(accounts, const [
        AccountsCompanion(
          name: Value('Cash'),
          type: Value('cash'),
          color: Value(0xFF3BB273),
        ),
        AccountsCompanion(
          name: Value('bKash'),
          type: Value('bkash'),
          color: Value(0xFFE2136E),
        ),
        AccountsCompanion(
          name: Value('Nagad'),
          type: Value('nagad'),
          color: Value(0xFFEE7623),
        ),
        AccountsCompanion(
          name: Value('Bank'),
          type: Value('bank'),
          color: Value(0xFF5B7CE0),
        ),
      ]);
      b.insertAll(expenseCategories, const [
        ExpenseCategoriesCompanion(
          name: Value('Food'),
          icon: Value('food'),
          color: Value(0xFFE5484D),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Transport'),
          icon: Value('transport'),
          color: Value(0xFF5B7CE0),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Bills'),
          icon: Value('bills'),
          color: Value(0xFFF2A03D),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Groceries'),
          icon: Value('groceries'),
          color: Value(0xFF3BB273),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Entertainment'),
          icon: Value('entertainment'),
          color: Value(0xFF9A6DD7),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Health'),
          icon: Value('health'),
          color: Value(0xFFEC4899),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Education'),
          icon: Value('education'),
          color: Value(0xFF3AAFB9),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Shopping'),
          icon: Value('shopping'),
          color: Value(0xFFF97316),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Family'),
          icon: Value('family'),
          color: Value(0xFF14B8A6),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Other'),
          icon: Value('other'),
          color: Value(0xFF6C6C6C),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Salary'),
          icon: Value('salary'),
          color: Value(0xFF3BB273),
          isIncome: Value(true),
        ),
        ExpenseCategoriesCompanion(
          name: Value('Freelance'),
          icon: Value('freelance'),
          color: Value(0xFF3BB273),
          isIncome: Value(true),
        ),
      ]);
      b.insert(
        people,
        const PeopleCompanion(
          // Left empty on purpose: onboarding asks for it, and an empty name
          // is what the profile card watches for.
          name: Value(''),
          relation: Value('Self'),
          isSelf: Value(true),
        ),
      );
      b.insertAll(projects, const [
        ProjectsCompanion(
          name: Value('Inbox'),
          icon: Value('inbox'),
          color: Value(0xFF6C6C6C),
        ),
        ProjectsCompanion(
          name: Value('Personal'),
          icon: Value('home'),
          color: Value(0xFF3BB273),
        ),
        ProjectsCompanion(
          name: Value('Work'),
          icon: Value('work'),
          color: Value(0xFF5B7CE0),
        ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mysuite.sqlite'));
    sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
    return NativeDatabase.createInBackground(file);
  });
}
