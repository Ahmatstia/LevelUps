import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/rpg_status_bar.dart';
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
    final analytics = ref.watch(analyticsProvider);
    final l10n = ref.watch(l10nProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.get('nav_stats'),
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
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
            const SizedBox(height: 24),

            // 2. Level & Streak Row
            Row(
              children: [
                Expanded(flex: 3, child: _buildLevelCard(user, l10n)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildStreakCard(user, l10n)),
              ],
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 32),

            // 3. AI Insights
            _buildSectionHeader(l10n.get('stats_insight'), AppTheme.primaryDark),
            const SizedBox(height: 16),
            InsightsCards(analytics: analytics).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),

            // 4. Heatmap
            ProductivityHeatmap(
              heatmapData: analytics.heatmapData,
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 32),

            // 5. Advanced Charts
            _buildSectionHeader(l10n.get('stats_charts'), AppTheme.manaBlue),
            const SizedBox(height: 16),
            AdvancedCharts(
              analytics: analytics,
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 32),

            // 6. RPG Stats Detail
            _buildSectionHeader(l10n.get('stats_rpg'), AppTheme.hpRed),
            const SizedBox(height: 16),
            _buildStatProgress(user, l10n).animate().fadeIn(delay: 1000.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: color.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildStatSummary(
    UserModel user,
    int completed,
    int incomplete,
    dynamic l10n,
  ) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.star,
            value: user.level.toString(),
            label: l10n.get('stats_level'),
            color: AppTheme.goldYellow,
          ),
          _buildSummaryItem(
            icon: Icons.flash_on,
            value: user.totalXp.toString(),
            label: l10n.get('stats_total_xp'),
            color: AppTheme.manaBlue,
          ),
          _buildSummaryItem(
            icon: Icons.check_circle,
            value: completed.toString(),
            label: l10n.get('task_tab_completed'),
            color: AppTheme.staminaGreen,
          ),
          _buildSummaryItem(
            icon: Icons.pending_actions,
            value: incomplete.toString(),
            label: l10n.get('task_tab_active'),
            color: AppTheme.goldYellow,
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
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(UserModel user, dynamic l10n) {
    final nextLevelXp = 100 * user.level;
    final currentLevelBaseXp = 100 * (user.level - 1);
    final currentLevelXp = user.totalXp - currentLevelBaseXp;
    final xpProgress = currentLevelXp / (nextLevelXp - currentLevelBaseXp);

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
          Text(
            l10n.get('stats_level'),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.level}',
            style: AppTheme.textTheme.displaySmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RpgStatusBar(
            value: xpProgress > 1 ? 1 : xpProgress,
            barColor: AppTheme.primary,
            height: 12,
            segments: 1, // Single continuous bar
            label: '$currentLevelXp / ${nextLevelXp - currentLevelBaseXp} XP',
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserModel user, dynamic l10n) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppTheme.goldYellow,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            '${user.streak}',
            style: AppTheme.textTheme.headlineLarge?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('stats_streak'),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.goldYellow,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatProgress(UserModel user, dynamic l10n) {
    final stats = [
      {
        'label': 'INTELLIGENCE',
        'value': user.intelligence,
        'color': AppTheme.manaBlue,
        'icon': Icons.school,
      },
      {
        'label': 'DISCIPLINE',
        'value': user.discipline,
        'color': AppTheme.staminaGreen,
        'icon': Icons.fitness_center,
      },
      {
        'label': 'HEALTH',
        'value': user.health,
        'color': AppTheme.hpRed,
        'icon': Icons.favorite,
      },
      {
        'label': 'WEALTH',
        'value': user.wealth,
        'color': AppTheme.goldYellow,
        'icon': Icons.attach_money,
      },
    ];

    return Column(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        final int maxValue = 100;
        final double progress = (stat['value'] as int) / maxValue;
        final statColor = stat['color'] as Color;

        return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statColor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        stat['icon'] as IconData,
                        size: 20,
                        color: statColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        stat['label'] as String,
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${stat['value']} / $maxValue',
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            color: statColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RpgStatusBar(
                    value: progress > 1 ? 1 : progress,
                    barColor: statColor,
                    height: 12,
                    segments: 1,
                  ),
                ],
              ),
            )
            .animate(delay: (index * 80).ms)
            .slideX(begin: 0.15, duration: 280.ms)
            .fadeIn();
      }).toList(),
    );
  }
}
