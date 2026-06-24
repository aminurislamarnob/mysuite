import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/medicine.dart';
import '../../state/medicine_controller.dart';
import '../../widgets/common.dart';
import 'add_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  int _tab = 0; // 0 = Today, 1 = Medicines
  DateTime _day = Day.today();

  @override
  Widget build(BuildContext context) {
    final med = context.watch<MedicineController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Today'), icon: Icon(LucideIcons.calendarCheck)),
                ButtonSegment(value: 1, label: Text('Medicines'), icon: Icon(LucideIcons.pill)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add medicine'),
      ),
      body: _tab == 0 ? _buildToday(context, med) : _buildList(context, med),
    );
  }

  Widget _buildToday(BuildContext context, MedicineController med) {
    final doses = med.dosesOn(_day);
    return Column(
      children: [
        _DayPicker(day: _day, onChange: (d) => setState(() => _day = d)),
        Expanded(
          child: doses.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.calendarCheck,
                  title: 'No doses scheduled',
                  message: 'Add a medicine to generate a daily schedule.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: doses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DoseTile(
                    slot: doses[i],
                    onToggle: (v) => med.setTaken(doses[i], v),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, MedicineController med) {
    if (med.count == 0) {
      return EmptyState(
        icon: LucideIcons.pill,
        title: 'No medicines yet',
        message: 'Add a course and mySuite builds the full schedule for you.',
        action: FilledButton.icon(
          onPressed: () => _add(context),
          icon: const Icon(LucideIcons.plus),
          label: const Text('Add medicine'),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: med.medicines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final m = med.medicines[i];
        return AppCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MedicineDetailScreen(medicineId: m.id))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(_formIcon(m.form), color: AppColors.medicine),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m.name} · ${m.dosage}',
                            style: context.text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${m.times.length}×/day · ${m.mealRule.label} · ${m.profile}',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.muted),
                        ),
                      ],
                    ),
                  ),
                  Text('${(m.adherence() * 100).round()}%',
                      style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.medicine)),
                ],
              ),
              const SizedBox(height: 10),
              ProgressBar(value: m.adherence(), color: AppColors.medicine),
              const SizedBox(height: 8),
              Text(
                '${Fmt.dateFull(m.startDate)} → ${Fmt.dateFull(m.endDate)} · ${m.courseDays} days',
                style: context.text.labelSmall?.copyWith(color: context.muted),
              ),
            ],
          ),
        );
      },
    );
  }

  void _add(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
  }
}

IconData _formIcon(MedForm form) => switch (form) {
      MedForm.tablet => LucideIcons.pill,
      MedForm.capsule => LucideIcons.pill,
      MedForm.syrup => LucideIcons.flaskConical,
      MedForm.injection => LucideIcons.syringe,
      MedForm.drops => LucideIcons.droplet,
      MedForm.inhaler => LucideIcons.wind,
    };

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.day, required this.onChange});

  final DateTime day;
  final ValueChanged<DateTime> onChange;

  @override
  Widget build(BuildContext context) {
    final today = Day.today();
    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 14,
        itemBuilder: (_, i) {
          final d = today.subtract(Duration(days: 3 - i));
          final selected = Day.same(d, day);
          return GestureDetector(
            onTap: () => onChange(d),
            child: Container(
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.medicine
                    : context.colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: context.muted.withValues(alpha: 0.18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Fmt.weekday(d),
                      style: context.text.labelSmall?.copyWith(
                          color: selected ? Colors.white : context.muted)),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                      style: context.text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : null)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoseTile extends StatelessWidget {
  const _DoseTile({required this.slot, required this.onToggle});

  final DoseSlot slot;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final taken = slot.taken;
    return AppCard(
      onTap: () => onToggle(!taken),
      child: Row(
        children: [
          Column(
            children: [
              Text(Fmt.timeOfDate(context, slot.time),
                  style: context.text.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 36, color: context.muted.withValues(alpha: 0.2)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${slot.medicine.name} · ${slot.medicine.dosage}',
                    style: context.text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: taken ? TextDecoration.lineThrough : null,
                        color: taken ? context.muted : null)),
                Text(slot.medicine.mealRule.label,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.muted)),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => onToggle(!taken),
            isSelected: taken,
            icon: Icon(taken ? LucideIcons.check : LucideIcons.circle),
            style: IconButton.styleFrom(
              backgroundColor: taken
                  ? AppColors.successLight.withValues(alpha: 0.18)
                  : null,
              foregroundColor: taken ? AppColors.successLight : context.muted,
            ),
          ),
        ],
      ),
    );
  }
}
