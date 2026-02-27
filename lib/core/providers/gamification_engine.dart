import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import 'achievement_provider.dart';
import 'quest_provider.dart';
import 'user_provider.dart';

/// The GamificationEngine acts as a central listener and event bus.
/// It observes state changes (like task completions) and triggers RPG logic.
final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  return GamificationEngine(ref);
});

class GamificationEngine {
  final Ref _ref;

  GamificationEngine(this._ref);

  /// Called whenever a task is marked as completed
  Future<void> onTaskCompleted(TaskModel task) async {
    final userNotifier = _ref.read(userProvider.notifier);
    final achievementNotifier = _ref.read(achievementProvider.notifier);
    final questNotifier = _ref.read(questProvider.notifier);

    final now = task.completedAt ?? DateTime.now();

    // 1. Process Quests
    final quests = _ref.read(questProvider);
    for (var quest in quests) {
      if (!quest.isCompleted) {
        bool justCompleted = false;

        // Routing berdasarkan targetStat — lebih robust daripada string title matching
        if (quest.targetStat == 'tasks') {
          // Semua quest yang butuh menyelesaikan task (daily complete, weekly warrior, dll)
          justCompleted = questNotifier.updateProgress(quest.id, 1);
        } else if (quest.targetStat == 'hard_tasks' &&
            task.difficulty == TaskDifficulty.hard) {
          // Quest yang butuh task sulit (Focus Mode, dll)
          justCompleted = questNotifier.updateProgress(quest.id, 1);
        }

        // Claim rewards immediately only if this specific action completed it
        if (justCompleted) {
          await userNotifier.addXp(quest.xpReward);
        }
      }
    }

    // 2. Process Achievements
    achievementNotifier.updateProgress('completionist_1', 1);

    if (now.hour < 8) {
      achievementNotifier.updateProgress('early_bird', 1);
    }

    if (now.hour >= 22) {
      achievementNotifier.updateProgress('night_owl', 1);
    }
  }

  /// Called when the user levels up
  void onLevelUp(int newLevel) {
    final userNotifier = _ref.read(userProvider.notifier);
    final user = _ref.read(userProvider);

    if (user != null) {
      // Grand 1 skill point per level
      userNotifier.updateUser(
        (u) => u.copyWith(skillPoints: u.skillPoints + 1),
      );
    }
  }

  /// Called when a streak is updated
  void onStreakUpdated(int currentStreak) {
    final achievementNotifier = _ref.read(achievementProvider.notifier);
    achievementNotifier.updateProgress(
      'streak_master_1',
      currentStreak,
      isAbsolute: true,
    );
  }
}
