import 'package:hive/hive.dart';

part 'quest_model.g.dart';

@HiveType(typeId: 15)
enum QuestType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  special,
}

@HiveType(typeId: 16)
enum QuestDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard,
  @HiveField(3)
  epic,
}

@HiveType(typeId: 11)
class QuestModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final QuestType type;

  @HiveField(4)
  final QuestDifficulty difficulty;

  @HiveField(5)
  final String targetStat;

  @HiveField(6)
  final int targetValue;

  @HiveField(7)
  int currentValue;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  bool isClaimed;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  DateTime? expiresAt;

  @HiveField(12)
  final int xpReward;

  QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.targetStat,
    required this.targetValue,
    required this.currentValue,
    required this.isCompleted,
    required this.isClaimed,
    required this.createdAt,
    this.expiresAt,
    this.xpReward = 0,
  });

  void updateProgress(int value) {
    currentValue += value;
    if (currentValue >= targetValue && !isCompleted) {
      isCompleted = true;
    }
  }

  void claim() {
    isClaimed = true;
  }
}
