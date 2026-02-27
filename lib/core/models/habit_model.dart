import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 20)
enum HabitFrequency {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
    }
  }
}

@HiveType(typeId: 21)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String statType; // 'intelligence' | 'discipline' | 'health' | 'wealth'

  @HiveField(4)
  HabitFrequency frequency;

  @HiveField(5)
  int currentStreak;

  @HiveField(6)
  int bestStreak;

  @HiveField(7)
  DateTime? lastCheckinDate;

  @HiveField(8)
  int xpReward;

  @HiveField(9)
  List<DateTime> completedDates;

  @HiveField(10)
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.statType,
    required this.frequency,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastCheckinDate,
    required this.xpReward,
    List<DateTime>? completedDates,
    required this.createdAt,
  }) : completedDates = completedDates ?? [];

  factory HabitModel.create({
    required String title,
    required String description,
    required String statType,
    required HabitFrequency frequency,
    int xpReward = 15,
  }) {
    return HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      statType: statType,
      frequency: frequency,
      xpReward: xpReward,
      createdAt: DateTime.now(),
    );
  }

  bool get isCheckedInToday {
    if (lastCheckinDate == null) return false;
    final now = DateTime.now();
    return lastCheckinDate!.year == now.year &&
        lastCheckinDate!.month == now.month &&
        lastCheckinDate!.day == now.day;
  }

  bool get isStreakAlive {
    if (lastCheckinDate == null) return false;
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastDate = DateTime(
      lastCheckinDate!.year,
      lastCheckinDate!.month,
      lastCheckinDate!.day,
    );
    return lastDate == yesterday ||
        (lastDate.year == now.year &&
            lastDate.month == now.month &&
            lastDate.day == now.day);
  }

  int get totalCheckins => completedDates.length;
}
