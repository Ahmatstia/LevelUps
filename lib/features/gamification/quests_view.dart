import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/quest_provider.dart';
import '../../core/providers/locale_provider.dart';
import 'package:intl/intl.dart';

class QuestsView extends ConsumerWidget {
  const QuestsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final l10n = ref.watch(l10nProvider);

    // Sort so incomplete quests are on top
    final sortedQuests = [...quests]
      ..sort((a, b) {
        if (a.isCompleted && !b.isCompleted) return 1;
        if (!a.isCompleted && b.isCompleted) return -1;
        return a.type.index.compareTo(b.type.index); // Daily then weekly
      });

    if (sortedQuests.isEmpty) {
      return Center(child: Text(l10n.get('quest_empty')));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedQuests.length,
      itemBuilder: (context, index) {
        final quest = sortedQuests[index];
        final progress = quest.currentValue / quest.targetValue;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: quest.isCompleted
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: quest.isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    quest.isCompleted
                        ? Icons.check_circle
                        : Icons.assignment_late,
                    color: quest.isCompleted ? Colors.green : Colors.blue,
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
                              quest.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+${quest.rewardXp} XP',
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[300],
                                color: quest.isCompleted
                                    ? Colors.green
                                    : Colors.blue,
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${quest.currentValue} / ${quest.targetValue}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: quest.isCompleted
                                  ? Colors.green
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      // Expires at
                      if (quest.expiresAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.get('quest_expires')} ${DateFormat('MMM dd, hh:mm a').format(quest.expiresAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[300],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
