import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/habit_model.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/theme/game_theme.dart';
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
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        title: Text(
          'HABITS',
          style: GameTheme.neonTextStyle(GameTheme.staminaGreen, fontSize: 16),
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
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.staminaGreen.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.staminaGreen.withValues(alpha: 0.1),
            blurRadius: 8,
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
                style: GameTheme.textTheme.bodySmall?.copyWith(
                  color: GameTheme.staminaGreen,
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GameTheme.staminaGreen.withValues(alpha: 0.15),
                  border: Border.all(color: GameTheme.staminaGreen, width: 1.5),
                ),
                child: Text(
                  '$done / $total',
                  style: GameTheme.neonTextStyle(
                    GameTheme.staminaGreen,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar manual bergaya game
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: GameTheme.staminaGreen,
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.staminaGreen.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
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
      backgroundColor: GameTheme.staminaGreen,
      onPressed: () => AddHabitDialog.show(context, ref),
      shape: const RoundedRectangleBorder(),
      child: const Icon(Icons.add, color: Colors.black),
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
            color: GameTheme.staminaGreen.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'NO HABITS YET',
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first daily habit',
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckinSuccess(BuildContext context, HabitModel habit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: GameTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: GameTheme.staminaGreen, size: 18),
            const SizedBox(width: 10),
            Text(
              '✅ +${habit.xpReward} XP  🔥 ${habit.currentStreak} day streak!',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
