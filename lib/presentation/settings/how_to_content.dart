import '../../core/settings/app_settings.dart';
import '../../core/theme/app_icons.dart';

/// One short guide to a part of the app.
///
/// A guide is a handful of steps, each an action and one sentence on what it
/// does, plus a few things worth knowing that do not fit a step. Every line
/// describes what the app actually does today; a feature that is planned but
/// not shipped has no business here.
class HowToGuide {
  /// Stable key, used to open the screen at this guide. A module's guide uses
  /// the module's name so the two can be matched without a lookup table.
  final String id;

  /// The short form for the jump strip, where "Privacy, lock and backups"
  /// would not fit on a pill.
  final String label;

  final String title;
  final HugeIconData icon;

  /// One line under the title, saying what the area is for.
  final String tagline;

  /// The module this guide covers, or null for one that spans the app.
  final AppModule? module;

  final List<HowToStep> steps;

  /// "Good to know": behaviour people would not guess from the screen.
  final List<String> tips;

  const HowToGuide({
    required this.id,
    required this.label,
    required this.title,
    required this.icon,
    required this.tagline,
    required this.steps,
    this.module,
    this.tips = const [],
  });
}

class HowToStep {
  /// What to do, in a few words: "Swipe to act".
  final String action;

  /// What happens, in one sentence.
  final String detail;

  const HowToStep(this.action, this.detail);
}

/// Every guide, in the order the screen shows them: a quick start, then one
/// per module in the order Settings lists them, then the parts of the app
/// that sit across the modules.
const howToGuides = <HowToGuide>[
  HowToGuide(
    id: 'start',
    label: 'Start',
    title: 'Quick start',
    icon: AppIcons.quick,
    tagline: 'Four things to know before anything else',
    steps: [
      HowToStep(
        'Tap + to add anything',
        'The centre button opens Quick add: a task, an expense, a habit log, '
            'a dose, a note, a transfer or a focus session.',
      ),
      HowToStep(
        'Hold + to say it instead',
        'Speak one sentence and the assistant sorts it into the right modules '
            'for you to check before anything is saved.',
      ),
      HowToStep(
        'Start your day on Today',
        'The first tab shows what needs you now, one card per module, each '
            'with an Open button.',
      ),
      HowToStep(
        'Keep only what you use',
        'Settings → Modules switches any module off. The Modules tab shows '
            'the rest as a grid; long-press a card there to switch it off too.',
      ),
    ],
    tips: [
      'Everything is stored on this device. Nothing leaves it unless you add '
          'an AI key, and then only the words you say.',
      'Appearance in Settings sets light or dark, the colour palette, text '
          'size, compact rows and reduced motion.',
    ],
  ),
  HowToGuide(
    id: 'notes',
    label: 'Notes',
    title: 'Notes',
    icon: AppIcons.notes,
    tagline: 'Write, organise and lock your notes',
    module: AppModule.notes,
    steps: [
      HowToStep(
        'Start from a template',
        'Tap + in Notes and pick Blank, Meeting notes, Journal, Daily log, '
            'Shopping list, Idea or Recipe.',
      ),
      HowToStep(
        'Write with formatting',
        'The toolbar has headings, checklists, quotes, code, dividers and '
            'links. A note saves itself when you leave it.',
      ),
      HowToStep(
        'File it in folders and tags',
        'The folder button lists All Notes, Favorites, Archive, Trash and your '
            'folders. Tags live in Note options, separated by commas.',
      ),
      HowToStep(
        'Long-press a note for more',
        'Pin it to the top, favourite it, archive it, lock it behind '
            'biometrics or a PIN, or move it to the trash.',
      ),
      HowToStep(
        'Turn a checklist into tasks',
        'Note options → Convert checklist to tasks sends every unchecked line '
            'to Tasks as its own task.',
      ),
    ],
    tips: [
      "Today's journal in the top bar opens one dated note per day, creating "
          'it the first time.',
      'Trash keeps a note for 30 days, then deletes it for good. Restore is '
          'a long-press away until then.',
      'Note options can also set a reminder, export the note as a PDF or '
          'share it as text.',
    ],
  ),
  HowToGuide(
    id: 'medicine',
    label: 'Medicine',
    title: 'Medicine',
    icon: AppIcons.medicine,
    tagline: 'Courses, dose times and adherence',
    module: AppModule.medicine,
    steps: [
      HowToStep(
        'Add a medicine',
        'Tap + in Medicine, name it, pick the form, dose and how often, then '
            'set the dose times. The whole course is generated for you.',
      ),
      HowToStep(
        'Or scan the prescription',
        'The scan button in the editor reads the name, strength, frequency '
            'and length from a photo, entirely on the device.',
      ),
      HowToStep(
        'Mark doses as they happen',
        'On Today, tap the circle to mark a dose taken. Long-press a dose to '
            'skip it.',
      ),
      HowToStep(
        'Watch the stock',
        'Every taken dose counts down what is in stock. The Medicines tab '
            'warns before you run out and has Add stock.',
      ),
      HowToStep(
        'Keep a profile per person',
        'The person button switches between household members, so each has '
            'their own schedule and adherence.',
      ),
    ],
    tips: [
      'Medicine reminders always ring, even inside quiet hours.',
      'Calendar, Timeline and Table show the same doses by day. Today shows '
          'adherence for today, this week and the last 30 days.',
      'Share schedule in the top bar exports this month as a PDF.',
    ],
  ),
  HowToGuide(
    id: 'habits',
    label: 'Habits',
    title: 'Habits',
    icon: AppIcons.habits,
    tagline: 'Build streaks or cut back, one tap a day',
    module: AppModule.habits,
    steps: [
      HowToStep(
        'Add a habit',
        'Tap + in Habits. Start from a preset such as Water or Exercise, or '
            'name your own with a daily goal and a unit.',
      ),
      HowToStep(
        'Build or Reduce',
        'Build counts up to a goal. Reduce sets a daily limit, and a day with '
            'nothing logged counts as a win.',
      ),
      HowToStep(
        'Log with one tap',
        'The + on a card adds one. Tap a day in the heatmap to enter an exact '
            'amount for that day.',
      ),
      HowToStep(
        'Choose the days',
        'Daily, weekdays or a number of times a week. Days off never break a '
            'streak.',
      ),
      HowToStep(
        'Read the stats',
        'Tap a card for streak, completion, this week, this month and cost. '
            'Long-press it to edit the habit.',
      ),
    ],
    tips: [
      'Add a cost or caffeine per unit and the screen totals what you spent '
          'and drank today.',
      'A daily reminder per habit is optional and stays quiet during quiet '
          'hours.',
      'From the Today tab, the + on a habit card logs one without leaving '
          'the dashboard.',
    ],
  ),
  HowToGuide(
    id: 'tasks',
    label: 'Tasks',
    title: 'Tasks',
    icon: AppIcons.tasks,
    tagline: 'Capture fast, plan in six views',
    module: AppModule.tasks,
    steps: [
      HowToStep(
        'Type it like you say it',
        'The quick-add box understands "Buy milk tomorrow 5pm #shopping '
            '!high": dates, times, weekdays, #tags, !priority and *daily '
            'repeats.',
      ),
      HowToStep(
        'Open the full editor',
        'Tap + for a description, priority P1 to P4, due date, reminder, '
            'repeat, time estimate, project and tags. Subtasks appear once a '
            'task is saved.',
      ),
      HowToStep(
        'Pick a view',
        'Today (with anything overdue), Upcoming, Inbox, Calendar, Kanban and '
            'Matrix show the same tasks in different ways.',
      ),
      HowToStep(
        'Swipe to act',
        'Swipe right to start a Focus session on the task. Swipe left to edit '
            'or delete it. Tap the circle to complete it.',
      ),
      HowToStep(
        'Group with projects',
        'The folder button filters by project and creates new ones. Quick '
            'adds land in the project you are viewing.',
      ),
    ],
    tips: [
      'Completing a repeating task schedules the next one automatically.',
      'In Kanban, long-press a card and drag it to Doing or Done.',
      'Matrix sorts by urgency (due within two days) and importance (P1 or '
          'P2).',
    ],
  ),
  HowToGuide(
    id: 'expenses',
    label: 'Expenses',
    title: 'Expenses',
    icon: AppIcons.expenses,
    tagline: 'Money in, money out, and who owes what',
    module: AppModule.expenses,
    steps: [
      HowToStep(
        'Record a transaction',
        'Tap + and choose Expense, Income or Transfer. Enter the amount, pick '
            'a category and account, and say who it was for.',
      ),
      HowToStep(
        'Set up your accounts',
        'Tap the accounts count on Overview to add Cash, Bank, Card, bKash, '
            'Nagad or Rocket, each with an opening balance.',
      ),
      HowToStep(
        'Cap what you spend',
        'Budgets sets a monthly limit per category or for the whole month, '
            'and shows what is not budgeted yet.',
      ),
      HowToStep(
        'Track bills and loans',
        'Bills remembers rent and subscriptions and reminds you on the due '
            'date; Pay books the expense. Loans tracks money lent and '
            'borrowed, with Repay.',
      ),
      HowToStep(
        'See where it went',
        'Reports breaks the month down by category, by person and over the '
            'last six months. Export gives you a CSV or a PDF.',
      ),
    ],
    tips: [
      'Swipe a transaction left to delete it. Undo is in the toast.',
      'The mic in the entry sheet takes "200 taka lunch with bKash" and '
          'fills the form.',
      'Scan receipt in the top bar pulls the total and merchant off a photo.',
      'Categories, under the More button in the top bar, lets you rename, '
          'recolour and reorder them.',
    ],
  ),
  HowToGuide(
    id: 'focus',
    label: 'Focus',
    title: 'Focus',
    icon: AppIcons.focus,
    tagline: 'Timed work sessions with breaks',
    module: AppModule.focus,
    steps: [
      HowToStep(
        'Pick a rhythm',
        'Pomodoro (25/5), 52/17, Deep work (90/20), Flow with no limit, '
            'Reverse, or a Custom length from 5 to 120 minutes.',
      ),
      HowToStep(
        'Press Start',
        'The ring counts down and flips to a break when the time is up. '
            'Pause, Reset or Finish whenever you like.',
      ),
      HowToStep(
        'Link a task',
        'Tap the task row to link one and the focused minutes are logged '
            'against it. Swiping a task right starts here already linked.',
      ),
      HowToStep(
        'Rate the session',
        'When you finish, note what you worked on and give it one to five '
            'stars.',
      ),
      HowToStep(
        'Set a daily goal',
        'The bar under the ring tracks minutes against your goal, 120 by '
            'default. Change goal sets another.',
      ),
      HowToStep(
        'Put a sound on',
        'Rain, Café, Forest, White, Brown or Ocean loops quietly while you '
            'work. Tap the same pill again to stop it.',
      ),
    ],
    tips: [
      'Stats shows today, this week, your streak, your best hour and a '
          'heatmap of focus days.',
      'A notification and a chime mark every break, so the phone can stay '
          'face down.',
      'Pomodoro gives a longer 15-minute break after every fourth interval.',
    ],
  ),
  HowToGuide(
    id: 'assistant',
    label: 'Assistant',
    title: 'Voice assistant',
    icon: AppIcons.sparkle,
    tagline: 'One sentence, several entries',
    steps: [
      HowToStep(
        'Hold + or tap the sparkle',
        'Either opens the assistant. Tap the mic and speak, or choose Type '
            'instead.',
      ),
      HowToStep(
        'Say it all at once',
        '"Spent 200 taka on lunch with bKash and remind me to call the doctor '
            'at 5" becomes an expense and a task with a reminder.',
      ),
      HowToStep(
        'Check the preview',
        'Each entry is a card. Tap one to adjust it in the module\'s own '
            'form; a warning marks anything that needs a look.',
      ),
      HowToStep(
        'Save all',
        'One tap writes every card into its module. Each saved row gets an '
            'Open button.',
      ),
      HowToStep(
        'Choose its brain',
        'Settings → AI assistant picks Claude, OpenAI, Gemini or DeepSeek '
            'with your own key. Without a key, a simpler offline parser '
            'handles it.',
      ),
    ],
    tips: [
      'Only your words and the names of your categories, accounts, people, '
          'habits and projects are sent to the provider.',
      'English and Banglish both work offline. Bangla script needs a '
          'provider.',
      'Auto-save without preview skips the check only when every entry '
          'resolved cleanly.',
    ],
  ),
  HowToGuide(
    id: 'home',
    label: 'Home',
    title: 'Today, Insights and search',
    icon: AppIcons.dashboard,
    tagline: 'The overview tabs, and finding anything',
    steps: [
      HowToStep(
        'Start on Today',
        'The banner shows the most pressing item, My plans counts what is '
            'left per module, and every card has Open.',
      ),
      HowToStep(
        'Act from a card',
        'Tick a task or tap + on a habit without leaving the dashboard.',
      ),
      HowToStep(
        'Read the weekly digest',
        'Insights sums up tasks, focus, money, adherence and habits, with '
            'heatmaps and your peak focus hour.',
      ),
      HowToStep(
        'Search everything',
        'The search button on Today looks across notes, tasks, habits, '
            'medicines, expenses and focus sessions. Type two letters or '
            'more, then filter by module.',
      ),
      HowToStep(
        'Open the reminders inbox',
        'The bell lists every upcoming dose, task, habit nudge, bill and '
            'loan by day. Tap one to jump to it.',
      ),
    ],
    tips: [
      'The activity chart shows seven days of focus minutes, tasks done or '
          'spending, whichever has data.',
      'Tap your avatar on Today to set your name and photo.',
    ],
  ),
  HowToGuide(
    id: 'reminders',
    label: 'Reminders',
    title: 'Reminders and quiet hours',
    icon: AppIcons.notificationsActive,
    tagline: 'What rings, when, and how to hush it',
    steps: [
      HowToStep(
        'Allow notifications once',
        'Settings → Notifications → Allow notifications. Nothing can ring '
            'until the system permission is granted.',
      ),
      HowToStep(
        'Set the reminder where it belongs',
        'Dose times in Medicine, a reminder on a task or note, a daily nudge '
            'on a habit, and due dates on bills and loans.',
      ),
      HowToStep(
        'Set quiet hours',
        'Turn on Quiet hours and pick From and To. Reminders that fall inside '
            'that window are skipped, except medicine.',
      ),
      HowToStep(
        'Tap a notification',
        'It opens the module it came from, so you land on the dose, task or '
            'bill it is about.',
      ),
    ],
    tips: [
      'Bills and loans remind at 9:00 on the morning they fall due.',
      'Settings → About → Clear all scheduled reminders silences everything '
          'until the next launch, when anything still due is scheduled '
          'again.',
    ],
  ),
  HowToGuide(
    id: 'people',
    label: 'People',
    title: 'People',
    icon: AppIcons.people,
    tagline: 'Household and contacts, shared by every module',
    steps: [
      HowToStep(
        'Add your household',
        'Settings → People → Add person. Household members get their own '
            'medicine profile and can be who an expense was for.',
      ),
      HowToStep(
        'Add contacts for loans',
        'Contacts are who you lend to or borrow from. Loans shows what each '
            'one owes or is owed.',
      ),
      HowToStep(
        'Give each a colour and photo',
        'The colour marks their records everywhere; a photo replaces the '
            'initials.',
      ),
      HowToStep(
        'You are the first row',
        'The profile card at the top of Settings is you. Rename it any time; '
            'it cannot be deleted.',
      ),
    ],
    tips: [
      'Deleting a person moves their records to you rather than losing them.',
      'The assistant matches spoken names against this list, so spell them '
          'the way you say them.',
    ],
  ),
  HowToGuide(
    id: 'security',
    label: 'Security',
    title: 'Privacy, lock and backups',
    icon: AppIcons.privacy,
    tagline: 'Keep it private and keep a copy',
    steps: [
      HowToStep(
        'Lock the app',
        'Settings → Security → Lock the app asks for biometrics or a PIN on '
            'launch. Auto-lock after sets how long it may sit in the '
            'background first.',
      ),
      HowToStep(
        'Set a PIN',
        'At least four digits, as the fallback when biometrics are not '
            'available. Change or remove it from the same row.',
      ),
      HowToStep(
        'Lock single modules',
        'Lock individual modules asks again before opening, say, Expenses, '
            'while everything else stays open.',
      ),
      HowToStep(
        'Export your data',
        'Settings → Data shares a full JSON backup, or a CSV of tasks, '
            'transactions, medicine or habits, through the system share '
            'sheet.',
      ),
      HowToStep(
        'Put a backup back',
        'Restore from a backup takes a full JSON backup and replaces '
            'everything on this device with it. Your photos come back too.',
      ),
    ],
    tips: [
      'There is no account and no sync, so a backup is the only way to move '
          'to a new phone. Take one before you switch.',
      'A restore cannot be undone, and it replaces your data rather than '
          'merging with it.',
      'An AI key, if you add one, lives in the platform keychain, never in '
          'plain settings.',
    ],
  ),
];
