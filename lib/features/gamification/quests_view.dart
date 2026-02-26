import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/providers/quest_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/game_theme.dart';
import '../../core/widgets/rpg_status_bar.dart';

class QuestsView extends ConsumerWidget {
  const QuestsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final l10n = ref.watch(l10nProvider);

    final sortedQuests = [...quests]
      ..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return a.type.index.compareTo(b.type.index);
      });

    if (sortedQuests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'NO ACTIVE QUESTS',
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: sortedQuests.length,
      itemBuilder: (context, index) {
        final quest = sortedQuests[index];
        final progress = (quest.currentValue / quest.targetValue).clamp(
          0.0,
          1.0,
        );
        final isDone = quest.isCompleted;
        final accentColor = isDone
            ? GameTheme.staminaGreen
            : GameTheme.neonPink;

        return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GameTheme.surface,
                border: Border.all(
                  color: accentColor.withValues(alpha: isDone ? 0.5 : 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quest icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.assignment_outlined,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                quest.title,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDone
                                      ? Colors.grey[500]
                                      : Colors.white,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: GameTheme.goldYellow.withValues(
                                  alpha: 0.1,
                                ),
                                border: Border.all(
                                  color: GameTheme.goldYellow.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                '+${quest.xpReward} XP',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: GameTheme.goldYellow,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quest.description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // RPG Progress Bar
                        Row(
                          children: [
                            Expanded(
                              child: RpgStatusBar(
                                value: progress,
                                barColor: accentColor,
                                height: 12,
                                segments: quest.targetValue.clamp(2, 10),
                                animate: !isDone,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${quest.currentValue}/${quest.targetValue}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),

                        if (quest.expiresAt != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 10,
                                color: Colors.red[300],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${l10n.get('quest_expires')} ${DateFormat('MMM dd, hh:mm a').format(quest.expiresAt!)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: Colors.red[300],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate(delay: (index * 50).ms)
            .slideX(begin: 0.2, duration: 280.ms)
            .fadeIn();
      },
    );
  }
}
