import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../repository/medicine_repository.dart';
import '../utils/schedule_generator.dart';

/// The caregiver profile currently being viewed.
final activeProfileProvider = StateProvider<int?>((ref) => null);

final profilesProvider = StreamProvider<List<MedicineProfile>>((ref) {
  return ref.watch(medicineRepositoryProvider).watchProfiles();
});

final medicinesProvider = StreamProvider<List<Medicine>>((ref) {
  return ref
      .watch(medicineRepositoryProvider)
      .watchMedicines(profileId: ref.watch(activeProfileProvider));
});

final todayDosesProvider = StreamProvider<List<MedicineDose>>((ref) {
  return ref.watch(medicineRepositoryProvider).watchTodayDoses();
});

final medicineByIdProvider = FutureProvider.family<Medicine?, int>((ref, id) {
  return ref.watch(medicineRepositoryProvider).getMedicine(id);
});

/// A dose joined to its medicine, which is what every schedule view renders.
@immutable
class DoseView {
  final MedicineDose dose;
  final Medicine medicine;

  const DoseView({required this.dose, required this.medicine});

  DateTime get at => dose.scheduledTime;
  int get status => dose.status;

  String get dosageLabel =>
      '${trimAmount(medicine.dosage)} ${medicine.dosageUnit}';

  String get mealLabel => MealRelationX.fromToken(medicine.mealRelation).label;

  /// Renders a dose amount without a trailing ".0".
  static String trimAmount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

/// Joins doses to medicines, filtered to the active profile.
Stream<List<DoseView>> _joinDoses(
  Ref ref,
  Stream<List<MedicineDose>> doses,
) async* {
  final repo = ref.watch(medicineRepositoryProvider);
  final profileId = ref.watch(activeProfileProvider);

  await for (final list in doses) {
    final meds = {for (final m in await repo.medicines()) m.id: m};
    yield list
        .map((d) {
          final med = meds[d.medicineId];
          return med == null ? null : DoseView(dose: d, medicine: med);
        })
        .whereType<DoseView>()
        .where((v) => profileId == null || v.medicine.profileId == profileId)
        .toList();
  }
}

final todayDoseViewsProvider = StreamProvider<List<DoseView>>((ref) {
  return _joinDoses(
    ref,
    ref.watch(medicineRepositoryProvider).watchTodayDoses(),
  );
});

/// The month currently shown in the schedule views.
final scheduleMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

final monthDoseViewsProvider = StreamProvider<List<DoseView>>((ref) {
  final month = ref.watch(scheduleMonthProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);
  return _joinDoses(
    ref,
    ref.watch(medicineRepositoryProvider).watchDosesBetween(start, end),
  );
});

/// Month doses grouped by calendar day, for the grid and table views.
final monthDosesByDayProvider = Provider<Map<DateTime, List<DoseView>>>((ref) {
  final views = ref.watch(monthDoseViewsProvider).valueOrNull ?? const [];
  final grouped = <DateTime, List<DoseView>>{};
  for (final v in views) {
    grouped.putIfAbsent(Fmt.dateOnly(v.at), () => []).add(v);
  }
  return grouped;
});

/// Adherence over a trailing window, plus the weekday it slips most often.
@immutable
class AdherenceStats {
  final double daily;
  final double weekly;
  final double monthly;
  final Map<int, int> missesByWeekday;

  const AdherenceStats({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.missesByWeekday,
  });

  /// The weekday (1 = Monday) with the most misses, or null when there are none.
  int? get worstWeekday {
    if (missesByWeekday.isEmpty) return null;
    final sorted = missesByWeekday.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  int get totalMisses => missesByWeekday.values.fold(0, (a, b) => a + b);
}

final adherenceProvider = FutureProvider<AdherenceStats>((ref) async {
  final repo = ref.watch(medicineRepositoryProvider);
  // Recompute whenever a dose is marked.
  ref.watch(todayDosesProvider);

  final today = Fmt.dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  return AdherenceStats(
    daily: await repo.adherence(today, tomorrow),
    weekly: await repo.adherence(
      today.subtract(const Duration(days: 6)),
      tomorrow,
    ),
    monthly: await repo.adherence(
      today.subtract(const Duration(days: 29)),
      tomorrow,
    ),
    missesByWeekday: await repo.missesByWeekday(
      today.subtract(const Duration(days: 29)),
      tomorrow,
    ),
  );
});

/// Medicines at or under their low-stock threshold.
final lowStockProvider = Provider<List<Medicine>>((ref) {
  final meds = ref.watch(medicinesProvider).valueOrNull ?? const [];
  return meds.where((m) => m.inventory <= m.lowStockThreshold).toList();
});

/// Forecast of when each active medicine runs out.
final runOutForecastProvider =
    Provider<List<({Medicine medicine, DateTime? date})>>((ref) {
      final meds = ref.watch(medicinesProvider).valueOrNull ?? const [];
      return meds.where((m) => m.isActive).map((m) {
        final spec = MedicineRepository.specOf(m);
        // Only the remainder of the course matters for the forecast.
        final remaining = ScheduleSpec(
          start: DateTime.now().isAfter(spec.start)
              ? DateTime.now()
              : spec.start,
          end: spec.end,
          frequency: spec.frequency,
          doseMinutes: spec.doseMinutes,
          intervalHours: spec.intervalHours,
          weekdayMask: spec.weekdayMask,
          skipDates: spec.skipDates,
        );
        return (
          medicine: m,
          date: ScheduleGenerator.runOutDate(remaining, m.inventory, m.dosage),
        );
      }).toList();
    });

/// Doses of different medicines scheduled close together.
final conflictsProvider = Provider<List<DoseConflict>>((ref) {
  final views = ref.watch(monthDoseViewsProvider).valueOrNull ?? const [];
  final byMedicine = <String, List<DateTime>>{};
  for (final v in views) {
    byMedicine.putIfAbsent(v.medicine.name, () => []).add(v.at);
  }
  return ScheduleGenerator.findConflicts(byMedicine);
});

final symptomsProvider = StreamProvider<List<SymptomLog>>((ref) {
  return ref.watch(medicineRepositoryProvider).watchSymptoms();
});
