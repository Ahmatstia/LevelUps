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

@HiveType(typeId: 4)
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

@HiveType(typeId: 5)
enum RecurringType {
  @HiveField(0)
  none,

  @HiveField(1)
  daily,

  @HiveField(2)
  weekly,

  @HiveField(3)
  monthly;

  String get displayName {
    switch (this) {
      case RecurringType.none:
        return 'One time';
      case RecurringType.daily:
        return 'Daily';
      case RecurringType.weekly:
        return 'Weekly';
      case RecurringType.monthly:
        return 'Monthly';
    }
  }
}

@HiveType(typeId: 6)
enum EnergyLevel {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high;

  String get displayName {
    switch (this) {
      case EnergyLevel.low:
        return '⚡ Low';
      case EnergyLevel.medium:
        return '⚡⚡ Medium';
      case EnergyLevel.high:
        return '⚡⚡⚡ High';
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

  // Due Date
  @HiveField(8)
  final DateTime? dueDate;

  // Recurring type
  @HiveField(9)
  final RecurringType? recurringType;

  // Energy level
  @HiveField(10)
  final EnergyLevel? energyLevel;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.statType,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.recurringType,
    this.energyLevel,
  });

  // Factory untuk task baru
  factory TaskModel.create({
    required String title,
    required String description,
    required TaskDifficulty difficulty,
    required StatType statType,
    DateTime? dueDate,
    RecurringType? recurringType,
    EnergyLevel? energyLevel,
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
      dueDate: dueDate,
      recurringType: recurringType,
      energyLevel: energyLevel,
    );
  }

  // CopyWith untuk update task
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskDifficulty? difficulty,
    StatType? statType,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    RecurringType? recurringType,
    EnergyLevel? energyLevel,
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
      dueDate: dueDate ?? this.dueDate,
      recurringType: recurringType ?? this.recurringType,
      energyLevel: energyLevel ?? this.energyLevel,
    );
  }

  // Helper methods untuk due date (tanpa UI)
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    return dueDate!.isAfter(now) && dueDate!.isBefore(weekLater);
  }

  Duration? get timeLeft {
    if (dueDate == null || isCompleted) return null;
    return dueDate!.difference(DateTime.now());
  }

  String get timeLeftText {
    final timeLeft = this.timeLeft;
    if (timeLeft == null) return 'No deadline';
    if (timeLeft.isNegative) return 'Overdue';

    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays}d ${timeLeft.inHours % 24}h left';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m left';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes}m left';
    } else {
      return 'Due soon';
    }
  }

  // Status untuk filtering
  String get status {
    if (isCompleted) return 'completed';
    if (isOverdue) return 'overdue';
    if (isDueToday) return 'today';
    if (isDueThisWeek) return 'thisWeek';
    return 'upcoming';
  }
}
