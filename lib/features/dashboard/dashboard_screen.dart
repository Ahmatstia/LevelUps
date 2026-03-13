import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/rpg_status_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final xpProgress = ref.watch(xpProgressProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final completedToday = todayTasks.where((t) => t.isCompleted).length;
    final l10n = ref.watch(l10nProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                user,
                l10n,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              const SizedBox(height: 24),
              _buildLevelCard(
                user,
                xpProgress,
                l10n,
              ).animate().fadeIn(delay: 200.ms).slideX(),
              const SizedBox(height: 24),
              _buildStatsGrid(
                user,
                l10n,
              ).animate().fadeIn(delay: 400.ms).scale(),
              const SizedBox(height: 24),
              _buildTodayProgress(
                todayTasks.length,
                completedToday,
                l10n,
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),
              _buildRecentTasks(
                todayTasks,
                l10n,
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.get('dash_greeting').split(' ')[0]} ${user.name}!',
                style: AppTheme.textTheme.displayMedium?.copyWith(
                  color: AppTheme.primaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'READY TO CONTINUE?',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.goldYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.goldYellow.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: AppTheme.goldYellow,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1200.ms, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '${user.streak}x MULTI',
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldYellow,
                ),
              ),
            ],
          ),
        ).animate().shake(hz: 2, delay: 2.seconds), // Idle shake
      ],
    );
  }

  Widget _buildLevelCard(UserModel user, double progress, dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Flexible(
                child: Text(
                  '${l10n.get('stats_level')} ${user.level}',
                  style: AppTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${user.totalXp} XP',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Clean Progress Bar
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
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${user.totalXp - (100 * (user.level - 1))} XP',
                style: AppTheme.textTheme.bodySmall,
              ),
              Text(
                '${100 * user.level} XP',
                style: AppTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserModel user, dynamic l10n) {
    final stats = [
      {
        'icon': Icons.school,
        'label': l10n.get('task_stat_int'),
        'value': user.intelligence,
        'color': AppTheme.manaBlue,
      },
      {
        'icon': Icons.fitness_center,
        'label': l10n.get('task_stat_disc'),
        'value': user.discipline,
        'color': AppTheme.staminaGreen,
      },
      {
        'icon': Icons.favorite,
        'label': l10n.get('task_stat_hp'),
        'value': user.health,
        'color': AppTheme.hpRed,
      },
      {
        'icon': Icons.attach_money,
        'label': l10n.get('task_stat_wlth'),
        'value': user.wealth,
        'color': AppTheme.goldYellow,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8, // Diubah dari 0.9 ke 0.8 untuk mencegah overflow
        crossAxisSpacing: 8, // Kurangi spacing
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final statColor = stat['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(8), // Kurangi padding
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                size: 24,
                color: statColor,
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'].toString(),
                style: AppTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  stat['label'] as String,
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayProgress(int total, int completed, dynamic l10n) {
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Container(
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
                'MISSION PROGRESS',
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
                  '$percent%',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.staminaGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RpgStatusBar(
            value: progress,
            barColor: AppTheme.staminaGreen,
            height: 8,
            segments: total > 0 ? total.clamp(2, 10) : 10,
            label: '$completed / $total QUESTS DONE',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks(List<TaskModel> tasks, dynamic l10n) {
    final recentTasks = tasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TODAY\'S QUESTS',
              style: AppTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 40,
                    color: AppTheme.primary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NO MISSIONS TODAY',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = recentTasks[index];
              final statColor = _getStatColor(task.statType);
              final borderColor = task.isCompleted
                  ? AppTheme.staminaGreen.withOpacity(0.4)
                  : Colors.transparent;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Stat icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: statColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatIcon(task.statType),
                        size: 18,
                        color: statColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: AppTheme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? Colors.grey[400]
                                  : AppTheme.primaryDark,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    task.difficulty,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.difficulty.displayName.toUpperCase(),
                                  style: AppTheme.textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    color: _getDifficultyColor(task.difficulty),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${task.difficulty.xpValue} XP',
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.goldYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (task.isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.staminaGreen,
                        size: 24,
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getStatColor(StatType stat) {
    switch (stat) {
      case StatType.intelligence:
        return AppTheme.manaBlue;
      case StatType.discipline:
        return AppTheme.staminaGreen;
      case StatType.health:
        return AppTheme.hpRed;
      case StatType.wealth:
        return AppTheme.goldYellow;
    }
  }

  IconData _getStatIcon(StatType stat) {
    switch (stat) {
      case StatType.intelligence:
        return Icons.school;
      case StatType.discipline:
        return Icons.fitness_center;
      case StatType.health:
        return Icons.favorite;
      case StatType.wealth:
        return Icons.attach_money;
    }
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return AppTheme.staminaGreen;
      case TaskDifficulty.medium:
        return AppTheme.goldYellow;
      case TaskDifficulty.hard:
        return AppTheme.hpRed;
    }
  }
}
