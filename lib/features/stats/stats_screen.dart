import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/analytics_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/game_theme.dart';
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
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        title: Text(
          l10n.get('nav_stats'),
          style: GameTheme.neonTextStyle(GameTheme.neonPink, fontSize: 16),
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
            _buildSectionHeader(l10n.get('stats_insight'), GameTheme.neonCyan),
            const SizedBox(height: 16),
            InsightsCards(analytics: analytics).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),

            // 4. Heatmap
            ProductivityHeatmap(
              heatmapData: analytics.heatmapData,
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 32),

            // 5. Advanced Charts
            _buildSectionHeader(l10n.get('stats_charts'), GameTheme.manaBlue),
            const SizedBox(height: 16),
            AdvancedCharts(
              analytics: analytics,
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 32),

            // 6. RPG Stats Detail
            _buildSectionHeader(l10n.get('stats_rpg'), GameTheme.hpRed),
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
          style: GameTheme.neonTextStyle(color, fontSize: 10),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.3)),
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
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonCyan.withValues(alpha: 0.1),
            blurRadius: 8,
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
            color: GameTheme.goldYellow,
          ),
          _buildSummaryItem(
            icon: Icons.flash_on,
            value: user.totalXp.toString(),
            label: l10n.get('stats_total_xp'),
            color: GameTheme.manaBlue,
          ),
          _buildSummaryItem(
            icon: Icons.check_circle,
            value: completed.toString(),
            label: l10n.get('task_tab_completed'),
            color: GameTheme.staminaGreen,
          ),
          _buildSummaryItem(
            icon: Icons.pending_actions,
            value: incomplete.toString(),
            label: l10n.get('task_tab_active'),
            color: GameTheme.goldYellow,
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
          size: 22,
          shadows: [Shadow(color: color, blurRadius: 10)],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            color: color,
            letterSpacing: 0.5,
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
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.neonCyan.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonCyan.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('stats_level'),
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: GameTheme.neonCyan,
              fontSize: 8,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.level}',
            style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 22),
          ),
          const SizedBox(height: 12),
          RpgStatusBar(
            value: xpProgress > 1 ? 1 : xpProgress,
            barColor: GameTheme.neonCyan,
            height: 12,
            segments: 5,
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
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.goldYellow.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.goldYellow.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            color: GameTheme.goldYellow,
            size: 24,
            shadows: [Shadow(color: GameTheme.goldYellow, blurRadius: 12)],
          ),
          const SizedBox(height: 8),
          Text(
            '${user.streak}',
            style: GameTheme.neonTextStyle(GameTheme.goldYellow, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('stats_streak'),
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: GameTheme.goldYellow,
              fontSize: 8,
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
        'color': GameTheme.manaBlue,
        'icon': Icons.school,
      },
      {
        'label': 'DISCIPLINE',
        'value': user.discipline,
        'color': GameTheme.staminaGreen,
        'icon': Icons.fitness_center,
      },
      {
        'label': 'HEALTH',
        'value': user.health,
        'color': GameTheme.hpRed,
        'icon': Icons.favorite,
      },
      {
        'label': 'WEALTH',
        'value': user.wealth,
        'color': GameTheme.goldYellow,
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
                color: GameTheme.surface,
                border: Border.all(
                  color: statColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statColor.withValues(alpha: 0.08),
                    blurRadius: 6,
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
                        size: 16,
                        color: statColor,
                        shadows: [Shadow(color: statColor, blurRadius: 8)],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stat['label'] as String,
                        style: GameTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: statColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: statColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${stat['value']} / $maxValue',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
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
                    height: 14,
                    segments: 10,
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
