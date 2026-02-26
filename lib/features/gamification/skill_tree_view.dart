import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/skill_tree_provider.dart';
import '../../core/models/skill_node_model.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/game_theme.dart';

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
              style: GameTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontSize: 10,
                letterSpacing: 2,
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
                    style: GameTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 8,
                      color: headerColor,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: headerColor.withValues(alpha: 0.3),
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
        return GameTheme.manaBlue;
      case 'DISCIPLINE':
        return GameTheme.staminaGreen;
      case 'HEALTH':
        return GameTheme.hpRed;
      case 'WEALTH':
        return GameTheme.goldYellow;
      default:
        return GameTheme.neonCyan;
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
            backgroundColor: GameTheme.surface,
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
        ? GameTheme.goldYellow
        : isUnlocked
        ? GameTheme.neonCyan
        : Colors.grey[700]!;

    return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: GameTheme.surface,
            border: Border.all(
              color: isMaxed
                  ? GameTheme.goldYellow.withValues(alpha: 0.6)
                  : isUnlocked
                  ? GameTheme.neonCyan.withValues(alpha: 0.3)
                  : Colors.white12,
              width: isUnlocked ? 1.5 : 1.0,
            ),
            boxShadow: isUnlocked || isMaxed
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: isUnlocked || isMaxed
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isMaxed
                      ? Icons.star
                      : isUnlocked
                      ? Icons.auto_awesome
                      : Icons.lock_outline,
                  color: accentColor,
                  size: 22,
                  shadows: isUnlocked || isMaxed
                      ? [Shadow(color: accentColor, blurRadius: 10)]
                      : null,
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
                            style: GameTheme.textTheme.bodySmall?.copyWith(
                              fontSize: 9,
                              letterSpacing: 0.5,
                              color: isUnlocked
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'LV ${skill.currentLevel}/${skill.maxLevel}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
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
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (!skill.isMaxed) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            size: 12,
                            color: GameTheme.goldYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.get('skill_cost')}: ${skill.currentCost} SP',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: GameTheme.goldYellow,
                              fontWeight: FontWeight.w500,
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
                      color: GameTheme.neonCyan.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isUnlocked
                            ? GameTheme.neonCyan
                            : Colors.grey[700]!,
                        width: 1.5,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: GameTheme.neonCyan.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      skill.currentLevel == 0
                          ? l10n.get('skill_unlock').toUpperCase()
                          : l10n.get('skill_upgrade').toUpperCase(),
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        letterSpacing: 1,
                        color: isUnlocked
                            ? GameTheme.neonCyan
                            : Colors.grey[600],
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
