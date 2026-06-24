import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/medicine.dart';
import '../../state/medicine_controller.dart';
import '../../widgets/common.dart';

/// Per-medicine monthly schedule as a table (rows = dates, columns = time
/// slots) with tap-to-toggle intake, adherence and a run-out forecast.
class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key, required this.medicineId});

  final String medicineId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MedicineController>();
    final med = controller.medicines
        .where((m) => m.id == medicineId)
        .cast<Medicine?>()
        .firstWhere((m) => true, orElse: () => null);

    if (med == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Medicine not found')),
      );
    }

    final days = <DateTime>[
      for (var d = Day.only(med.startDate);
          !d.isAfter(Day.only(med.endDate));
          d = d.add(const Duration(days: 1)))
        d
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(med.name),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () {
              controller.delete(med.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Adherence',
                  value: '${(med.adherence() * 100).round()}%',
                  icon: LucideIcons.circleCheck,
                  color: AppColors.medicine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Doses / day',
                  value: '${med.times.length}',
                  icon: LucideIcons.clock,
                  color: AppColors.medicine,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Course',
                  value: '${med.courseDays}d',
                  icon: LucideIcons.calendar,
                  color: AppColors.medicine,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (med.stock != null) _StockForecast(med: med),
          const SizedBox(height: 8),
          const SectionHeader('Schedule', icon: LucideIcons.calendarRange),
          AppCard(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 52,
                columns: [
                  const DataColumn(label: Text('Date')),
                  for (final t in med.times)
                    DataColumn(
                      label: Text(TimeOfDay(hour: t ~/ 60, minute: t % 60)
                          .format(context)),
                    ),
                ],
                rows: [
                  for (final day in days)
                    DataRow(
                      cells: [
                        DataCell(Text(Fmt.date(day),
                            style: Day.same(day, DateTime.now())
                                ? context.text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.medicine)
                                : null)),
                        for (final t in med.times)
                          DataCell(
                            _Check(
                              taken: med.takenAt(day, t),
                              onTap: () {
                                med.setTaken(day, t, !med.takenAt(day, t));
                                controller.upsert(med);
                              },
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.taken, required this.onTap});
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Icon(
        taken ? LucideIcons.circleCheck : LucideIcons.circle,
        color: taken ? AppColors.successLight : context.muted,
        size: 22,
      ),
    );
  }
}

class _StockForecast extends StatelessWidget {
  const _StockForecast({required this.med});
  final Medicine med;

  @override
  Widget build(BuildContext context) {
    final perDay = med.times.length;
    final daysLeft = perDay == 0 ? 0 : (med.stock! / perDay).floor();
    final runOut = Day.today().add(Duration(days: daysLeft));
    final low = daysLeft <= 3;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (low ? AppColors.warningLight : AppColors.medicine)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(low ? LucideIcons.triangleAlert : LucideIcons.package,
              color: low ? AppColors.warningLight : AppColors.medicine),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${med.stock} left · enough for ~$daysLeft days. You\'ll run out around ${Fmt.date(runOut)}.',
              style: context.text.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
