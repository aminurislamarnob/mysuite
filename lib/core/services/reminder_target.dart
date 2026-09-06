/// Where a tapped reminder should take the user.
///
/// Every scheduled notification carries a `kind:id` payload. The kinds are
/// the ones [NotificationService] writes; anything else, and any payload
/// without a usable id, resolves to nothing so a stray tap is a no-op rather
/// than a crash.
class ReminderTarget {
  const ReminderTarget(this.route, {this.extra});

  /// A go_router location, always outside the tab shell.
  final String route;

  /// What the route's builder reads from `state.extra`, if anything.
  final Object? extra;

  static ReminderTarget? parse(String? payload) {
    if (payload == null) return null;
    final colon = payload.indexOf(':');
    if (colon <= 0) return null;
    final kind = payload.substring(0, colon);
    final id = int.tryParse(payload.substring(colon + 1));
    if (id == null) return null;
    return switch (kind) {
      'dose' => const ReminderTarget('/medicine'),
      'task' => const ReminderTarget('/tasks'),
      'habit' => const ReminderTarget('/habits'),
      'note' => ReminderTarget('/note_editor', extra: id),
      'bill' || 'loan' => const ReminderTarget('/expenses'),
      _ => null,
    };
  }
}
