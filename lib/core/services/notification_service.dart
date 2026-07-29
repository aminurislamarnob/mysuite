import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../settings/app_settings.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

/// Notification id namespaces. Each module owns a disjoint integer range so a
/// module can cancel and reschedule its own reminders without touching others.
class _IdRange {
  static const medicine = 100000;
  static const task = 200000;
  static const habit = 300000;
  static const note = 400000;
  static const bill = 500000;
}

class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _medicineChannel = AndroidNotificationDetails(
    'medicine',
    'Medicine reminders',
    channelDescription: 'Dose reminders and refill alerts',
    importance: Importance.max,
    priority: Priority.high,
    category: AndroidNotificationCategory.alarm,
  );

  static const _defaultChannel = AndroidNotificationDetails(
    'general',
    'Reminders',
    channelDescription: 'Tasks, habits and notes',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    // The device's own zone is not exposed by dart:core, so schedules are
    // anchored to the local offset that `tz.local` resolves to at boot.
    tz.setLocalLocation(tz.getLocation(await _resolveTimeZoneName()));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(settings: settings);
      _ready = true;
    } on Exception catch (e) {
      // Leaving _ready false lets a later call retry once the platform side is
      // available, rather than permanently disabling reminders.
      debugPrint('Notification plugin unavailable: $e');
      rethrow;
    }
  }

  Future<String> _resolveTimeZoneName() async {
    // `DateTime.now().timeZoneName` gives an abbreviation which is ambiguous;
    // fall back to UTC offset matching against the tz database.
    final offset = DateTime.now().timeZoneOffset;
    for (final entry in tz.timeZoneDatabase.locations.entries) {
      final now = tz.TZDateTime.now(entry.value);
      if (now.timeZoneOffset == offset) return entry.key;
    }
    return 'UTC';
  }

  Future<bool> requestPermissions() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
    await android?.requestExactAlarmsPermission();
    return granted;
  }

  /// True when [when] falls inside the user's quiet hours. Medicine reminders
  /// ignore this: the spec marks them as a priority override.
  bool _inQuietHours(DateTime when) {
    final s = _ref.read(settingsProvider);
    if (!s.dndEnabled) return false;
    final minutes = when.hour * 60 + when.minute;
    final start = s.dndStartMinutes;
    final end = s.dndEndMinutes;
    // A window that wraps past midnight is expressed as start > end.
    return start <= end
        ? minutes >= start && minutes < end
        : minutes >= start || minutes < end;
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    bool isMedicine = false,
    String? payload,
  }) async {
    await init();
    if (when.isBefore(DateTime.now())) return;
    if (!isMedicine && _inQuietHours(when)) return;

    final details = NotificationDetails(
      android: isMedicine ? _medicineChannel : _defaultChannel,
      iOS: DarwinNotificationDetails(
        interruptionLevel: isMedicine
            ? InterruptionLevel.timeSensitive
            : InterruptionLevel.active,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } on PlatformException catch (e) {
      // Exact-alarm permission can be revoked at any time on Android 13+.
      // Degrade to an inexact alarm rather than losing the reminder.
      debugPrint('Exact schedule failed ($e); retrying inexact.');
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    }
  }

  Future<void> scheduleDose({
    required int doseId,
    required String medicineName,
    required String dosageLabel,
    required String mealHint,
    required DateTime when,
  }) {
    final body = mealHint.isEmpty
        ? dosageLabel
        : '$dosageLabel • $mealHint';
    return _schedule(
      id: _IdRange.medicine + doseId,
      title: 'Time for $medicineName',
      body: body,
      when: when,
      isMedicine: true,
      payload: 'dose:$doseId',
    );
  }

  Future<void> cancelDose(int doseId) =>
      _plugin.cancel(id: _IdRange.medicine + doseId);

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required DateTime when,
  }) {
    return _schedule(
      id: _IdRange.task + taskId,
      title: 'Task due',
      body: title,
      when: when,
      payload: 'task:$taskId',
    );
  }

  Future<void> cancelTaskReminder(int taskId) =>
      _plugin.cancel(id: _IdRange.task + taskId);

  /// Daily repeating nudge for a habit at [minutesFromMidnight].
  Future<void> scheduleHabitNudge({
    required int habitId,
    required String habitName,
    required int minutesFromMidnight,
  }) async {
    await init();
    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day,
        minutesFromMidnight ~/ 60, minutesFromMidnight % 60);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    if (_inQuietHours(when)) return;

    await _plugin.zonedSchedule(
      id: _IdRange.habit + habitId,
      title: habitName,
      body: 'Log today\'s progress',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: _defaultChannel,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'habit:$habitId',
    );
  }

  Future<void> cancelHabitNudge(int habitId) =>
      _plugin.cancel(id: _IdRange.habit + habitId);

  Future<void> scheduleNoteReminder({
    required int noteId,
    required String title,
    required DateTime when,
  }) {
    return _schedule(
      id: _IdRange.note + noteId,
      title: 'Note reminder',
      body: title,
      when: when,
      payload: 'note:$noteId',
    );
  }

  Future<void> cancelNoteReminder(int noteId) =>
      _plugin.cancel(id: _IdRange.note + noteId);

  Future<void> scheduleBillReminder({
    required int billId,
    required String name,
    required double amount,
    required String currency,
    required DateTime when,
  }) {
    return _schedule(
      id: _IdRange.bill + billId,
      title: '$name is due',
      body: '$currency${amount.toStringAsFixed(0)} due today',
      when: when,
      payload: 'bill:$billId',
    );
  }

  Future<void> cancelBillReminder(int billId) =>
      _plugin.cancel(id: _IdRange.bill + billId);

  /// Fires immediately; used for low-stock and budget-threshold alerts.
  Future<void> notifyNow({
    required int id,
    required String title,
    required String body,
    bool isMedicine = false,
  }) async {
    await init();
    if (!isMedicine && _inQuietHours(DateTime.now())) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: isMedicine ? _medicineChannel : _defaultChannel,
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
