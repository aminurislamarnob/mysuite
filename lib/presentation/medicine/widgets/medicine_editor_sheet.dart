import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand.dart';
import '../../../core/widgets/common.dart';
import '../camera_scan_screen.dart';
import '../providers/medicine_provider.dart';
import '../repository/medicine_repository.dart';
import '../utils/schedule_generator.dart';

/// Create/edit a medicine and preview the generated course before saving.
class MedicineEditorSheet extends ConsumerStatefulWidget {
  final Medicine? medicine;
  const MedicineEditorSheet({super.key, this.medicine});

  static Future<void> show(BuildContext context, {Medicine? medicine}) {
    return brandSheet(
      context: context,
      builder: (_) => MedicineEditorSheet(medicine: medicine),
    );
  }

  @override
  ConsumerState<MedicineEditorSheet> createState() =>
      _MedicineEditorSheetState();
}

class _MedicineEditorSheetState extends ConsumerState<MedicineEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _dosage;
  late final TextEditingController _dosageUnit;
  late final TextEditingController _inventory;
  late final TextEditingController _doctor;
  late final TextEditingController _notes;

  String _form = 'tablet';
  MedFrequency _frequency = MedFrequency.timesPerDay;
  List<int> _times = [480]; // 08:00
  int _intervalHours = 8;
  int _weekdayMask = 127;
  MealRelation _meal = MealRelation.none;
  DateTime _start = Fmt.dateOnly(DateTime.now());
  DateTime _end = Fmt.dateOnly(DateTime.now()).add(const Duration(days: 6));
  Set<DateTime> _skip = {};
  int? _profileId;

  bool get _isEditing => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _name = TextEditingController(text: m?.name ?? '');
    _dosage = TextEditingController(text: m == null ? '1' : _trim(m.dosage));
    _dosageUnit = TextEditingController(text: m?.dosageUnit ?? 'tablet');
    _inventory = TextEditingController(text: '${m?.inventory ?? 0}');
    _doctor = TextEditingController(text: m?.doctorName ?? '');
    _notes = TextEditingController(text: m?.notes ?? '');

    if (m != null) {
      _form = m.form;
      _frequency = MedFrequency
          .values[m.frequencyType.clamp(0, MedFrequency.values.length - 1)];
      _times = ScheduleSpec.parseTimes(m.doseTimes);
      _intervalHours = m.intervalHours;
      _weekdayMask = m.weekdayMask;
      _meal = MealRelationX.fromToken(m.mealRelation);
      _start = m.startDate;
      _end = m.endDate;
      _skip = ScheduleSpec.parseSkipDates(m.skipDates);
      _profileId = m.profileId;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _dosage,
      _dosageUnit,
      _inventory,
      _doctor,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  ScheduleSpec get _spec => ScheduleSpec(
    start: _start,
    end: _end,
    frequency: _frequency,
    doseMinutes: _times,
    intervalHours: _intervalHours,
    weekdayMask: _weekdayMask,
    skipDates: _skip,
  );

  Future<void> _scanPrescription() async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => const CameraScanScreen(mode: ScanMode.prescription),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      if (result.medicineName != null) _name.text = result.medicineName!;
      if (result.dosage != null) {
        final numeric = RegExp(r'[\d.]+').firstMatch(result.dosage!)?.group(0);
        final unit = RegExp(r'[a-zA-Z]+').firstMatch(result.dosage!)?.group(0);
        if (numeric != null) _dosage.text = numeric;
        if (unit != null) _dosageUnit.text = unit;
      }
      if (result.timesPerDay != null) {
        _frequency = MedFrequency.timesPerDay;
        _times = _defaultTimesFor(result.timesPerDay!);
      }
      if (result.durationDays != null) {
        _end = _start.add(Duration(days: result.durationDays! - 1));
      }
    });
  }

  /// Sensible waking-hour defaults for N doses a day.
  static List<int> _defaultTimesFor(int count) => switch (count) {
    1 => [480], // 08:00
    2 => [480, 1200], // 08:00, 20:00
    3 => [480, 840, 1200], // 08:00, 14:00, 20:00
    4 => [480, 720, 1020, 1320], // 08:00, 12:00, 17:00, 22:00
    _ => List.generate(
      count.clamp(1, 6),
      (i) => 480 + (i * (840 ~/ count.clamp(1, 6))),
    ),
  };

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      brandToast(context, 'Enter a medicine name.');
      return;
    }

    final repo = ref.read(medicineRepositoryProvider);
    final profiles = await repo.profiles();
    final profileId = _profileId ?? profiles.firstOrNull?.id;

    final companion = MedicinesCompanion(
      name: drift.Value(name),
      form: drift.Value(_form),
      dosage: drift.Value(double.tryParse(_dosage.text.trim()) ?? 1),
      dosageUnit: drift.Value(
        _dosageUnit.text.trim().isEmpty ? 'tablet' : _dosageUnit.text.trim(),
      ),
      inventory: drift.Value(int.tryParse(_inventory.text.trim()) ?? 0),
      doctorName: drift.Value(
        _doctor.text.trim().isEmpty ? null : _doctor.text.trim(),
      ),
      notes: drift.Value(
        _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
      profileId: drift.Value(profileId),
      frequencyType: drift.Value(_frequency.index),
      doseTimes: drift.Value(ScheduleSpec.encodeTimes(_times)),
      intervalHours: drift.Value(_intervalHours),
      weekdayMask: drift.Value(_weekdayMask),
      mealRelation: drift.Value(_meal.token),
      startDate: drift.Value(_start),
      endDate: drift.Value(_end),
      skipDates: drift.Value(ScheduleSpec.encodeSkipDates(_skip)),
    );

    int medicineId;
    if (_isEditing) {
      medicineId = widget.medicine!.id;
      await repo.updateMedicine(medicineId, companion);
      await repo.regenerateSchedule(medicineId, _spec);
    } else {
      medicineId = await repo.createMedicineWithSchedule(
        medicine: companion,
        spec: _spec,
      );
    }

    // The course is already saved at this point. Reminder scheduling depends on
    // OS permissions that can be denied or revoked, so a failure here must
    // never lose the user's medicine or trap them in the form.
    try {
      await _scheduleReminders(medicineId, name);
    } on Exception catch (e) {
      debugPrint('Could not schedule dose reminders: $e');
      if (mounted) {
        brandToast(
          context,
          'Saved, but reminders could not be scheduled. '
          'Check notification permissions in Settings.',
        );
      }
    }

    if (mounted) Navigator.pop(context);
  }

  /// Schedules notifications for upcoming doses.
  ///
  /// Only the near-term window is registered: both platforms cap how many
  /// pending local notifications an app may hold, and a long course can easily
  /// generate hundreds.
  Future<void> _scheduleReminders(int medicineId, String name) async {
    final repo = ref.read(medicineRepositoryProvider);
    final notifier = ref.read(notificationServiceProvider);
    final doses = await repo.dosesFor(medicineId);
    final horizon = DateTime.now().add(const Duration(days: 14));

    final upcoming = doses
        .where(
          (d) =>
              d.scheduledTime.isAfter(DateTime.now()) &&
              d.scheduledTime.isBefore(horizon),
        )
        .take(50);

    for (final dose in upcoming) {
      await notifier.scheduleDose(
        doseId: dose.id,
        medicineName: name,
        dosageLabel: '${_dosage.text.trim()} ${_dosageUnit.text.trim()}',
        mealHint: _meal.label,
        when: dose.scheduledTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    final profiles = ref.watch(profilesProvider).valueOrNull ?? const [];
    final preview = ScheduleGenerator.generate(_spec);
    final inventory = int.tryParse(_inventory.text.trim()) ?? 0;
    final dosage = double.tryParse(_dosage.text.trim()) ?? 1;
    final runOut = ScheduleGenerator.runOutDate(_spec, inventory, dosage);

    return SheetScaffold(
      title: _isEditing ? 'Edit medicine' : 'Add medicine',
      actions: [
        CircleIconButton(
          icon: AppIcons.scan,
          tooltip: 'Scan prescription',
          size: 40,
          onPressed: _scanPrescription,
        ),
        BrandButton(
          label: 'Save',
          kind: BrandButtonKind.ghost,
          expand: false,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandField(
            controller: _name,
            label: 'Medicine name',
            hint: 'Amoxicillin',
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          Text('Form', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppIcons.medicineForms.keys
                .map(
                  (f) => Pill(
                    label: f[0].toUpperCase() + f.substring(1),
                    icon: AppIcons.medicineForm(f),
                    selected: _form == f,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(() {
                      _form = f;
                      _dosageUnit.text = f;
                    }),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: BrandField(
                  controller: _dosage,
                  label: 'Dose',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrandField(controller: _dosageUnit, label: 'Unit'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrandField(
                  controller: _inventory,
                  label: 'In stock',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (profiles.length > 1) ...[
            Text('For', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profiles
                  .map(
                    (p) => Pill(
                      label: p.name,
                      selected: (_profileId ?? profiles.first.id) == p.id,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => setState(() => _profileId = p.id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          Text('How often', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _freqChip(MedFrequency.timesPerDay, 'Times a day'),
              _freqChip(MedFrequency.everyXHours, 'Every X hours'),
              _freqChip(MedFrequency.specificWeekdays, 'Certain days'),
              _freqChip(MedFrequency.alternateDays, 'Alternate days'),
            ],
          ),
          const SizedBox(height: 16),

          if (_frequency == MedFrequency.everyXHours)
            Row(
              children: [
                Text(
                  'Every $_intervalHours hours',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: BrandSlider(
                    value: _intervalHours.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    onChanged: (v) =>
                        setState(() => _intervalHours = v.round()),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Text(
                  'Dose times',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const AppIcon(AppIcons.add, size: 16),
                  label: const Text('Add time'),
                  onPressed: _addTime,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._times.map(
                  (m) => Pill(
                    label: Fmt.minutesOfDay(m),
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => _editTime(m),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 3, 4]
                  .map(
                    (n) => Pill(
                      label: '${n}x daily',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => setState(() => _times = _defaultTimesFor(n)),
                    ),
                  )
                  .toList(),
            ),
          ],

          if (_frequency == MedFrequency.specificWeekdays) ...[
            const SizedBox(height: 16),
            Text('On these days', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(7, (i) {
                const labels = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                final on = (_weekdayMask & (1 << i)) != 0;
                return Pill(
                  label: labels[i],
                  selected: on,
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    final v = !(on);
                    setState(() {
                      _weekdayMask = v
                          ? _weekdayMask | (1 << i)
                          : _weekdayMask & ~(1 << i);
                    });
                  },
                );
              }),
            ),
          ],

          const SizedBox(height: 20),
          Text('With food', style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MealRelation.values
                .map(
                  (m) => Pill(
                    label: m == MealRelation.none ? 'Any time' : m.label,
                    selected: _meal == m,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(() => _meal = m),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _dateField(
                  'Starts',
                  _start,
                  (d) => setState(() {
                    _start = d;
                    if (_end.isBefore(_start)) _end = _start;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  'Ends',
                  _end,
                  (d) => setState(() => _end = d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3, 5, 7, 10, 14, 30]
                .map(
                  (d) => Pill(
                    label: '$d days',
                    color: Theme.of(context).colorScheme.primary,
                    onTap: () => setState(
                      () => _end = _start.add(Duration(days: d - 1)),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),
          BrandTile(
            leading: const AppIcon(AppIcons.travel),
            title: const Text('Skip dates'),
            subtitle: Text(
              _skip.isEmpty
                  ? 'Travel or holiday — none set'
                  : '${_skip.length} date${_skip.length == 1 ? '' : 's'} skipped',
            ),
            trailing: const AppIcon(AppIcons.chevronRight),
            onTap: _pickSkipDates,
          ),

          const SizedBox(height: 12),
          BrandField(
            controller: _doctor,
            label: 'Doctor',
            prefix: const AppIcon(AppIcons.person),
          ),
          const SizedBox(height: 12),
          BrandField(
            controller: _notes,
            label: 'Notes',
            maxLines: 2,
            minLines: 1,
          ),

          const SizedBox(height: 24),
          BrandDivider(),
          const SizedBox(height: 8),
          const Text(
            'Course preview',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: AppIcons.medicine,
                  color: context.brand.medicine,
                  label: 'Total doses',
                  value: '${preview.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: AppIcons.inventory,
                  color: runOut == null
                      ? context.brand.success
                      : context.brand.warning,
                  label: 'Stock',
                  value: runOut == null ? 'Enough' : 'Runs out',
                  sublabel: runOut == null
                      ? 'Covers the course'
                      : Fmt.dayMonth(runOut),
                ),
              ),
            ],
          ),
          if (runOut != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _warning(
                'You will run out on ${Fmt.dayMonthYear(runOut)}. '
                'Add stock or plan a refill.',
              ),
            ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'First dose ${Fmt.relativeDay(preview.first)} at '
              '${Fmt.time(preview.first)} · last ${Fmt.dayMonthYear(preview.last)}',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _warning(
                'This setup generates no doses. Check the dates and days.',
              ),
            ),
        ],
      ),
    );
  }

  Widget _warning(String message) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: context.brand.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: context.brand.warning.withValues(alpha: 0.4)),
    ),
    child: Row(
      children: [
        AppIcon(AppIcons.warning, size: 18, color: context.brand.warning),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );

  Widget _freqChip(MedFrequency f, String label) => Pill(
    label: label,
    selected: _frequency == f,
    color: Theme.of(context).colorScheme.primary,
    onTap: () => setState(() => _frequency = f),
  );

  Widget _dateField(
    String label,
    DateTime value,
    ValueChanged<DateTime> onSet,
  ) {
    // A row rather than a decorated field: it reads as tappable, and it matches
    // the course/skip-date rows directly above it.
    return BrandTile(
      leading: const AppIcon(AppIcons.calendar),
      title: Text(label),
      subtitle: Text(Fmt.dayMonthYear(value)),
      trailing: const AppIcon(AppIcons.chevronRight),
      onTap: () async {
        final picked = await brandDatePicker(
          context,
          initial: value,
          first: DateTime.now().subtract(const Duration(days: 365)),
          last: DateTime.now().add(const Duration(days: 3650)),
          title: label,
        );
        if (picked != null) onSet(picked);
      },
    );
  }

  Future<void> _addTime() async {
    final minutes = await brandTimePicker(
      context,
      initialMinutes: 8 * 60,
      title: 'Add a dose time',
    );
    if (minutes == null) return;
    if (_times.contains(minutes)) return;
    setState(() => _times = [..._times, minutes]..sort());
  }

  Future<void> _editTime(int existing) async {
    final minutes = await brandTimePicker(
      context,
      initialMinutes: existing,
      title: 'Dose time',
    );
    if (minutes == null) return;
    setState(() {
      _times = [..._times.where((t) => t != existing), minutes]..sort();
    });
  }

  Future<void> _pickSkipDates() async {
    final range = await brandDateRangePicker(
      context,
      first: _start,
      last: _end,
      title: 'Days to skip',
    );
    if (range == null) return;
    setState(() {
      var day = Fmt.dateOnly(range.$1);
      final last = Fmt.dateOnly(range.$2);
      while (!day.isAfter(last)) {
        _skip.add(day);
        day = day.add(const Duration(days: 1));
      }
    });
  }
}
