import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/services/export_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import 'providers/medicine_provider.dart';
import 'repository/medicine_repository.dart';
import 'utils/schedule_generator.dart';
import 'widgets/medicine_editor_sheet.dart';

class MedicineScreen extends ConsumerStatefulWidget {
  const MedicineScreen({super.key});

  @override
  ConsumerState<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends ConsumerState<MedicineScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine'),
        actions: [
          IconButton(
            tooltip: 'Log a symptom',
            icon: const AppIcon(AppIcons.symptom),
            onPressed: () => _logSymptom(context),
          ),
          IconButton(
            tooltip: 'Share schedule',
            icon: const AppIcon(AppIcons.share),
            onPressed: _exportSchedule,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Calendar'),
            Tab(text: 'Timeline'),
            Tab(text: 'Table'),
            Tab(text: 'Medicines'),
          ],
        ),
      ),
      drawer: const _ProfileDrawer(),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _TodayTab(),
          _CalendarTab(),
          _TimelineTab(),
          _TableTab(),
          _MedicinesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MedicineEditorSheet.show(context),
        backgroundColor: AppColors.medicineAccent,
        foregroundColor: Colors.white,
        icon: const AppIcon(AppIcons.add),
        label: const Text('Add medicine'),
      ),
    );
  }

  Future<void> _exportSchedule() async {
    final export = ref.read(exportServiceProvider);
    final views = ref.read(monthDoseViewsProvider).valueOrNull ?? const [];
    if (views.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No doses scheduled this month.')),
      );
      return;
    }
    final profiles = ref.read(profilesProvider).valueOrNull ?? const [];
    final activeId = ref.read(activeProfileProvider);
    final profileName = activeId == null
        ? 'All profiles'
        : profiles.where((p) => p.id == activeId).firstOrNull?.name ?? 'Profile';
    final adherence = ref.read(adherenceProvider).valueOrNull;

    final file = await export.medicineSchedulePdf(
      profileName: profileName,
      adherence: adherence?.monthly,
      doses: views
          .map((v) => (
                medicine: v.medicine.name,
                dosage: v.dosageLabel,
                meal: v.mealLabel,
                at: v.at,
                status: v.status,
              ))
          .toList(),
    );
    await export.shareFile(file, text: 'Medicine schedule');
  }

  Future<void> _logSymptom(BuildContext context) async {
    final controller = TextEditingController();
    var severity = 1;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          title: 'Log symptom',
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save')),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Symptom', hintText: 'Headache, nausea…'),
              ),
              const SizedBox(height: 20),
              const Text('Severity'),
              Slider(
                value: severity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$severity',
                onChanged: (v) => setState(() => severity = v.round()),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
      await ref.read(medicineRepositoryProvider).logSymptom(
            symptom: controller.text.trim(),
            severity: severity,
            profileId: ref.read(activeProfileProvider),
          );
    }
  }
}

// --- Today ------------------------------------------------------------------

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doses = ref.watch(todayDoseViewsProvider);
    final adherence = ref.watch(adherenceProvider).valueOrNull;
    final lowStock = ref.watch(lowStockProvider);
    final forecast = ref.watch(runOutForecastProvider)
        .where((f) => f.date != null)
        .toList();
    final conflicts = ref.watch(conflictsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (adherence != null)
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: AppIcons.today,
                  color: AppColors.medicineAccent,
                  label: 'Today',
                  value: Fmt.percent(adherence.daily),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  icon: AppIcons.calendarWeek,
                  color: AppColors.medicineAccent,
                  label: 'This week',
                  value: Fmt.percent(adherence.weekly),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  icon: AppIcons.insights,
                  color: AppColors.medicineAccent,
                  label: '30 days',
                  value: Fmt.percent(adherence.monthly),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),

        if (conflicts.isNotEmpty) ...[
          _alert(
            context,
            icon: AppIcons.warning,
            color: AppColors.warningLight,
            title: '${conflicts.length} timing conflict'
                '${conflicts.length == 1 ? '' : 's'} this month',
            body: conflicts
                .take(3)
                .map((c) =>
                    '${c.first} and ${c.second} both at ${Fmt.time(c.at)} on ${Fmt.dayMonth(c.at)}')
                .join('\n'),
          ),
          const SizedBox(height: 12),
        ],

        for (final f in forecast) ...[
          _alert(
            context,
            icon: AppIcons.inventory,
            color: AppColors.warningLight,
            title: '${f.medicine.name} runs out ${Fmt.relativeDay(f.date!)}',
            body:
                '${f.medicine.inventory} ${f.medicine.dosageUnit} left. Plan a refill.',
          ),
          const SizedBox(height: 12),
        ],

        for (final m in lowStock.where((m) =>
            !forecast.any((f) => f.medicine.id == m.id))) ...[
          _alert(
            context,
            icon: AppIcons.inventory,
            color: AppColors.warningLight,
            title: '${m.name} is low',
            body: 'Only ${m.inventory} ${m.dosageUnit} left.',
          ),
          const SizedBox(height: 12),
        ],

        const SectionHeader("Today's doses"),
        doses.when(
          data: (list) => list.isEmpty
              ? const EmptyState(
                  icon: AppIcons.medicine,
                  title: 'No doses today',
                  message: 'Add a medicine to generate its schedule.',
                )
              : Column(children: list.map((v) => DoseTile(view: v)).toList()),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
      ],
    );
  }

  Widget _alert(
    BuildContext context, {
    required HugeIconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One dose row with taken / skip / snooze actions.
class DoseTile extends ConsumerWidget {
  final DoseView view;
  final bool showDate;

  const DoseTile({super.key, required this.view, this.showDate = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(medicineRepositoryProvider);
    final muted = Theme.of(context).colorScheme.outline;
    final taken = view.status == DoseStatus.taken;
    final skipped = view.status == DoseStatus.skipped;
    final missed = !taken &&
        !skipped &&
        view.at.isBefore(DateTime.now().subtract(const Duration(hours: 1)));

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onLongPress: () => repo.setDoseStatus(view.dose.id, DoseStatus.skipped),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.medicineAccent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: AppIcon(AppIcons.medicineForm(view.medicine.form),
              color: AppColors.medicineAccent, size: 20),
        ),
        title: Text(
          view.medicine.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: skipped ? TextDecoration.lineThrough : null,
            color: skipped ? muted : null,
          ),
        ),
        subtitle: Text(
          [
            view.dosageLabel,
            if (view.mealLabel.isNotEmpty) view.mealLabel,
            if (showDate) Fmt.dayMonth(view.at),
            if (missed) 'Missed',
          ].join(' · '),
          style: TextStyle(
              fontSize: 11, color: missed ? AppColors.dangerLight : muted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Fmt.time(view.at),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 6),
            IconButton(
              tooltip: taken ? 'Mark not taken' : 'Mark taken',
              icon: AppIcon(
                  taken ? AppIcons.checkCircle : AppIcons.circle),
              color: taken ? AppColors.successLight : muted,
              iconSize: 28,
              onPressed: () => repo.setDoseStatus(
                view.dose.id,
                taken ? DoseStatus.pending : DoseStatus.taken,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Calendar ---------------------------------------------------------------

final _selectedDayProvider =
    StateProvider<DateTime>((ref) => Fmt.dateOnly(DateTime.now()));

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(scheduleMonthProvider);
    final byDay = ref.watch(monthDosesByDayProvider);
    final selected = ref.watch(_selectedDayProvider);
    final muted = Theme.of(context).colorScheme.outline;

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = DateTime(month.year, month.month, 1).weekday - 1;
    final selectedDoses = byDay[selected] ?? const <DoseView>[];

    return Column(
      children: [
        _MonthSwitcher(month: month),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(fontSize: 11, color: muted)),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, childAspectRatio: 0.92),
            itemCount: leading + daysInMonth,
            itemBuilder: (_, i) {
              if (i < leading) return const SizedBox.shrink();
              final day =
                  DateTime(month.year, month.month, i - leading + 1);
              final doses = byDay[day] ?? const <DoseView>[];
              final isSel = Fmt.isSameDay(day, selected);
              final isToday = Fmt.isSameDay(day, DateTime.now());

              final taken =
                  doses.where((d) => d.status == DoseStatus.taken).length;
              final allTaken = doses.isNotEmpty && taken == doses.length;
              final anyMissed = doses.any((d) =>
                  d.status == DoseStatus.pending &&
                  d.at.isBefore(DateTime.now()));

              return GestureDetector(
                onTap: () =>
                    ref.read(_selectedDayProvider.notifier).state = day,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.medicineAccent
                        : isToday
                            ? AppColors.medicineAccent.withValues(alpha: 0.1)
                            : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${day.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isSel ? Colors.white : null,
                          )),
                      const SizedBox(height: 3),
                      if (doses.isEmpty)
                        const SizedBox(height: 6)
                      else
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSel
                                ? Colors.white
                                : allTaken
                                    ? AppColors.successLight
                                    : anyMissed
                                        ? AppColors.dangerLight
                                        : AppColors.medicineAccent,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 20),
        Expanded(
          child: selectedDoses.isEmpty
              ? EmptyState(
                  icon: AppIcons.calendarDone,
                  title: 'No doses on ${Fmt.relativeDay(selected)}',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  children:
                      selectedDoses.map((v) => DoseTile(view: v)).toList(),
                ),
        ),
      ],
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  final DateTime month;
  const _MonthSwitcher({required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          icon: const AppIcon(AppIcons.chevronLeft),
          onPressed: () => ref.read(scheduleMonthProvider.notifier).state =
              DateTime(month.year, month.month - 1),
        ),
        Expanded(
          child: Text(Fmt.monthYear(month),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        IconButton(
          icon: const AppIcon(AppIcons.chevronRight),
          onPressed: () => ref.read(scheduleMonthProvider.notifier).state =
              DateTime(month.year, month.month + 1),
        ),
      ],
    );
  }
}

// --- Timeline ---------------------------------------------------------------

class _TimelineTab extends ConsumerWidget {
  const _TimelineTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(scheduleMonthProvider);
    final byDay = ref.watch(monthDosesByDayProvider);
    final days = byDay.keys.toList()..sort();

    return Column(
      children: [
        _MonthSwitcher(month: month),
        Expanded(
          child: days.isEmpty
              ? const EmptyState(
                  icon: AppIcons.timeline,
                  title: 'Nothing scheduled this month')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: days.length,
                  itemBuilder: (_, i) {
                    final day = days[i];
                    final doses = byDay[day]!;
                    final taken = doses
                        .where((d) => d.status == DoseStatus.taken)
                        .length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Text(Fmt.relativeDay(day),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Text('$taken/${doses.length} taken',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline)),
                            ],
                          ),
                        ),
                        ...doses.map((v) => DoseTile(view: v)),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- Table (rows = dates, columns = time slots) -----------------------------

class _TableTab extends ConsumerWidget {
  const _TableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(scheduleMonthProvider);
    final byDay = ref.watch(monthDosesByDayProvider);
    final repo = ref.read(medicineRepositoryProvider);
    final muted = Theme.of(context).colorScheme.outline;

    final days = byDay.keys.toList()..sort();
    // Columns are every distinct time-of-day used anywhere in the month.
    final slots = <int>{
      for (final list in byDay.values)
        for (final v in list) v.at.hour * 60 + v.at.minute,
    }.toList()
      ..sort();

    if (days.isEmpty) {
      return Column(
        children: [
          _MonthSwitcher(month: month),
          const Expanded(
            child: EmptyState(
                icon: AppIcons.spreadsheet,
                title: 'Nothing scheduled this month'),
          ),
        ],
      );
    }

    return Column(
      children: [
        _MonthSwitcher(month: month),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 52,
                columnSpacing: 18,
                columns: [
                  const DataColumn(
                      label: Text('Date',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))),
                  ...slots.map((s) => DataColumn(
                        label: Text(Fmt.minutesOfDay(s),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                      )),
                ],
                rows: days.map((day) {
                  final doses = byDay[day]!;
                  return DataRow(cells: [
                    DataCell(Text(Fmt.dayMonth(day),
                        style: const TextStyle(fontSize: 12))),
                    ...slots.map((slot) {
                      final atSlot = doses
                          .where((v) => v.at.hour * 60 + v.at.minute == slot)
                          .toList();
                      if (atSlot.isEmpty) {
                        return DataCell(Text('—',
                            style: TextStyle(color: muted, fontSize: 12)));
                      }
                      return DataCell(
                        Wrap(
                          spacing: 4,
                          children: atSlot.map((v) {
                            final taken = v.status == DoseStatus.taken;
                            final skipped = v.status == DoseStatus.skipped;
                            return InkWell(
                              onTap: () => repo.setDoseStatus(
                                v.dose.id,
                                taken ? DoseStatus.pending : DoseStatus.taken,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (taken
                                          ? AppColors.successLight
                                          : skipped
                                              ? muted
                                              : AppColors.medicineAccent)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppIcon(
                                      taken
                                          ? AppIcons.check
                                          : skipped
                                              ? AppIcons.close
                                              : AppIcons.circle,
                                      size: 11,
                                      color: taken
                                          ? AppColors.successLight
                                          : skipped
                                              ? muted
                                              : AppColors.medicineAccent,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      v.medicine.name.length > 10
                                          ? '${v.medicine.name.substring(0, 9)}…'
                                          : v.medicine.name,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Per-medicine -----------------------------------------------------------

class _MedicinesTab extends ConsumerWidget {
  const _MedicinesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicinesProvider);
    final repo = ref.read(medicineRepositoryProvider);
    final muted = Theme.of(context).colorScheme.outline;

    return meds.when(
      data: (list) => list.isEmpty
          ? EmptyState(
              icon: AppIcons.medicine,
              title: 'No medicines yet',
              message: 'Add one to generate its full course automatically.',
              actionLabel: 'Add medicine',
              onAction: () => MedicineEditorSheet.show(context),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: list.map((m) {
                final spec = MedicineRepository.specOf(m);
                final total = ScheduleGenerator.totalDoses(spec);
                final low = m.inventory <= m.lowStockThreshold;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () =>
                        MedicineEditorSheet.show(context, medicine: m),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color:
                            AppColors.medicineAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(AppIcons.medicineForm(m.form),
                          color: AppColors.medicineAccent, size: 20),
                    ),
                    title: Text(m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DoseView.trimAmount(m.dosage)} ${m.dosageUnit} · '
                          '$total doses · until ${Fmt.dayMonth(m.endDate)}',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                        Text(
                          '${m.inventory} ${m.dosageUnit} in stock',
                          style: TextStyle(
                            fontSize: 11,
                            color: low ? AppColors.warningLight : muted,
                            fontWeight: low ? FontWeight.w600 : null,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        switch (value) {
                          case 'refill':
                            await _refill(context, ref, m);
                          case 'delete':
                            await repo.deleteMedicine(m.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'refill', child: Text('Add stock')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('$e'),
    );
  }

  Future<void> _refill(
      BuildContext context, WidgetRef ref, Medicine m) async {
    final controller = TextEditingController(text: '30');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add stock — ${m.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: 'Units to add', suffixText: m.dosageUnit),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add')),
        ],
      ),
    );
    final delta = int.tryParse(result?.trim() ?? '');
    if (delta != null && delta > 0) {
      await ref.read(medicineRepositoryProvider).adjustInventory(m.id, delta);
    }
  }
}

// --- Profiles ---------------------------------------------------------------

class _ProfileDrawer extends ConsumerWidget {
  const _ProfileDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider);
    final active = ref.watch(activeProfileProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.medicineAccent),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text('Profiles',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          ListTile(
            dense: true,
            leading: const AppIcon(AppIcons.people, size: 20),
            title: const Text('Everyone'),
            selected: active == null,
            selectedTileColor:
                AppColors.medicineAccent.withValues(alpha: 0.12),
            onTap: () {
              ref.read(activeProfileProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
          const Divider(),
          profiles.maybeWhen(
            data: (list) => Column(
              children: list
                  .map((p) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(p.color),
                          child: Text(
                            p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                        ),
                        title: Text(p.name),
                        subtitle: Text(p.relation,
                            style: const TextStyle(fontSize: 11)),
                        selected: active == p.id,
                        selectedTileColor: AppColors.medicineAccent
                            .withValues(alpha: 0.12),
                        onTap: () {
                          ref.read(activeProfileProvider.notifier).state = p.id;
                          Navigator.pop(context);
                        },
                        onLongPress: () async {
                          Navigator.pop(context);
                          await ref
                              .read(medicineRepositoryProvider)
                              .deleteProfile(p.id);
                        },
                      ))
                  .toList(),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const Divider(),
          ListTile(
            dense: true,
            leading: const AppIcon(AppIcons.personAdd, size: 20),
            title: const Text('Add profile'),
            onTap: () => _addProfile(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _addProfile(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final relation = TextEditingController(text: 'Family');
    var color = 0xFFFF6547;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relation,
                decoration: const InputDecoration(
                    labelText: 'Relation', hintText: 'Mum, son, partner'),
              ),
              const SizedBox(height: 16),
              ColorPickerRow(
                  selected: color, onChanged: (c) => setState(() => color = c)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Create')),
          ],
        ),
      ),
    );

    if (saved == true && name.text.trim().isNotEmpty) {
      await ref.read(medicineRepositoryProvider).createProfile(
            name.text.trim(),
            relation.text.trim(),
            color,
          );
    }
    if (context.mounted) Navigator.of(context).maybePop();
  }
}
