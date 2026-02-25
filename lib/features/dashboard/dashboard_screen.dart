import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/task_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final xpProgress = ref.watch(xpProgressProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final completedToday = todayTasks.where((t) => t.isCompleted).length;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              const SizedBox(height: 24),
              _buildLevelCard(user, xpProgress),
              const SizedBox(height: 24),
              _buildStatsGrid(user), // Stats grid sudah diperbaiki
              const SizedBox(height: 24),
              _buildTodayProgress(todayTasks.length, completedToday),
              const SizedBox(height: 24),
              _buildRecentTasks(todayTasks),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Let\'s level up today!',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1), // Perbaiki withOpacity
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.orange.withValues(
                alpha: 0.3,
              ), // Perbaiki withOpacity
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 18,
                color: Colors.orange[300],
              ),
              const SizedBox(width: 6),
              Text(
                '🔥 ${user.streak} day streak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[300],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(UserModel user, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.3), // Perbaiki withOpacity
            Colors.purple.withValues(alpha: 0.3), // Perbaiki withOpacity
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), // Perbaiki withOpacity
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${user.level}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.1,
                  ), // Perbaiki withOpacity
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${user.totalXp} XP',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.1,
                  ), // Perbaiki withOpacity
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${user.totalXp - (100 * (user.level - 1))} XP',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              Text(
                '${100 * user.level} XP',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserModel user) {
    final stats = [
      {
        'icon': Icons.school,
        'label': 'Intel',
        'value': user.intelligence,
        'color': Colors.blue,
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Disc',
        'value': user.discipline,
        'color': Colors.green,
      },
      {
        'icon': Icons.favorite,
        'label': 'Health',
        'value': user.health,
        'color': Colors.red,
      },
      {
        'icon': Icons.attach_money,
        'label': 'Wealth',
        'value': user.wealth,
        'color': Colors.amber,
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
        return Container(
          padding: const EdgeInsets.all(8), // Kurangi padding
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.05,
              ), // Perbaiki withOpacity
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                size: 20, // Kurangi ukuran icon
                color: (stat['color'] as Color).withValues(
                  alpha: 0.8,
                ), // Perbaiki withOpacity
              ),
              const SizedBox(height: 4), // Kurangi spacing
              Text(
                stat['value'].toString(),
                style: const TextStyle(
                  fontSize: 16, // Kurangi ukuran font
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2), // Kurangi spacing
              Text(
                stat['label'] as String,
                style: TextStyle(
                  fontSize: 9, // Kurangi ukuran font
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayProgress(int total, int completed) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05), // Perbaiki withOpacity
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completed of $total tasks completed',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: total == 0 ? 0 : completed / total,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              Text(
                '${total == 0 ? 0 : (completed / total * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks(List<TaskModel> tasks) {
    final recentTasks = tasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (recentTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.05,
                ), // Perbaiki withOpacity
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.task_alt, size: 48, color: Colors.grey[700]),
                  const SizedBox(height: 12),
                  Text(
                    'No tasks yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a task to start your journey',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final task = recentTasks[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: task.isCompleted
                        ? Colors.green.withValues(
                            alpha: 0.3,
                          ) // Perbaiki withOpacity
                        : Colors.white.withValues(
                            alpha: 0.05,
                          ), // Perbaiki withOpacity
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatColor(
                          task.statType,
                        ).withValues(alpha: 0.1), // Perbaiki withOpacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatIcon(task.statType),
                        size: 20,
                        color: _getStatColor(task.statType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(task.difficulty)
                                      .withValues(
                                        alpha: 0.1,
                                      ), // Perbaiki withOpacity
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  task.difficulty.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getDifficultyColor(task.difficulty),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${task.difficulty.xpValue} XP',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (task.isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
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
        return Colors.blue;
      case StatType.discipline:
        return Colors.green;
      case StatType.health:
        return Colors.red;
      case StatType.wealth:
        return Colors.amber;
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
        return Colors.green;
      case TaskDifficulty.medium:
        return Colors.orange;
      case TaskDifficulty.hard:
        return Colors.red;
    }
  }
}
