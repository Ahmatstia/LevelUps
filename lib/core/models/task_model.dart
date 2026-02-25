import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
enum TaskDifficulty {
  @HiveField(0)
  easy,

  @HiveField(1)
  medium,

  @HiveField(2)
  hard;

  int get xpValue {
    switch (this) {
      case TaskDifficulty.easy:
        return 10;
      case TaskDifficulty.medium:
        return 20;
      case TaskDifficulty.hard:
        return 30;
    }
  }

  String get displayName {
    switch (this) {
      case TaskDifficulty.easy:
        return 'Easy';
      case TaskDifficulty.medium:
        return 'Medium';
      case TaskDifficulty.hard:
        return 'Hard';
    }
  }
}

@HiveType(typeId: 2)
enum StatType {
  @HiveField(0)
  intelligence,

  @HiveField(1)
  discipline,

  @HiveField(2)
  health,

  @HiveField(3)
  wealth;

  String get displayName {
    switch (this) {
      case StatType.intelligence:
        return 'Intelligence';
      case StatType.discipline:
        return 'Discipline';
      case StatType.health:
        return 'Health';
      case StatType.wealth:
        return 'Wealth';
    }
  }
}

@HiveType(typeId: 3)
class TaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final TaskDifficulty difficulty;

  @HiveField(4)
  final StatType statType;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.statType,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  factory TaskModel.create({
    required String title,
    required String description,
    required TaskDifficulty difficulty,
    required StatType statType,
  }) {
    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      difficulty: difficulty,
      statType: statType,
      isCompleted: false,
      createdAt: DateTime.now(),
      completedAt: null,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskDifficulty? difficulty,
    StatType? statType,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      statType: statType ?? this.statType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
