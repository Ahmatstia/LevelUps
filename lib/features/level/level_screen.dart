import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/user_model.dart'; // Tambahkan ini
import '../../core/models/task_model.dart'; // Tambahkan ini

class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final xpProgress = ref.watch(xpProgressProvider);
    final xpForNextLevel = ref.watch(xpForNextLevelProvider);
    final completedTasks = ref.watch(completedTasksProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Level & Stats',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Card
            _buildLevelCard(user, xpProgress, xpForNextLevel),
            const SizedBox(height: 24),

            // Stats Detail
            _buildStatsDetail(user),
            const SizedBox(height: 24),

            // Streak Info
            _buildStreakCard(user),
            const SizedBox(height: 24),

            // Stat Distribution
            _buildStatDistribution(user),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(completedTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(UserModel user, double progress, int xpNeeded) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Level',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${user.totalXp} Total XP',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${user.level}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // XP Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                '$xpNeeded XP to Level ${user.level + 1}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDetail(UserModel user) {
    final stats = [
      {
        'icon': Icons.school,
        'label': 'Intelligence',
        'value': user.intelligence,
        'color': Colors.blue,
        'description': 'Learning, reading, problem solving',
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Discipline',
        'value': user.discipline,
        'color': Colors.green,
        'description': 'Exercise, routine, consistency',
      },
      {
        'icon': Icons.favorite,
        'label': 'Health',
        'value': user.health,
        'color': Colors.red,
        'description': 'Diet, sleep, meditation',
      },
      {
        'icon': Icons.attach_money,
        'label': 'Wealth',
        'value': user.wealth,
        'color': Colors.amber,
        'description': 'Work, savings, investment',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stat Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...stats.map((stat) => _buildStatItem(stat)),
      ],
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat['icon'] as IconData,
              color: stat['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stat['label'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${stat['value']} pts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stat['description'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Streak',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.streak} days',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last active: ${_formatDate(user.lastTaskDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDistribution(UserModel user) {
    final total =
        user.intelligence + user.discipline + user.health + user.wealth;

    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Complete tasks to see your stat distribution',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final stats = [
      {'label': 'Intel', 'value': user.intelligence, 'color': Colors.blue},
      {'label': 'Disc', 'value': user.discipline, 'color': Colors.green},
      {'label': 'Health', 'value': user.health, 'color': Colors.red},
      {'label': 'Wealth', 'value': user.wealth, 'color': Colors.amber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stat Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...stats.map((stat) {
          final percentage = (stat['value'] as int) / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stat['label'] as String,
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: stat['color'] as Color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity(List<TaskModel> completedTasks) {
    final recentTasks = completedTasks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
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
            ),
            child: const Center(
              child: Text(
                'No activity yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...recentTasks.map(
            (task) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getStatColor(
                        task.statType,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatIcon(task.statType),
                      size: 16,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${task.difficulty.xpValue} XP • ${task.statType.displayName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(task.completedAt ?? task.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
}
