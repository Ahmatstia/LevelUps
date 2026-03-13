import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/habit_model.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/habit_card.dart';
import 'widgets/add_habit_dialog.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final doneTodayCount = ref.watch(habitsTodayDoneProvider);
    final total = habits.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'HABITS',
        ),
      ),
      floatingActionButton: _buildFab(context, ref),
      body: Column(
        children: [
          // Daily Progress Summary
          _buildDailyProgress(
            doneTodayCount,
            total,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

          const SizedBox(height: 8),

          // List habits
          Expanded(
            child: habits.isEmpty
                ? _buildEmptyState().animate().fadeIn(delay: 200.ms)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return HabitCard(
                            habit: habits[index],
                            onCheckIn: () async {
                              final success = await ref
                                  .read(habitProvider.notifier)
                                  .checkIn(habits[index].id);
                              if (success && context.mounted) {
                                _showCheckinSuccess(context, habits[index]);
                              }
                            },
                            onDelete: () => ref
                                .read(habitProvider.notifier)
                                .deleteHabit(habits[index].id),
                          )
                          .animate(delay: (index * 60).ms)
                          .slideX(begin: 0.2)
                          .fadeIn();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress(int done, int total) {
    final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S HABITS',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.staminaGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$done / $total',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.staminaGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              color: AppTheme.primary.withOpacity(0.1),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      backgroundColor: AppTheme.primary,
      onPressed: () => AddHabitDialog.show(context, ref),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.repeat,
            size: 48,
            color: AppTheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'NO HABITS YET',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first daily habit',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckinSuccess(BuildContext context, HabitModel habit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.staminaGreen, size: 20),
            const SizedBox(width: 10),
            Text(
              '+${habit.xpReward} XP  🔥 ${habit.currentStreak} day streak!',
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
