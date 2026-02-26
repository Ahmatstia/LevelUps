import 'package:hive/hive.dart';
import 'subtask_model.dart';

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

@HiveType(typeId: 9)
enum QuadrantType {
  @HiveField(0)
  doFirst,

  @HiveField(1)
  schedule,

  @HiveField(2)
  delegate,

  @HiveField(3)
  eliminate;

  String get displayName {
    switch (this) {
      case QuadrantType.doFirst:
        return 'Do First';
      case QuadrantType.schedule:
        return 'Schedule';
      case QuadrantType.delegate:
        return 'Delegate';
      case QuadrantType.eliminate:
        return 'Eliminate';
    }
  }

  // Hapus Color dari sini, akan ditangani di UI
  String get description {
    switch (this) {
      case QuadrantType.doFirst:
        return 'Important & Urgent - Do now';
      case QuadrantType.schedule:
        return 'Important & Not Urgent - Schedule later';
      case QuadrantType.delegate:
        return 'Not Important & Urgent - Delegate if possible';
      case QuadrantType.eliminate:
        return 'Not Important & Not Urgent - Eliminate';
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

  @HiveField(8)
  final DateTime? dueDate;

  @HiveField(9)
  final RecurringType? recurringType;

  @HiveField(10)
  final EnergyLevel? energyLevel;

  @HiveField(11, defaultValue: QuadrantType.doFirst)
  final QuadrantType quadrant;

  @HiveField(12, defaultValue: [])
  final List<SubtaskModel> subtasks;

  @HiveField(13, defaultValue: [])
  final List<String> tagIds;

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
    this.quadrant = QuadrantType.doFirst,
    this.subtasks = const [],
    this.tagIds = const [],
  });

  factory TaskModel.create({
    required String title,
    required String description,
    required TaskDifficulty difficulty,
    required StatType statType,
    DateTime? dueDate,
    RecurringType? recurringType,
    EnergyLevel? energyLevel,
    QuadrantType quadrant = QuadrantType.doFirst,
    List<SubtaskModel> subtasks = const [],
    List<String> tagIds = const [],
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
      quadrant: quadrant,
      subtasks: subtasks,
      tagIds: tagIds,
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
    DateTime? dueDate,
    RecurringType? recurringType,
    EnergyLevel? energyLevel,
    QuadrantType? quadrant,
    List<SubtaskModel>? subtasks,
    List<String>? tagIds,
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
      quadrant: quadrant ?? this.quadrant,
      subtasks: subtasks ?? this.subtasks,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  int get completedSubtasksCount {
    return subtasks.where((s) => s.isCompleted).length;
  }

  double get subtasksProgress {
    if (subtasks.isEmpty) return 1.0;
    return completedSubtasksCount / subtasks.length;
  }

  bool get allSubtasksCompleted {
    if (subtasks.isEmpty) return false;
    return completedSubtasksCount == subtasks.length;
  }

  bool get isFullyCompleted {
    if (subtasks.isEmpty) return isCompleted;
    return allSubtasksCompleted;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();

    // Normalisasi hari
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    // Jika deadline adalah hari kemarin atau lebih lama
    if (dueDay.isBefore(today)) return true;

    // Jika deadline hari ini, dan waktunya sudah lewat
    return dueDate!.isBefore(now);
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

  String get status {
    if (isCompleted) return 'completed';
    if (isOverdue) return 'overdue';
    if (isDueToday) return 'today';
    if (isDueThisWeek) return 'thisWeek';
    return 'upcoming';
  }
}
