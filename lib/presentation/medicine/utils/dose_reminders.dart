import '../../../core/services/notification_service.dart';
import '../repository/medicine_repository.dart';

/// Schedules notifications for a medicine's upcoming doses.
///
/// Only the near-term window is registered: both platforms cap how many
/// pending local notifications an app may hold, and a long course can easily
/// generate hundreds. Shared by the editor sheet and the assistant so a
/// spoken "add Napa" reminds exactly like a typed one.
Future<void> scheduleDoseReminders({
  required MedicineRepository repo,
  required NotificationService notifier,
  required int medicineId,
  required String name,
  required String dosageLabel,
  required String mealHint,
  DateTime? now,
}) async {
  final reference = now ?? DateTime.now();
  final horizon = reference.add(const Duration(days: 14));
  final doses = await repo.dosesFor(medicineId);

  final upcoming = doses
      .where(
        (d) =>
            d.scheduledTime.isAfter(reference) &&
            d.scheduledTime.isBefore(horizon),
      )
      .take(50);

  for (final dose in upcoming) {
    await notifier.scheduleDose(
      doseId: dose.id,
      medicineName: name,
      dosageLabel: dosageLabel,
      mealHint: mealHint,
      when: dose.scheduledTime,
    );
  }
}
