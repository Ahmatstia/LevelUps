import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/user_model.dart';
import 'widgets/productivity_heatmap.dart';
import 'widgets/insights_cards.dart';
import 'widgets/advanced_charts.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final incompleteTasks = ref.watch(incompleteTasksProvider);
    final analytics = ref.watch(analyticsProvider); // Grab the new analytics
    final l10n = ref.watch(l10nProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.get('nav_stats'),
          style: const TextStyle(
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
            // 1. Basic Overviews
            _buildStatSummary(
              user,
              completedTasks.length,
              incompleteTasks.length,
              l10n,
            ),
            const SizedBox(height: 24),

            // 2. Level & Streak Row
            Row(
              children: [
                Expanded(flex: 3, child: _buildLevelCard(user, l10n)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildStreakCard(user, l10n)),
              ],
            ),
            const SizedBox(height: 32),

            // 3. New AI Insights / Advanced Analytics
            Text(
              l10n.get('stats_insight'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            InsightsCards(analytics: analytics),
            const SizedBox(height: 32),

            // 4. Heatmap
            ProductivityHeatmap(heatmapData: analytics.heatmapData),
            const SizedBox(height: 32),

            // 5. Advanced Charts (Line XP, Bar Tasks, Pie Quadrants)
            Text(
              l10n.get('stats_charts'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            AdvancedCharts(analytics: analytics),
            const SizedBox(height: 32),

            // 6. RPG Stats Detail
            Text(
              l10n.get('stats_rpg'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatProgress(user, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(
    UserModel user,
    int completed,
    int incomplete,
    dynamic l10n,
  ) {
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
            label: l10n.get('stats_level'),
            color: Colors.amber,
          ),
          _buildSummaryItem(
            icon: Icons.flash_on,
            value: user.totalXp.toString(),
            label: l10n.get('stats_total_xp'),
            color: Colors.blue,
          ),
          _buildSummaryItem(
            icon: Icons.check_circle,
            value: completed.toString(),
            label: l10n.get('task_tab_completed'),
            color: Colors.green,
          ),
          _buildSummaryItem(
            icon: Icons.pending_actions,
            value: incomplete.toString(),
            label: l10n.get('task_tab_active'),
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

  Widget _buildLevelCard(UserModel user, dynamic l10n) {
    final nextLevelXp = 100 * user.level;
    final currentLevelBaseXp = 100 * (user.level - 1);
    final currentLevelXp = user.totalXp - currentLevelBaseXp;
    final xpProgress = currentLevelXp / (nextLevelXp - currentLevelBaseXp);

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
          Text(
            l10n.get('stats_level'),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.level}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
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
                widthFactor: xpProgress > 1 ? 1 : xpProgress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(3),
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
                '$currentLevelXp XP',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
              Text(
                '${nextLevelXp - currentLevelBaseXp} XP',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserModel user, dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${user.streak}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('stats_streak'),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgress(UserModel user, dynamic l10n) {
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
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${stat['value']} / $maxValue',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                          boxShadow: [
                            BoxShadow(
                              color: (stat['color'] as Color).withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
