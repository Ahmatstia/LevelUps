import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 13)
enum AchievementCategory {
  @HiveField(0)
  productivity,
  @HiveField(1)
  streak,
  @HiveField(2)
  tasks,
  @HiveField(3)
  stats,
  @HiveField(4)
  social,
  @HiveField(5)
  hidden,
}

@HiveType(typeId: 14)
enum AchievementRarity {
  @HiveField(0)
  common,
  @HiveField(1)
  rare,
  @HiveField(2)
  epic,
  @HiveField(3)
  legendary,
}

@HiveType(typeId: 10)
class AchievementModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final AchievementCategory category;

  @HiveField(4)
  final AchievementRarity rarity;

  @HiveField(5)
  final String iconData;

  @HiveField(6)
  final int targetValue;

  @HiveField(7)
  int currentValue;

  @HiveField(8)
  bool isUnlocked;

  @HiveField(9)
  DateTime? dateUnlocked;

  @HiveField(10)
  final int xpReward;

  @HiveField(11)
  final String? hiddenCondition;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.rarity,
    required this.iconData,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    this.dateUnlocked,
    required this.xpReward,
    this.hiddenCondition,
  });

  double get progress => currentValue / targetValue;

  void unlock() {
    isUnlocked = true;
    dateUnlocked = DateTime.now();
    currentValue = targetValue;
  }
}
