import 'package:hive/hive.dart';

part 'quest_model.g.dart';

@HiveType(typeId: 11)
enum QuestType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
}

@HiveType(typeId: 12)
class QuestModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final QuestType type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final int rewardXp;

  @HiveField(5)
  final int targetValue;

  @HiveField(6)
  int currentValue;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  DateTime? expiresAt;

  QuestModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
    this.expiresAt,
  });

  void updateProgress(int newValue) {
    if (isCompleted) return;

    currentValue = newValue;
    if (currentValue >= targetValue) {
      isCompleted = true;
      currentValue = targetValue;
    }
  }

  void incrementProgress(int amount) {
    if (isCompleted) return;

    currentValue += amount;
    if (currentValue >= targetValue) {
      isCompleted = true;
      currentValue = targetValue;
    }
  }
}
