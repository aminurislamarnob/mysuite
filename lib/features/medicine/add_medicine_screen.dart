import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/medicine.dart';
import '../../state/medicine_controller.dart';

/// Add a medicine course. Picking a frequency preset auto-fills sensible times,
/// which feed the schedule generator (spec 4.2).
class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _name = TextEditingController();
  final _dosage = TextEditingController(text: '1 tablet');
  final _stock = TextEditingController();

  MedForm _form = MedForm.tablet;
  MealRule _meal = MealRule.after;
  String _profile = 'Self';
  final List<int> _times = [8 * 60, 20 * 60]; // 8:00, 20:00
  DateTime _start = Day.today();
  int _durationDays = 7;

  static const _profiles = ['Self', 'Mother', 'Father', 'Partner', 'Child'];

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    _stock.dispose();
    super.dispose();
  }

  DateTime get _end => _start.add(Duration(days: _durationDays - 1));

  void _applyFrequency(int perDay) {
    setState(() {
      _times
        ..clear()
        ..addAll(switch (perDay) {
          1 => [8 * 60],
          2 => [8 * 60, 20 * 60],
          3 => [8 * 60, 14 * 60, 20 * 60],
          4 => [8 * 60, 12 * 60, 16 * 60, 20 * 60],
          _ => [8 * 60],
        });
    });
  }

  Future<void> _pickTime(int index) async {
    final current = _times[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked != null) {
      setState(() => _times[index] = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _times.add(picked.hour * 60 + picked.minute);
        _times.sort();
      });
    }
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a medicine name')));
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one time')));
      return;
    }
    final controller = context.read<MedicineController>();
    controller.upsert(Medicine(
      id: controller.newId(),
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      form: _form,
      times: [..._times]..sort(),
      startDate: _start,
      endDate: _end,
      mealRule: _meal,
      profile: _profile,
      stock: int.tryParse(_stock.text.trim()),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalDoses = _times.length * _durationDays;
    return Scaffold(
      appBar: AppBar(title: const Text('Add medicine')),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
        child: FilledButton.icon(
          onPressed: _save,
          icon: const Icon(LucideIcons.calendarPlus),
          label: Text('Generate schedule · $totalDoses doses'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Medicine name',
              hintText: 'e.g. Napa Extra',
              prefixIcon: Icon(LucideIcons.pill),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dosage,
            decoration: const InputDecoration(
              labelText: 'Dosage',
              hintText: 'e.g. 500mg / 2 tablets',
            ),
          ),
          const SizedBox(height: 20),
          _Label('Form'),
          Wrap(
            spacing: 8,
            children: [
              for (final f in MedForm.values)
                ChoiceChip(
                  label: Text(f.label),
                  selected: _form == f,
                  onSelected: (_) => setState(() => _form = f),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _Label('Frequency'),
          Wrap(
            spacing: 8,
            children: [
              for (final n in const [1, 2, 3, 4])
                ActionChip(
                  label: Text('$n×/day'),
                  onPressed: () => _applyFrequency(n),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Label('Times'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < _times.length; i++)
                InputChip(
                  label: Text(TimeOfDay(
                          hour: _times[i] ~/ 60, minute: _times[i] % 60)
                      .format(context)),
                  avatar: const Icon(LucideIcons.clock, size: 16),
                  onPressed: () => _pickTime(i),
                  onDeleted: _times.length > 1
                      ? () => setState(() => _times.removeAt(i))
                      : null,
                ),
              ActionChip(
                avatar: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add time'),
                onPressed: _addTime,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Label('Meal instruction'),
          Wrap(
            spacing: 8,
            children: [
              for (final r in MealRule.values)
                ChoiceChip(
                  label: Text(r.label),
                  selected: _meal == r,
                  onSelected: (_) => setState(() => _meal = r),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _Label('Course'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _start,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _start = Day.only(picked));
                  },
                  icon: const Icon(LucideIcons.calendar, size: 18),
                  label: Text(Fmt.dateFull(_start)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Duration', style: context.text.bodyMedium),
              const Spacer(),
              Text('$_durationDays days · ends ${Fmt.date(_end)}',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.muted)),
            ],
          ),
          Slider(
            value: _durationDays.toDouble(),
            min: 1,
            max: 90,
            divisions: 89,
            label: '$_durationDays days',
            onChanged: (v) => setState(() => _durationDays = v.round()),
          ),
          const SizedBox(height: 8),
          _Label('Profile'),
          Wrap(
            spacing: 8,
            children: [
              for (final p in _profiles)
                ChoiceChip(
                  label: Text(p),
                  selected: _profile == p,
                  onSelected: (_) => setState(() => _profile = p),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _stock,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pills in stock (optional)',
              hintText: 'For low-stock & refill alerts',
              prefixIcon: Icon(LucideIcons.package),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.medicine.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.sparkles, color: AppColors.medicine),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'mySuite will generate $totalDoses doses across $_durationDays days and set reminders automatically.',
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style:
              context.text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
