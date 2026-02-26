import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/quest_model.dart';

class QuestNotifier extends StateNotifier<List<QuestModel>> {
  final Box<QuestModel> _box;

  QuestNotifier(this._box) : super([]) {
    _loadAndGenerateQuests();
  }

  void _loadAndGenerateQuests() {
    final now = DateTime.now();

    // Remove expired quests
    final keysToRemove = <dynamic>[];
    for (var i = 0; i < _box.length; i++) {
      final quest = _box.getAt(i);
      if (quest != null &&
          quest.expiresAt != null &&
          quest.expiresAt!.isBefore(now)) {
        keysToRemove.add(_box.keyAt(i));
      }
    }
    for (var key in keysToRemove) {
      _box.delete(key);
    }

    final currentQuests = _box.values.toList();

    // Check if we need to generate daily quests
    final dailyQuests = currentQuests
        .where((q) => q.type == QuestType.daily)
        .toList();
    if (dailyQuests.isEmpty) {
      _generateDailyQuests(now);
    }

    // Check if we need to generate weekly quests
    final weeklyQuests = currentQuests
        .where((q) => q.type == QuestType.weekly)
        .toList();
    if (weeklyQuests.isEmpty) {
      _generateWeeklyQuests(now);
    }

    state = _box.values.toList();
  }

  void _generateDailyQuests(DateTime now) {
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final q1 = QuestModel(
      id: 'daily_${now.millisecondsSinceEpoch}_1',
      type: QuestType.daily,
      difficulty: QuestDifficulty.easy,
      targetStat: 'tasks',
      title: 'Complete 3 tasks',
      description: 'Finish any 3 tasks today',
      targetValue: 3,
      currentValue: 0,
      isCompleted: false,
      isClaimed: false,
      createdAt: now,
      xpReward: 50,
      expiresAt: endOfDay,
    );

    final q2 = QuestModel(
      id: 'daily_${now.millisecondsSinceEpoch}_2',
      type: QuestType.daily,
      difficulty: QuestDifficulty.medium,
      targetStat: 'hard_tasks',
      title: 'Focus Mode',
      description: 'Complete 1 Hard difficulty task',
      targetValue: 1,
      currentValue: 0,
      isCompleted: false,
      isClaimed: false,
      createdAt: now,
      xpReward: 100,
      expiresAt: endOfDay,
    );

    _box.put(q1.id, q1);
    _box.put(q2.id, q2);
  }

  void _generateWeeklyQuests(DateTime now) {
    final endOfWeek = now
        .add(Duration(days: 7 - now.weekday))
        .copyWith(hour: 23, minute: 59, second: 59);

    final q1 = QuestModel(
      id: 'weekly_${now.millisecondsSinceEpoch}_1',
      type: QuestType.weekly,
      difficulty: QuestDifficulty.hard,
      targetStat: 'tasks',
      title: 'Weekly Warrior',
      description: 'Complete 20 tasks this week',
      targetValue: 20,
      currentValue: 0,
      isCompleted: false,
      isClaimed: false,
      createdAt: now,
      xpReward: 500,
      expiresAt: endOfWeek,
    );

    _box.put(q1.id, q1);
  }

  bool updateProgress(
    String questId,
    int progressToAdd, {
    bool isAbsolute = false,
  }) {
    final quest = _box.get(questId);
    if (quest == null || quest.isCompleted) return false;

    if (isAbsolute) {
      quest.currentValue = progressToAdd;
    } else {
      quest.currentValue += progressToAdd;
    }

    // Check completion
    if (quest.currentValue >= quest.targetValue && !quest.isCompleted) {
      quest.isCompleted = true;
    }

    _box.put(questId, quest);
    state = _box.values.toList();

    // Return true ONLY IF the quest was just completed by this action
    return quest.isCompleted;
  }
}

final questProvider = StateNotifierProvider<QuestNotifier, List<QuestModel>>((
  ref,
) {
  final box = Hive.box<QuestModel>('quests');
  return QuestNotifier(box);
});
