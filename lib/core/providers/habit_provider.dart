import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/habit_model.dart';
import '../models/task_model.dart';
import 'user_provider.dart';

class HabitNotifier extends StateNotifier<List<HabitModel>> {
  final Box<HabitModel> _box;
  final Ref _ref;

  HabitNotifier(this._box, this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = _box.values.toList();
  }

  // Tambah habit baru
  Future<void> addHabit({
    required String title,
    required String description,
    required String statType,
    required HabitFrequency frequency,
    int xpReward = 15,
  }) async {
    final habit = HabitModel.create(
      title: title,
      description: description,
      statType: statType,
      frequency: frequency,
      xpReward: xpReward,
    );
    await _box.put(habit.id, habit);
    state = _box.values.toList();
  }

  // Check-in habit hari ini
  Future<bool> checkIn(String habitId) async {
    final habit = _box.get(habitId);
    if (habit == null) return false;

    // Jangan check-in 2x dalam sehari
    if (habit.isCheckedInToday) return false;

    final now = DateTime.now();
    final lastDate = habit.lastCheckinDate;

    // Hitung streak baru
    int newStreak = 1;
    if (lastDate != null) {
      final lastNormalized = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final todayNormalized = DateTime(now.year, now.month, now.day);
      final diff = todayNormalized.difference(lastNormalized).inDays;
      if (diff == 1) {
        // Nyambung dari kemarin
        newStreak = habit.currentStreak + 1;
      } else if (diff == 0) {
        // Sudah check-in hari ini (tidak mungkin, tapi safety check)
        return false;
      }
    }

    final newBest = newStreak > habit.bestStreak ? newStreak : habit.bestStreak;

    habit.currentStreak = newStreak;
    habit.bestStreak = newBest;
    habit.lastCheckinDate = now;
    habit.completedDates = [...habit.completedDates, now];

    await habit.save();
    state = _box.values.toList();

    // Berikan reward ke user
    final userNotifier = _ref.read(userProvider.notifier);
    await userNotifier.addXp(habit.xpReward);

    // Tambah stat sesuai statType
    final statMap = {
      'intelligence': StatType.intelligence,
      'discipline': StatType.discipline,
      'health': StatType.health,
      'wealth': StatType.wealth,
    };
    final stat = statMap[habit.statType];
    if (stat != null) {
      await userNotifier.addStat(stat, 1);
    }

    return true;
  }

  // Hapus habit
  Future<void> deleteHabit(String habitId) async {
    await _box.delete(habitId);
    state = _box.values.toList();
  }

  // Hitung berapa habit yang sudah check-in hari ini
  int get checkedInTodayCount {
    return state.where((h) => h.isCheckedInToday).length;
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<HabitModel>>((
  ref,
) {
  final box = Hive.box<HabitModel>('habits');
  return HabitNotifier(box, ref);
});

final habitsTodayDoneProvider = Provider<int>((ref) {
  final habits = ref.watch(habitProvider);
  return habits.where((h) => h.isCheckedInToday).length;
});
