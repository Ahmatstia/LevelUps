import 'package:hive/hive.dart';
import 'task_model.dart';

part 'skill_node_model.g.dart';

@HiveType(typeId: 17)
enum SkillType {
  @HiveField(0)
  passive,
  @HiveField(1)
  active,
  @HiveField(2)
  multiplier,
  @HiveField(3)
  unlock,
}

@HiveType(typeId: 12)
class SkillNodeModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final StatType statType;

  @HiveField(4)
  final SkillType skillType;

  @HiveField(5)
  final int maxLevel;

  @HiveField(6)
  int currentLevel;

  @HiveField(7)
  final List<int> costPerLevel;

  @HiveField(8)
  final List<double> effectPerLevel;

  @HiveField(9)
  final String? parentId;

  @HiveField(10)
  final List<String> requirements;

  @HiveField(11)
  final int treePositionX;

  @HiveField(12)
  final int treePositionY;

  SkillNodeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.statType,
    required this.skillType,
    required this.maxLevel,
    required this.currentLevel,
    required this.costPerLevel,
    required this.effectPerLevel,
    this.parentId,
    this.requirements = const [],
    required this.treePositionX,
    required this.treePositionY,
  });

  bool get isMaxed => currentLevel >= maxLevel;

  bool get isUnlocked => currentLevel > 0;

  int get currentCost {
    if (isMaxed) return 0;
    return costPerLevel[currentLevel];
  }

  double get currentEffect {
    if (currentLevel == 0) return 1.0;
    return effectPerLevel[currentLevel - 1];
  }

  bool canUpgrade(int availablePoints) {
    if (isMaxed) return false;
    return availablePoints >= currentCost;
  }

  void upgrade() {
    if (currentLevel < maxLevel) {
      currentLevel++;
    }
  }
}
