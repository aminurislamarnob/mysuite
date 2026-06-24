import '../core/utils/formatters.dart';

/// Priority levels P1 (urgent) → P4 (someday) from the spec.
enum Priority { p1, p2, p3, p4 }

extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.p1 => 'P1',
        Priority.p2 => 'P2',
        Priority.p3 => 'P3',
        Priority.p4 => 'P4',
      };

  /// 0xAARRGGBB accent per priority — red (urgent) → slate (someday).
  int get color => switch (this) {
        Priority.p1 => 0xFFEF4444,
        Priority.p2 => 0xFFF59E0B,
        Priority.p3 => 0xFF5B6CFF,
        Priority.p4 => 0xFF64748B,
      };
}

class Subtask {
  Subtask({required this.title, this.done = false});
  String title;
  bool done;

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
  factory Subtask.fromJson(Map<String, dynamic> j) =>
      Subtask(title: j['title'] as String, done: j['done'] as bool? ?? false);
}

class Task {
  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.due,
    this.priority = Priority.p3,
    this.project = 'Inbox',
    this.tags = const [],
    this.done = false,
    this.completedAt,
    this.focusedSeconds = 0,
    List<Subtask>? subtasks,
  }) : subtasks = subtasks ?? [];

  final String id;
  String title;
  String notes;
  DateTime? due;
  Priority priority;
  String project;
  List<String> tags;
  bool done;
  DateTime? completedAt;
  int focusedSeconds;
  List<Subtask> subtasks;

  bool get isOverdue =>
      !done && due != null && Day.only(due!).isBefore(Day.today());

  bool get isDueToday => due != null && Day.same(due!, DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'due': due?.toIso8601String(),
        'priority': priority.name,
        'project': project,
        'tags': tags,
        'done': done,
        'completedAt': completedAt?.toIso8601String(),
        'focusedSeconds': focusedSeconds,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String? ?? '',
        due: json['due'] != null ? DateTime.parse(json['due'] as String) : null,
        priority: Priority.values.byName(json['priority'] as String? ?? 'p3'),
        project: json['project'] as String? ?? 'Inbox',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        done: json['done'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        focusedSeconds: json['focusedSeconds'] as int? ?? 0,
        subtasks: (json['subtasks'] as List?)
                ?.map((e) => Subtask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
