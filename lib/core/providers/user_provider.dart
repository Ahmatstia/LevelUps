import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/task_model.dart'; // Tambahkan import ini
import '../repositories/user_repository.dart';

// Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// State notifier untuk user
class UserNotifier extends StateNotifier<UserModel?> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(null) {
    loadUser();
  }

  // Load user dari Hive
  Future<void> loadUser() async {
    final user = await _repository.getUser();
    if (user != null) {
      state = user;
    } else {
      // Jika belum ada user, buat default
      state = UserModel.initial('Player');
      await _repository.saveUser(state!);
    }
  }

  // Update user
  Future<void> updateUser(UserModel Function(UserModel) update) async {
    if (state == null) return;

    final updatedUser = update(state!);
    state = updatedUser;
    await _repository.saveUser(updatedUser);
  }

  // Hitung level dari XP
  int getLevelFromXp(int xp) {
    int level = 1;
    int xpRequired = 100;

    while (xp >= xpRequired) {
      level++;
      xpRequired = 100 * level;
    }

    return level;
  }

  // Tambah XP dan cek level up
  Future<void> addXp(int xpAmount) async {
    if (state == null) return;

    final newTotalXp = state!.totalXp + xpAmount;
    final newLevel = getLevelFromXp(newTotalXp);

    await updateUser((user) {
      return user.copyWith(totalXp: newTotalXp, level: newLevel);
    });
  }

  // Tambah stat
  Future<void> addStat(StatType statType, int amount) async {
    if (state == null) return;

    await updateUser((user) {
      switch (statType) {
        case StatType.intelligence:
          return user.copyWith(intelligence: user.intelligence + amount);
        case StatType.discipline:
          return user.copyWith(discipline: user.discipline + amount);
        case StatType.health:
          return user.copyWith(health: user.health + amount);
        case StatType.wealth:
          return user.copyWith(wealth: user.wealth + amount);
      }
    });
  }

  // Update streak
  Future<void> updateStreak(DateTime taskDate) async {
    if (state == null) return;

    final lastDate = state!.lastTaskDate;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    // Reset jika lebih dari 1 hari
    if (lastDate.isBefore(yesterday)) {
      await updateUser((user) => user.copyWith(streak: 0));
    }

    // Tambah streak jika task hari ini
    if (taskDate.year == today.year &&
        taskDate.month == today.month &&
        taskDate.day == today.day) {
      await updateUser(
        (user) => user.copyWith(streak: user.streak + 1, lastTaskDate: today),
      );
    }
  }

  // Reset user
  Future<void> resetUser(String name) async {
    state = UserModel.initial(name);
    await _repository.saveUser(state!);
  }
}

// Provider untuk user state
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});

// Provider untuk XP requirement di level saat ini
final xpForNextLevelProvider = Provider<int>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return 100;
  return 100 * user.level;
});

// Provider untuk progress XP ke level berikutnya
final xpProgressProvider = Provider<double>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return 0.0;

  final currentLevelXp = 100 * (user.level - 1);
  final nextLevelXp = 100 * user.level;
  final xpInCurrentLevel = user.totalXp - currentLevelXp;

  return xpInCurrentLevel / (nextLevelXp - currentLevelXp);
});
