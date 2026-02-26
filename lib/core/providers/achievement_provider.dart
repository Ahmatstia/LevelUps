import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/achievement_model.dart';
import 'package:flutter/material.dart';

class AchievementNotifier extends StateNotifier<List<AchievementModel>> {
  final Box<AchievementModel> _box;

  AchievementNotifier(this._box) : super([]) {
    _loadAchievements();
  }

  void _loadAchievements() {
    if (_box.isEmpty) {
      _initializeBaseAchievements();
    } else {
      state = _box.values.toList();
    }
  }

  void _initializeBaseAchievements() {
    final baseAchievements = [
      AchievementModel(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete 10 tasks before 8 AM',
        targetValue: 10,
        icon: Icons.wb_sunny,
      ),
      AchievementModel(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete 10 tasks after 10 PM',
        targetValue: 10,
        icon: Icons.nights_stay,
      ),
      AchievementModel(
        id: 'streak_master_1',
        title: 'Streak Starter',
        description: 'Reach a 7-day streak',
        targetValue: 7,
        icon: Icons.local_fire_department,
      ),
      AchievementModel(
        id: 'completionist_1',
        title: 'Getting Started',
        description: 'Complete 50 tasks',
        targetValue: 50,
        icon: Icons.check_circle_outline,
      ),
      AchievementModel(
        id: 'balanced_life',
        title: 'Balanced Life',
        description: 'Level up all 4 stats to level 5+',
        targetValue: 4, // 4 stats need to reach level 5
        icon: Icons.balance,
      ),
    ];

    for (var achievement in baseAchievements) {
      _box.put(achievement.id, achievement);
    }
    state = baseAchievements;
  }

  void updateProgress(
    String achievementId,
    int progressToAdd, {
    bool isAbsolute = false,
  }) {
    final achievement = _box.get(achievementId);
    if (achievement == null || achievement.isUnlocked) return;

    if (isAbsolute) {
      achievement.updateProgress(progressToAdd);
    } else {
      achievement.incrementProgress(progressToAdd);
    }

    achievement.save();

    // Check if it just unlocked
    if (achievement.isUnlocked) {
      // We can trigger a UI notification here through another mechanism
      debugPrint('🏆 ACHIEVEMENT UNLOCKED: ${achievement.title}!');
    }

    // Refresh state
    state = _box.values.toList();
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, List<AchievementModel>>((ref) {
      final box = Hive.box<AchievementModel>('achievements');
      return AchievementNotifier(box);
    });
