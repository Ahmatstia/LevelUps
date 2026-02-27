import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/habit_model.dart';
import '../../../core/theme/game_theme.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onCheckIn;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onCheckIn,
    required this.onDelete,
  });

  Color get _statColor {
    switch (habit.statType) {
      case 'intelligence':
        return GameTheme.manaBlue;
      case 'health':
        return GameTheme.hpRed;
      case 'wealth':
        return GameTheme.goldYellow;
      default:
        return GameTheme.staminaGreen; // discipline
    }
  }

  IconData get _statIcon {
    switch (habit.statType) {
      case 'intelligence':
        return Icons.school;
      case 'health':
        return Icons.favorite;
      case 'wealth':
        return Icons.attach_money;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = habit.isCheckedInToday;
    final borderColor = isDone
        ? GameTheme.staminaGreen.withValues(alpha: 0.5)
        : _statColor.withValues(alpha: 0.3);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isDone ? GameTheme.staminaGreen : _statColor).withValues(
              alpha: 0.07,
            ),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Stat icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statColor.withValues(alpha: 0.1),
              border: Border.all(color: _statColor.withValues(alpha: 0.5)),
            ),
            child: Icon(_statIcon, color: _statColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.grey[600] : Colors.white,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Streak
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: GameTheme.goldYellow.withValues(alpha: 0.1),
                        border: Border.all(
                          color: GameTheme.goldYellow.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 10,
                            color: GameTheme.goldYellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.currentStreak}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              color: GameTheme.goldYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // XP reward
                    Text(
                      '+${habit.xpReward} XP',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: GameTheme.goldYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Frequency
                    Text(
                      habit.frequency.displayName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Check-in button or done indicator
          if (isDone)
            Icon(
              Icons.check_circle,
              color: GameTheme.staminaGreen,
              size: 28,
              shadows: [Shadow(color: GameTheme.staminaGreen, blurRadius: 8)],
            ).animate().scale(duration: 300.ms, curve: Curves.elasticOut)
          else
            GestureDetector(
              onTap: onCheckIn,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _statColor.withValues(alpha: 0.15),
                  border: Border.all(color: _statColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _statColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(Icons.check, color: _statColor, size: 20),
              ),
            ),

          const SizedBox(width: 6),

          // Delete button
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Icon(
              Icons.delete_outline,
              color: Colors.grey[700],
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GameTheme.surface,
        shape: const RoundedRectangleBorder(),
        title: Text(
          'Delete Habit?',
          style: GameTheme.textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
        content: Text(
          'This will delete "${habit.title}" permanently.',
          style: GameTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text('DELETE', style: TextStyle(color: GameTheme.hpRed)),
          ),
        ],
      ),
    );
  }
}
