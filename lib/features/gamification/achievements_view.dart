import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/providers/achievement_provider.dart';
import '../../core/theme/game_theme.dart';
import '../../core/widgets/rpg_status_bar.dart';

class AchievementsView extends ConsumerWidget {
  const AchievementsView({super.key});

  static IconData _getIconFromString(String iconName) {
    const iconMap = {
      'wb_sunny': Icons.wb_sunny,
      'nights_stay': Icons.nights_stay,
      'local_fire_department': Icons.local_fire_department,
      'check_circle_outline': Icons.check_circle_outline,
      'balance': Icons.balance,
      'emoji_events': Icons.emoji_events,
    };
    return iconMap[iconName] ?? Icons.star;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementProvider);

    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'NO ACHIEVEMENTS YET',
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

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final isUnlocked = achievement.isUnlocked;
        final accentColor = isUnlocked
            ? GameTheme.goldYellow
            : Colors.grey[700]!;

        return Container(
              decoration: BoxDecoration(
                color: GameTheme.surface,
                border: Border.all(
                  color: isUnlocked
                      ? GameTheme.goldYellow.withValues(alpha: 0.6)
                      : Colors.white12,
                  width: isUnlocked ? 2.0 : 1.5,
                ),
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: GameTheme.goldYellow.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        _getIconFromString(achievement.iconData),
                        size: 28,
                        color: isUnlocked
                            ? GameTheme.goldYellow
                            : Colors.grey[700],
                        shadows: isUnlocked
                            ? [
                                Shadow(
                                  color: GameTheme.goldYellow,
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      achievement.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        letterSpacing: 0.5,
                        color: isUnlocked ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Progress or Unlock Date
                    if (isUnlocked && achievement.dateUnlocked != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: GameTheme.staminaGreen.withValues(alpha: 0.1),
                          border: Border.all(
                            color: GameTheme.staminaGreen.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          '✓ ${DateFormat('MMM dd').format(achievement.dateUnlocked!)}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 8,
                            color: GameTheme.staminaGreen,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else ...[
                      RpgStatusBar(
                        value:
                            achievement.currentValue / achievement.targetValue,
                        barColor: accentColor,
                        height: 10,
                        segments: achievement.targetValue.clamp(2, 10),
                        animate: isUnlocked,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.currentValue} / ${achievement.targetValue}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 8,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .animate(delay: (index * 60).ms)
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }
}
