import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/task_model.dart'; // Tambahkan import ini
import '../repositories/user_repository.dart';
import 'gamification_engine.dart';

// Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// State notifier untuk user
class UserNotifier extends StateNotifier<UserModel?> {
  final UserRepository _repository;
  final Ref _ref;

  UserNotifier(this._repository, this._ref) : super(null) {
    loadUser();
  }

  // Check and reset streak if needed (called on app start)
  Future<void> validateStreak() async {
    if (state == null) return;

    final lastDate = state!.lastTaskDate;
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastDateNormalized = DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    );

    final difference = todayNormalized.difference(lastDateNormalized).inDays;

    // Jika lewat lebih dari 1 hari dan bukan hari ini, reset streak
    if (difference > 1) {
      await updateUser((user) => user.copyWith(streak: 0));
    }
  }

  // Load user dari Hive
  Future<void> loadUser() async {
    try {
      final user = await _repository.getUser();
      if (user != null) {
        state = user;
        await validateStreak(); // Validasi streak saat app dibuka
      } else {
        // Jika belum ada user, buat default
        state = UserModel.initial('Player');
        await _repository.saveUser(state!);
      }
    } catch (e) {
      // Jika terjadi error saat load (misal data corrupt atau adapter error)
      // Buat user baru agar app tetap bisa jalan
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

    final oldLevel = state!.level;
    final newTotalXp = state!.totalXp + xpAmount;
    final newLevel = getLevelFromXp(newTotalXp);

    await updateUser((user) {
      return user.copyWith(totalXp: newTotalXp, level: newLevel);
    });

    // Check level up and trigger engine
    if (newLevel > oldLevel) {
      _ref.read(gamificationEngineProvider).onLevelUp(newLevel);
    }
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

    // Normalisasi tanggal (abaikan jam/menit/detik)
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastDateNormalized = DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    );
    final taskDateNormalized = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
    );

    // Jangan lakukan apa-apa jika task bukan hari ini (mungkin task lama yang diedit)
    if (taskDateNormalized != todayNormalized) return;

    // Jika sudah mengerjakan task hari ini, jangan tambah streak lagi
    if (lastDateNormalized == todayNormalized) return;

    final difference = todayNormalized.difference(lastDateNormalized).inDays;

    if (difference == 1) {
      // Jika nyambung dari kemarin
      await updateUser(
        (user) => user.copyWith(streak: user.streak + 1, lastTaskDate: today),
      );
    } else {
      // Jika streak putus atau baru mulai
      await updateUser((user) => user.copyWith(streak: 1, lastTaskDate: today));
    }

    // Trigger streak checked in GamificationEngine
    if (state != null) {
      _ref.read(gamificationEngineProvider).onStreakUpdated(state!.streak);
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
  return UserNotifier(repository, ref); // Inject ref
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
