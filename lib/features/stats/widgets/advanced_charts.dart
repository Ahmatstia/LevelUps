import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/analytics_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/game_theme.dart';

class AdvancedCharts extends ConsumerWidget {
  final AnalyticsData analytics;

  const AdvancedCharts({required this.analytics, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLineChartCard(l10n),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBarChartCard(l10n)),
            const SizedBox(width: 12),
            Expanded(child: _buildPieChartCard(l10n)),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChartCard(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.manaBlue.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.manaBlue.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('chart_xp').toString().toUpperCase(),
            style: GameTheme.textTheme.bodySmall?.copyWith(
              fontSize: 9,
              color: GameTheme.manaBlue,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('chart_xp_desc'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          '6d',
                          '5d',
                          '4d',
                          '3d',
                          '2d',
                          '1d',
                          l10n.get('task_tab_today'),
                        ];
                        if (value >= 0 && value < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                            fontSize: 9,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY:
                    (analytics.weeklyXpGrowth.reduce((a, b) => a > b ? a : b) +
                            50)
                        .ceilToDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (index) {
                      return FlSpot(
                        index.toDouble(),
                        analytics.weeklyXpGrowth[index],
                      );
                    }),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [GameTheme.neonCyan, GameTheme.neonPink],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: GameTheme.neonCyan,
                          strokeWidth: 1,
                          strokeColor: Colors.white24,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          GameTheme.neonCyan.withValues(alpha: 0.2),
                          GameTheme.neonPink.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(dynamic l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.staminaGreen.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.staminaGreen.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('chart_tasks').toString().toUpperCase(),
            style: GameTheme.textTheme.bodySmall?.copyWith(
              fontSize: 8,
              color: GameTheme.staminaGreen,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    (analytics.weeklyTaskCompletions.reduce(
                              (a, b) => a > b ? a : b,
                            ) +
                            2)
                        .toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['6', '5', '4', '3', '2', '1', 'T'];
                        if (value >= 0 && value < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: analytics.weeklyTaskCompletions[index].toDouble(),
                        gradient: const LinearGradient(
                          colors: [GameTheme.staminaGreen, GameTheme.neonCyan],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 10,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(dynamic l10n) {
    final dist = analytics.quadrantDistribution;
    final total = dist.values.fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(
          color: GameTheme.neonPink.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonPink.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('chart_quadrant').toString().toUpperCase(),
            style: GameTheme.textTheme.bodySmall?.copyWith(
              fontSize: 8,
              color: GameTheme.neonPink,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: total == 0
                ? Center(
                    child: Text(
                      l10n.get('dash_empty_tasks').split('\n')[0],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                      sections: [
                        _buildPieSection(
                          dist[QuadrantType.doFirst]!,
                          total,
                          GameTheme.hpRed,
                          'Q1',
                        ),
                        _buildPieSection(
                          dist[QuadrantType.schedule]!,
                          total,
                          GameTheme.manaBlue,
                          'Q2',
                        ),
                        _buildPieSection(
                          dist[QuadrantType.delegate]!,
                          total,
                          GameTheme.goldYellow,
                          'Q3',
                        ),
                        _buildPieSection(
                          dist[QuadrantType.eliminate]!,
                          total,
                          GameTheme.staminaGreen,
                          'Q4',
                        ),
                      ].where((section) => section.value > 0).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(
    int count,
    int total,
    Color color,
    String title,
  ) {
    return PieChartSectionData(
      color: color,
      value: count.toDouble(),
      title: title,
      radius: 36,
      titleStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
