import 'package:hive/hive.dart';
import 'task_model.dart'; // To access StatType

part 'skill_node_model.g.dart';

@HiveType(typeId: 13)
class SkillNodeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final StatType statType;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String description;

  @HiveField(4)
  int currentLevel;

  @HiveField(5)
  final int maxLevel;

  @HiveField(6)
  final int baseCost;

  @HiveField(7)
  final double costMultiplier;

  @HiveField(8)
  final List<String> parentIds; // Required skills to unlock this one

  @HiveField(9)
  bool isUnlocked;

  SkillNodeModel({
    required this.id,
    required this.statType,
    required this.name,
    required this.description,
    this.currentLevel = 0,
    required this.maxLevel,
    required this.baseCost,
    this.costMultiplier = 1.5,
    this.parentIds = const [],
    this.isUnlocked = false,
  });

  int get currentCost {
    if (currentLevel >= maxLevel) return 0;
    // Calculation: baseCost * (costMultiplier ^ currentLevel)
    double cost = baseCost.toDouble();
    for (int i = 0; i < currentLevel; i++) {
      cost *= costMultiplier;
    }
    return cost.round();
  }

  bool get isMaxed => currentLevel >= maxLevel;

  void upgrade() {
    if (!isMaxed) {
      currentLevel++;
      isUnlocked = true;
    }
  }
}
