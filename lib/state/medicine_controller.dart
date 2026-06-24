import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_store.dart';
import '../core/utils/formatters.dart';
import '../models/medicine.dart';

class MedicineController extends ChangeNotifier {
  MedicineController(this._store) {
    _load();
  }

  static const _key = 'medicines';
  static const _uuid = Uuid();
  final LocalStore _store;
  final List<Medicine> _meds = [];

  List<Medicine> get medicines => List.unmodifiable(_meds);
  int get count => _meds.length;

  void _load() {
    _meds
      ..clear()
      ..addAll(_store.readList(_key).map(Medicine.fromJson));
  }

  Future<void> _persist() =>
      _store.writeList(_key, _meds.map((m) => m.toJson()).toList());

  String newId() => _uuid.v4();

  void upsert(Medicine med) {
    final i = _meds.indexWhere((m) => m.id == med.id);
    if (i >= 0) {
      _meds[i] = med;
    } else {
      _meds.add(med);
    }
    _persist();
    notifyListeners();
  }

  void delete(String id) {
    _meds.removeWhere((m) => m.id == id);
    _persist();
    notifyListeners();
  }

  /// All dose slots scheduled for [day], sorted by time.
  List<DoseSlot> dosesOn(DateTime day) {
    final slots = <DoseSlot>[];
    for (final med in _meds) {
      if (!med.isActiveOn(day)) continue;
      for (final t in med.times) {
        slots.add(DoseSlot(medicine: med, day: Day.only(day), minutes: t));
      }
    }
    slots.sort((a, b) => a.minutes.compareTo(b.minutes));
    return slots;
  }

  List<DoseSlot> todaysDoses() => dosesOn(Day.today());

  /// The next not-yet-taken dose today (used on the dashboard).
  DoseSlot? nextDoseToday() {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final upcoming = todaysDoses()
        .where((d) => !d.taken && d.minutes >= nowMinutes)
        .toList();
    if (upcoming.isNotEmpty) return upcoming.first;
    final pending = todaysDoses().where((d) => !d.taken).toList();
    return pending.isEmpty ? null : pending.first;
  }

  int remainingToday() => todaysDoses().where((d) => !d.taken).length;

  void setTaken(DoseSlot slot, bool taken) {
    slot.medicine.setTaken(slot.day, slot.minutes, taken);
    _persist();
    notifyListeners();
  }

  double overallAdherence() {
    if (_meds.isEmpty) return 0;
    final active = _meds.where((m) => m.adherence() > 0 || m.isActiveOn(Day.today()));
    if (active.isEmpty) return 0;
    return active.map((m) => m.adherence()).reduce((a, b) => a + b) /
        active.length;
  }
}
