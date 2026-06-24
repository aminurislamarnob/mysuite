/// A completed focus (Pomodoro) session, optionally linked to a task.
class FocusSession {
  FocusSession({
    required this.id,
    required this.startedAt,
    required this.seconds,
    this.taskId,
    this.taskTitle,
    this.note = '',
    this.rating,
  });

  final String id;
  final DateTime startedAt;
  final int seconds;
  final String? taskId;
  final String? taskTitle;
  String note;
  int? rating;

  Duration get duration => Duration(seconds: seconds);

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'seconds': seconds,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'note': note,
        'rating': rating,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        seconds: json['seconds'] as int,
        taskId: json['taskId'] as String?,
        taskTitle: json['taskTitle'] as String?,
        note: json['note'] as String? ?? '',
        rating: json['rating'] as int?,
      );
}
