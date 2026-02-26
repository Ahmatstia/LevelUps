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
        name: 'Reading Speed',
        description: 'Increases INT gained from tasks by 5% per level',
        maxLevel: 5,
        baseCost: 1,
      ),
      SkillNodeModel(
        id: 'int_memory',
        statType: StatType.intelligence,
        name: 'Eidetic Memory',
        description: 'Passive: Small chance to double INT XP',
        maxLevel: 3,
        baseCost: 3,
        parentIds: ['int_reading'],
      ),
      // Discipline Tree
      SkillNodeModel(
        id: 'disc_routine',
        statType: StatType.discipline,
        name: 'Morning Routine',
        description: '+10% bonus XP for tasks done before 9 AM',
        maxLevel: 3,
        baseCost: 1,
      ),
      // Health Tree
      SkillNodeModel(
        id: 'hp_endurance',
        statType: StatType.health,
        name: 'Endurance',
        description: 'Lowers Burnout Risk threshold by 10%',
        maxLevel: 3,
        baseCost: 2,
      ),
      // Wealth Tree
      SkillNodeModel(
        id: 'wl_invest',
        statType: StatType.wealth,
        name: 'Compound Interest',
        description: 'Gain 1% of total Wealth stat as passive daily XP',
        maxLevel: 5,
        baseCost: 5,
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
    for (String parentId in skill.parentIds) {
      final parent = _box.get(parentId);
      if (parent == null || !parent.isUnlocked) {
        return false; // Parent not unlocked
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
      skill.save();
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
