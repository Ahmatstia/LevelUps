import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/providers/achievement_provider.dart';
import '../../core/theme/app_theme.dart';
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
            ? AppTheme.goldYellow
            : Colors.grey[400]!;

        return Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? AppTheme.goldYellow.withOpacity(0.4)
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
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconFromString(achievement.iconData),
                        size: 28,
                        color: isUnlocked
                            ? AppTheme.goldYellow
                            : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      achievement.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: isUnlocked ? AppTheme.primaryDark : Colors.grey[500],
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
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.grey[600],
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
                          color: AppTheme.staminaGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✓ ${DateFormat('MMM dd').format(achievement.dateUnlocked!)}',
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppTheme.staminaGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else ...[
                      RpgStatusBar(
                        value:
                            achievement.currentValue / achievement.targetValue,
                        barColor: accentColor,
                        height: 10,
                        segments: 1,
                        animate: isUnlocked,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${achievement.currentValue} / ${achievement.targetValue}',
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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
