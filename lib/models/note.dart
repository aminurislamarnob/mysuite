/// A note. The MVP stores plain/markdown body text; the spec's rich text,
/// attachments and handwriting are Phase 2 and would extend [body]/attachments.
class Note {
  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.pinned = false,
    this.color,
  });

  final String id;
  String title;
  String body;
  DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;
  bool pinned;
  int? color;

  String get preview {
    final text = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text.length <= 120 ? text : '${text.substring(0, 120)}…';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
        'pinned': pinned,
        'color': color,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        pinned: json['pinned'] as bool? ?? false,
        color: json['color'] as int?,
      );
}
