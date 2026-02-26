import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/skill_node_model.dart';
import '../models/task_model.dart';
import 'user_provider.dart';

class SkillTreeNotifier extends StateNotifier<List<SkillNodeModel>> {
  final Box<SkillNodeModel> _box;
  final Ref _ref;

  SkillTreeNotifier(this._box, this._ref) : super([]) {
    _loadSkills();
  }

  void _loadSkills() {
    if (_box.isEmpty) {
      _initializeBaseSkills();
    } else {
      state = _box.values.toList();
    }
  }

  void _initializeBaseSkills() {
    final baseSkills = [
      // Intelligence Tree
      SkillNodeModel(
        id: 'int_reading',
        statType: StatType.intelligence,
        skillType: SkillType.passive,
        name: 'Reading Speed',
        description: 'Increases INT gained from tasks by 5% per level',
        maxLevel: 5,
        currentLevel: 0,
        costPerLevel: [1, 2, 3, 4, 5],
        effectPerLevel: [1.05, 1.10, 1.15, 1.20, 1.25],
        treePositionX: 0,
        treePositionY: 0,
      ),
      SkillNodeModel(
        id: 'int_memory',
        statType: StatType.intelligence,
        skillType: SkillType.passive,
        name: 'Eidetic Memory',
        description: 'Passive: Small chance to double INT XP',
        maxLevel: 3,
        currentLevel: 0,
        costPerLevel: [3, 5, 8],
        effectPerLevel: [1.1, 1.2, 1.3],
        parentId: 'int_reading',
        treePositionX: 0,
        treePositionY: 1,
      ),
      // Discipline Tree
      SkillNodeModel(
        id: 'disc_routine',
        statType: StatType.discipline,
        skillType: SkillType.passive,
        name: 'Morning Routine',
        description: '+10% bonus XP for tasks done before 9 AM',
        maxLevel: 3,
        currentLevel: 0,
        costPerLevel: [1, 2, 3],
        effectPerLevel: [1.1, 1.2, 1.3],
        treePositionX: 1,
        treePositionY: 0,
      ),
      // Health Tree
      SkillNodeModel(
        id: 'hp_endurance',
        statType: StatType.health,
        skillType: SkillType.passive,
        name: 'Endurance',
        description: 'Lowers Burnout Risk threshold by 10%',
        maxLevel: 3,
        currentLevel: 0,
        costPerLevel: [2, 4, 6],
        effectPerLevel: [0.9, 0.8, 0.7],
        treePositionX: 2,
        treePositionY: 0,
      ),
      // Wealth Tree
      SkillNodeModel(
        id: 'wl_invest',
        statType: StatType.wealth,
        skillType: SkillType.multiplier,
        name: 'Compound Interest',
        description: 'Gain 1% of total Wealth stat as passive daily XP',
        maxLevel: 5,
        currentLevel: 0,
        costPerLevel: [5, 8, 12, 16, 20],
        effectPerLevel: [1.01, 1.02, 1.03, 1.04, 1.05],
        treePositionX: 3,
        treePositionY: 0,
      ),
    ];

    for (var skill in baseSkills) {
      _box.put(skill.id, skill);
    }
    state = baseSkills;
  }

  bool unlockOrUpgradeSkill(String skillId) {
    final skill = _box.get(skillId);
    if (skill == null || skill.isMaxed) return false;

    // Check parent requirements
    if (skill.parentId != null) {
      final parent = _box.get(skill.parentId);
      if (parent == null || !parent.isUnlocked) {
        return false; // Parent not unlocked
      }
    }
    for (String reqId in skill.requirements) {
      final req = _box.get(reqId);
      if (req == null || !req.isUnlocked) {
        return false;
      }
    }

    final userProviderNotifier = _ref.read(userProvider.notifier);
    final user = _ref.read(userProvider);

    if (user == null) return false;

    int cost = skill.currentCost;

    if (user.skillPoints >= cost) {
      // Deduct point
      userProviderNotifier.updateUser(
        (u) => u.copyWith(skillPoints: u.skillPoints - cost),
      );

      skill.upgrade();
      _box.put(skillId, skill);
      state = _box.values.toList();
      return true;
    }

    return false;
  }
}

final skillTreeProvider =
    StateNotifierProvider<SkillTreeNotifier, List<SkillNodeModel>>((ref) {
      final box = Hive.box<SkillNodeModel>('skills');
      return SkillTreeNotifier(box, ref);
    });
