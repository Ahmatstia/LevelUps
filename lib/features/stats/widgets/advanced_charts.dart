import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/analytics_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

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
            l10n.get('chart_xp').toString().toUpperCase(),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.manaBlue,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.get('chart_xp_desc'),
            style: AppTheme.textTheme.bodySmall?.copyWith(
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
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
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
                              style: AppTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
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
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: AppTheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.2),
                          AppTheme.accent.withOpacity(0.0),
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
            l10n.get('chart_tasks').toString().toUpperCase(),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.staminaGreen,
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
                              style: AppTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
                        gradient: LinearGradient(
                          colors: [AppTheme.staminaGreen, AppTheme.primary],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
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
            l10n.get('chart_quadrant').toString().toUpperCase(),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
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
                      style: AppTheme.textTheme.bodySmall?.copyWith(
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
                          AppTheme.hpRed,
                          'Q1',
                        ),
                        _buildPieSection(
                          dist[QuadrantType.schedule]!,
                          total,
                          AppTheme.manaBlue,
                          'Q2',
                        ),
                        _buildPieSection(
                          dist[QuadrantType.delegate]!,
                          total,
                          AppTheme.goldYellow,
                          'Q3',
                        ),
                        _buildPieSection(
                          dist[QuadrantType.eliminate]!,
                          total,
                          AppTheme.staminaGreen,
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
      titleStyle: AppTheme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
