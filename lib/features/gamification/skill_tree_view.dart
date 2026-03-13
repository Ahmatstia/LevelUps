import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/skill_tree_provider.dart';
import '../../core/models/skill_node_model.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';

class SkillTreeView extends ConsumerWidget {
  const SkillTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillTreeProvider);
    final notifier = ref.read(skillTreeProvider.notifier);
    final l10n = ref.watch(l10nProvider);

    if (skills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'NO SKILLS AVAILABLE',
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    // Group skills by StatType
    final Map<String, List<SkillNodeModel>> groupedSkills = {};
    for (var skill in skills) {
      final statName = skill.statType.name.toUpperCase();
      groupedSkills.putIfAbsent(statName, () => []).add(skill);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: groupedSkills.length,
      itemBuilder: (context, index) {
        final statName = groupedSkills.keys.elementAt(index);
        final statSkills = groupedSkills[statName]!;
        final Color headerColor = _getStatColor(statName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: index == 0 ? 0 : 20),
              child: Row(
                children: [
                  Text(
                    '$statName ${l10n.get('rpg_tab_skills').toUpperCase()}',
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      color: headerColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            ...statSkills.asMap().entries.map(
              (e) =>
                  _buildSkillCard(context, e.value, ref, notifier, l10n, e.key),
            ),
          ],
        );
      },
    );
  }

  Color _getStatColor(String statName) {
    switch (statName) {
      case 'INTELLIGENCE':
        return AppTheme.manaBlue;
      case 'DISCIPLINE':
        return AppTheme.staminaGreen;
      case 'HEALTH':
        return AppTheme.hpRed;
      case 'WEALTH':
        return AppTheme.goldYellow;
      default:
        return AppTheme.primary;
    }
  }

  Widget _buildSkillCard(
    BuildContext context,
    SkillNodeModel skill,
    WidgetRef ref,
    SkillTreeNotifier notifier,
    dynamic l10n,
    int animIndex,
  ) {
    void onPressedAction() {
      final success = notifier.unlockOrUpgradeSkill(skill.id);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surface,
            content: Text(
              l10n.get('skill_req_not_met'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }

    final isMaxed = skill.isMaxed;
    final isUnlocked = skill.isUnlocked;
    final accentColor = isMaxed
        ? AppTheme.goldYellow
        : isUnlocked
        ? AppTheme.primary
        : Colors.grey[400]!;

    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isMaxed
                  ? AppTheme.goldYellow.withOpacity(0.4)
                  : isUnlocked
                  ? AppTheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: isUnlocked ? 1.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isMaxed
                      ? Icons.star
                      : isUnlocked
                      ? Icons.auto_awesome
                      : Icons.lock_outline,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

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
                            skill.name.toUpperCase(),
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              color: isUnlocked
                                  ? AppTheme.primaryDark
                                  : Colors.grey[500],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LV ${skill.currentLevel}/${skill.maxLevel}',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skill.description,
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (!skill.isMaxed) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: 12,
                            color: AppTheme.goldYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.get('skill_cost')}: ${skill.currentCost} SP',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.goldYellow,
                              fontWeight: FontWeight.bold,
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
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onPressedAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppTheme.primary : AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isUnlocked
                            ? AppTheme.primary
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      skill.currentLevel == 0
                          ? l10n.get('skill_unlock').toUpperCase()
                          : l10n.get('skill_upgrade').toUpperCase(),
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: isUnlocked
                            ? Colors.white
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
        .animate(delay: (animIndex * 60).ms)
        .slideX(begin: 0.2, duration: 280.ms)
        .fadeIn();
  }
}
