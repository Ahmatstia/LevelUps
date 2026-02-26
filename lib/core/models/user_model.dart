import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int level;

  @HiveField(2)
  final int totalXp;

  @HiveField(3, defaultValue: 0)
  final int streak;

  @HiveField(4, defaultValue: 0)
  final int intelligence;

  @HiveField(5, defaultValue: 0)
  final int discipline;

  @HiveField(6, defaultValue: 0)
  final int health;

  @HiveField(7, defaultValue: 0)
  final int wealth;

  @HiveField(8)
  final DateTime lastTaskDate;

  UserModel({
    required this.name,
    required this.level,
    required this.totalXp,
    required this.streak,
    required this.intelligence,
    required this.discipline,
    required this.health,
    required this.wealth,
    required this.lastTaskDate,
  });

  // Factory untuk user baru
  factory UserModel.initial(String name) {
    return UserModel(
      name: name,
      level: 1,
      totalXp: 0,
      streak: 0,
      intelligence: 0,
      discipline: 0,
      health: 0,
      wealth: 0,
      lastTaskDate: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  // CopyWith method untuk update data
  UserModel copyWith({
    String? name,
    int? level,
    int? totalXp,
    int? streak,
    int? intelligence,
    int? discipline,
    int? health,
    int? wealth,
    DateTime? lastTaskDate,
  }) {
    return UserModel(
      name: name ?? this.name,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      intelligence: intelligence ?? this.intelligence,
      discipline: discipline ?? this.discipline,
      health: health ?? this.health,
      wealth: wealth ?? this.wealth,
      lastTaskDate: lastTaskDate ?? this.lastTaskDate,
    );
  }
}
