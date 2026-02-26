import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/skill_tree_provider.dart';
import '../../core/models/skill_node_model.dart';

class SkillTreeView extends ConsumerWidget {
  const SkillTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillTreeProvider);
    final notifier = ref.read(skillTreeProvider.notifier);

    if (skills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group skills by StatType for a tiered list view
    // (A true tree view requires custom painting, using categorized lists here)
    final Map<String, List<SkillNodeModel>> groupedSkills = {};
    for (var skill in skills) {
      final statName = skill.statType.name.toUpperCase();
      groupedSkills.putIfAbsent(statName, () => []).add(skill);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedSkills.length,
      itemBuilder: (context, index) {
        final statName = groupedSkills.keys.elementAt(index);
        final statSkills = groupedSkills[statName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '$statName SKILLS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            ...statSkills.map(
              (skill) => _buildSkillCard(context, skill, ref, notifier),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildSkillCard(
    BuildContext context,
    SkillNodeModel skill,
    WidgetRef ref,
    SkillTreeNotifier notifier,
  ) {
    // We use the central notifier which handles requirements and points
    void onPressedAction() {
      final success = notifier.unlockOrUpgradeSkill(skill.id);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough Skill Points or missing requirements!'),
          ),
        );
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: skill.isUnlocked ? 2 : 0,
      color: skill.isUnlocked ? Colors.white : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: skill.isMaxed
              ? Colors.amber
              : (skill.isUnlocked
                    ? Colors.blue.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon area
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: skill.isUnlocked
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                skill.isMaxed
                    ? Icons.star
                    : (skill.isUnlocked
                          ? Icons.auto_awesome
                          : Icons.lock_outline),
                color: skill.isMaxed
                    ? Colors.amber
                    : (skill.isUnlocked ? Colors.blue : Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          skill.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: skill.isUnlocked
                                ? Colors.black87
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: skill.isMaxed
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Lv ${skill.currentLevel}/${skill.maxLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: skill.isMaxed
                                ? Colors.amber[800]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (!skill.isMaxed) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.stars, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Cost: ${skill.currentCost} SP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Upgrade Button
            if (!skill.isMaxed) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onPressedAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(60, 36),
                ),
                child: Text(skill.currentLevel == 0 ? 'Unlock' : 'Upgrade'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
