import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/habit_model.dart';
import '../../../core/theme/app_theme.dart';

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
        return AppTheme.manaBlue;
      case 'health':
        return AppTheme.hpRed;
      case 'wealth':
        return AppTheme.goldYellow;
      default:
        return AppTheme.staminaGreen; // discipline
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
        ? AppTheme.staminaGreen.withOpacity(0.5)
        : Colors.transparent;
        
    final bgColor = isDone ? AppTheme.background : AppTheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDone ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
              color: _statColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.grey[400] : AppTheme.primaryDark,
                    decoration: isDone ? TextDecoration.lineThrough : null,
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
                        color: AppTheme.goldYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 10,
                            color: AppTheme.goldYellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${habit.currentStreak}',
                            style: AppTheme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: AppTheme.goldYellow,
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
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppTheme.goldYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Frequency
                    Text(
                      habit.frequency.displayName.toUpperCase(),
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
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
              color: AppTheme.staminaGreen,
              size: 28,
            ).animate().scale(duration: 300.ms, curve: Curves.elasticOut)
          else
            GestureDetector(
              onTap: onCheckIn,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDone ? _statColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statColor.withOpacity(0.5), 
                    width: 2
                  ),
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
              color: AppTheme.hpRed.withOpacity(0.6),
              size: 20,
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
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Habit?',
          style: AppTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will delete "${habit.title}" permanently.',
          style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL', 
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(
              'DELETE', 
              style: TextStyle(color: AppTheme.hpRed, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}
