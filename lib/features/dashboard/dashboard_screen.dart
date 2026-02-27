import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/task_model.dart';
import '../../core/theme/game_theme.dart';
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
      backgroundColor: GameTheme.background,
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
                style: GameTheme.neonTextStyle(
                  GameTheme.neonCyan,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'READY TO CONTINUE?',
                style: GameTheme.textTheme.bodyMedium?.copyWith(
                  color: GameTheme.neonPink,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: GameTheme.goldYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8), // Blocky game border
            border: Border.all(color: GameTheme.goldYellow, width: 2),
          ),
          child: Row(
            children: [
              const Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: GameTheme.goldYellow,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1200.ms, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '${user.streak}x MULTI',
                style: GameTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GameTheme.goldYellow,
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
        color: GameTheme.surface, // Solid dark background
        borderRadius: BorderRadius.circular(8), // Blocky radius
        border: Border.all(
          color: GameTheme.neonCyan.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonCyan.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
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
                  style: GameTheme.neonTextStyle(
                    GameTheme.neonCyan,
                    fontSize: 24,
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
                  color: GameTheme.neonPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: GameTheme.neonPink),
                ),
                child: Text(
                  '${user.totalXp} XP',
                  style: GameTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Blocky RPG Progress Bar
          Container(
            height: 16, // Thicker bar
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child:
                  Container(
                        decoration: BoxDecoration(
                          color: GameTheme.neonCyan,
                          boxShadow: [
                            BoxShadow(
                              color: GameTheme.neonCyan.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2.seconds, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${user.totalXp - (100 * (user.level - 1))} XP',
                style: GameTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              Text(
                '${100 * user.level} XP',
                style: GameTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
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
        'color': GameTheme.manaBlue,
      },
      {
        'icon': Icons.fitness_center,
        'label': l10n.get('task_stat_disc'),
        'value': user.discipline,
        'color': GameTheme.staminaGreen,
      },
      {
        'icon': Icons.favorite,
        'label': l10n.get('task_stat_hp'),
        'value': user.health,
        'color': GameTheme.hpRed,
      },
      {
        'icon': Icons.attach_money,
        'label': l10n.get('task_stat_wlth'),
        'value': user.wealth,
        'color': GameTheme.goldYellow,
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
            color: GameTheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: statColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                size: 20, // Kurangi ukuran icon
                color: statColor,
                shadows: [Shadow(color: statColor, blurRadius: 10)],
              ),
              const SizedBox(height: 8),
              Text(
                stat['value'].toString(),
                style: GameTheme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  stat['label'] as String,
                  style: GameTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 8,
                    color: statColor,
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
                'MISSION PROGRESS',
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
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.staminaGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '$percent%',
                  style: GameTheme.neonTextStyle(
                    GameTheme.staminaGreen,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RpgStatusBar(
            value: progress,
            barColor: GameTheme.staminaGreen,
            height: 18,
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
              style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 12),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                color: GameTheme.neonCyan.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GameTheme.surface,
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    size: 40,
                    color: GameTheme.neonCyan.withValues(alpha: 0.4),
                    shadows: [
                      Shadow(
                        color: GameTheme.neonCyan.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NO MISSIONS TODAY',
                    style: GameTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 2,
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
                  ? GameTheme.staminaGreen.withValues(alpha: 0.4)
                  : statColor.withValues(alpha: 0.2);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GameTheme.surface,
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (task.isCompleted
                                  ? GameTheme.staminaGreen
                                  : statColor)
                              .withValues(alpha: 0.07),
                      blurRadius: 6,
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
                        color: statColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: statColor.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statColor.withValues(alpha: 0.2),
                            blurRadius: 6,
                          ),
                        ],
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
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? Colors.grey[600]
                                  : Colors.white,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: Colors.grey[600],
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
                                  ).withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: _getDifficultyColor(
                                      task.difficulty,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  task.difficulty.displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 8,
                                    color: _getDifficultyColor(task.difficulty),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${task.difficulty.xpValue} XP',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  color: GameTheme.goldYellow,
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
                        Icons.check,
                        color: GameTheme.staminaGreen,
                        size: 20,
                        shadows: [
                          Shadow(color: GameTheme.staminaGreen, blurRadius: 10),
                        ],
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
        return GameTheme.manaBlue;
      case StatType.discipline:
        return GameTheme.staminaGreen;
      case StatType.health:
        return GameTheme.hpRed;
      case StatType.wealth:
        return GameTheme.goldYellow;
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
        return GameTheme.staminaGreen;
      case TaskDifficulty.medium:
        return GameTheme.goldYellow;
      case TaskDifficulty.hard:
        return GameTheme.hpRed;
    }
  }
}
