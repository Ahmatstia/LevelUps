import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 10)
class AchievementModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconCodePoint;

  @HiveField(4)
  final String iconFontFamily;

  @HiveField(5)
  final int targetValue;

  @HiveField(6)
  int currentValue;

  @HiveField(7)
  bool isUnlocked;

  @HiveField(8)
  DateTime? dateUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.dateUnlocked,
    IconData icon = Icons.star,
  }) : iconCodePoint = icon.codePoint.toString(),
       iconFontFamily = icon.fontFamily ?? 'MaterialIcons';

  IconData get iconData =>
      IconData(int.parse(iconCodePoint), fontFamily: iconFontFamily);

  void updateProgress(int newValue) {
    if (isUnlocked) return;

    currentValue = newValue;
    if (currentValue >= targetValue) {
      isUnlocked = true;
      dateUnlocked = DateTime.now();
      currentValue = targetValue;
    }
  }

  void incrementProgress(int amount) {
    if (isUnlocked) return;

    currentValue += amount;
    if (currentValue >= targetValue) {
      isUnlocked = true;
      dateUnlocked = DateTime.now();
      currentValue = targetValue;
    }
  }
}
