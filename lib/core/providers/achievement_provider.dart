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
        category: AchievementCategory.productivity,
        rarity: AchievementRarity.rare,
        iconData: 'wb_sunny',
        targetValue: 10,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 100,
      ),
      AchievementModel(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete 10 tasks after 10 PM',
        category: AchievementCategory.productivity,
        rarity: AchievementRarity.rare,
        iconData: 'nights_stay',
        targetValue: 10,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 100,
      ),
      AchievementModel(
        id: 'streak_master_1',
        title: 'Streak Starter',
        description: 'Reach a 7-day streak',
        category: AchievementCategory.streak,
        rarity: AchievementRarity.common,
        iconData: 'local_fire_department',
        targetValue: 7,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 75,
      ),
      AchievementModel(
        id: 'completionist_1',
        title: 'Getting Started',
        description: 'Complete 50 tasks',
        category: AchievementCategory.tasks,
        rarity: AchievementRarity.common,
        iconData: 'check_circle_outline',
        targetValue: 50,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 150,
      ),
      AchievementModel(
        id: 'balanced_life',
        title: 'Balanced Life',
        description: 'Level up all 4 stats to level 5+',
        category: AchievementCategory.stats,
        rarity: AchievementRarity.epic,
        iconData: 'balance',
        targetValue: 4,
        currentValue: 0,
        isUnlocked: false,
        xpReward: 500,
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
      achievement.currentValue = progressToAdd;
    } else {
      achievement.currentValue += progressToAdd;
    }

    // Check if target reached
    if (achievement.currentValue >= achievement.targetValue) {
      achievement.unlock();
    }

    _box.put(achievementId, achievement);

    // Log
    if (achievement.isUnlocked) {
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
