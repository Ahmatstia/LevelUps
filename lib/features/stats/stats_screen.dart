import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/user_model.dart'; // Tambahkan ini
import '../../core/models/task_model.dart'; // Tambahkan ini

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final incompleteTasks = ref.watch(incompleteTasksProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistics',
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
            // Stat Cards Ringkasan
            _buildStatSummary(
              user,
              completedTasks.length,
              incompleteTasks.length,
            ),
            const SizedBox(height: 24),

            // Level & XP Card
            _buildLevelCard(user),
            const SizedBox(height: 24),

            // Progress per Stat
            const Text(
              'Stat Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatProgress(user),
            const SizedBox(height: 24),

            // Stat Distribution Chart
            const Text(
              'Stat Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildPieChart(user),
            const SizedBox(height: 24),

            // Task Statistics
            const Text(
              'Task Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildTaskStats(completedTasks),
            const SizedBox(height: 24),

            // Streak Card
            _buildStreakCard(user),
            const SizedBox(height: 24),

            // XP History
            const Text(
              'XP Growth (7 Days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildXpHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(UserModel user, int completed, int incomplete) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.3),
            Colors.purple.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.star,
            value: user.level.toString(),
            label: 'Level',
            color: Colors.amber,
          ),
          _buildSummaryItem(
            icon: Icons.flash_on,
            value: user.totalXp.toString(),
            label: 'Total XP',
            color: Colors.blue,
          ),
          _buildSummaryItem(
            icon: Icons.check_circle,
            value: completed.toString(),
            label: 'Done',
            color: Colors.green,
          ),
          _buildSummaryItem(
            icon: Icons.local_fire_department,
            value: user.streak.toString(),
            label: 'Streak',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildLevelCard(UserModel user) {
    final xpProgress = (user.totalXp - (100 * (user.level - 1))) / 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Level',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.level}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: xpProgress,
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

  Widget _buildStatProgress(UserModel user) {
    final stats = [
      {
        'label': 'Intelligence',
        'value': user.intelligence,
        'color': Colors.blue,
        'icon': Icons.school,
      },
      {
        'label': 'Discipline',
        'value': user.discipline,
        'color': Colors.green,
        'icon': Icons.fitness_center,
      },
      {
        'label': 'Health',
        'value': user.health,
        'color': Colors.red,
        'icon': Icons.favorite,
      },
      {
        'label': 'Wealth',
        'value': user.wealth,
        'color': Colors.amber,
        'icon': Icons.attach_money,
      },
    ];

    return Column(
      children: stats.map((stat) {
        final int maxValue = 100; // Target maksimum per stat
        final double progress = (stat['value'] as int) / maxValue;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    size: 16,
                    color: stat['color'] as Color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stat['label'] as String,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    '${stat['value']} / $maxValue',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress > 1 ? 1 : progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (stat['color'] as Color).withValues(alpha: 0.5),
                            stat['color'] as Color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPieChart(UserModel user) {
    final total =
        user.intelligence + user.discipline + user.health + user.wealth;

    if (total == 0) {
      return Container(
        height: 200,
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

    final sections = [
      PieChartSectionData(
        value: user.intelligence.toDouble(),
        title: '${((user.intelligence / total) * 100).toInt()}%',
        color: Colors.blue,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: user.discipline.toDouble(),
        title: '${((user.discipline / total) * 100).toInt()}%',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: user.health.toDouble(),
        title: '${((user.health / total) * 100).toInt()}%',
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: user.wealth.toDouble(),
        title: '${((user.wealth / total) * 100).toInt()}%',
        color: Colors.amber,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildTaskStats(List<TaskModel> completedTasks) {
    // Hitung task per difficulty
    int easy = 0, medium = 0, hard = 0;
    int totalXp = 0;

    for (var task in completedTasks) {
      switch (task.difficulty) {
        case TaskDifficulty.easy:
          easy++;
          totalXp += 10;
          break;
        case TaskDifficulty.medium:
          medium++;
          totalXp += 20;
          break;
        case TaskDifficulty.hard:
          hard++;
          totalXp += 30;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTaskStatRow('Easy', easy, Colors.green),
          const SizedBox(height: 12),
          _buildTaskStatRow('Medium', medium, Colors.orange),
          const SizedBox(height: 12),
          _buildTaskStatRow('Hard', hard, Colors.red),
          const Divider(color: Colors.grey, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total XP Earned',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '$totalXp XP',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
        const Spacer(),
        Text(
          '$count tasks',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildXpHistory() {
    // Simulasi data XP 7 hari terakhir
    final data = [10.0, 25.0, 40.0, 65.0, 55.0, 80.0, 95.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Text(
                      days[index],
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index],
                  color: Colors.blue,
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
