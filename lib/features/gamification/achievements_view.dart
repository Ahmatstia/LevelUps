import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/achievement_provider.dart';
import 'package:intl/intl.dart';

class AchievementsView extends ConsumerWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementProvider);

    if (achievements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isUnlocked = achievement.isUnlocked;

        return Card(
          elevation: isUnlocked ? 4 : 1,
          color: isUnlocked ? Theme.of(context).cardColor : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isUnlocked
                  ? Colors.amber.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with Glow if unlocked
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.grey[300],
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    achievement.iconData,
                    size: 36,
                    color: isUnlocked ? Colors.amber : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isUnlocked ? Colors.black87 : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Progress or Date
                if (isUnlocked && achievement.dateUnlocked != null) ...[
                  Text(
                    'Achieved ${DateFormat('MMM dd').format(achievement.dateUnlocked!)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  LinearProgressIndicator(
                    value: achievement.currentValue / achievement.targetValue,
                    backgroundColor: Colors.grey[300],
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.currentValue} / ${achievement.targetValue}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
