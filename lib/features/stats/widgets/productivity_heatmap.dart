import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProductivityHeatmap extends ConsumerWidget {
  final Map<DateTime, int> heatmapData;

  const ProductivityHeatmap({required this.heatmapData, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    // Generate dates for the last 90 days (approx 13 weeks)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate start date so that the grid aligns nicely
    final startDate = today.subtract(const Duration(days: 89));

    // Create list of dates
    List<DateTime> dates = [];
    for (int i = 0; i < 90; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    // Determine max value for color scaling
    int maxTasks = 1;
    for (var count in heatmapData.values) {
      if (count > maxTasks) maxTasks = count;
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.get('stats_heatmap').toUpperCase(),
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.staminaGreen,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.get('stats_heatmap_desc'),
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Scrollable Heatmap horizontally
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekday labels
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.get('cal_mon'),
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('cal_wed'),
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('cal_fri'),
                        style: AppTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildGrid(dates, maxTasks),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.get('heatmap_less'),
                style: AppTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 4),
              _buildLegendBox(0),
              const SizedBox(width: 4),
              _buildLegendBox(1),
              const SizedBox(width: 4),
              _buildLegendBox(2),
              const SizedBox(width: 4),
              _buildLegendBox(3),
              const SizedBox(width: 4),
              _buildLegendBox(4),
              const SizedBox(width: 4),
              Text(
                l10n.get('heatmap_more'),
                style: AppTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<DateTime> dates, int maxTasks) {
    List<List<DateTime>> columns = [];
    List<DateTime> currentColumn = [];

    int paddingDays = dates.first.weekday - 1;

    for (int i = 0; i < paddingDays; i++) {
      currentColumn.add(DateTime(1970));
    }

    for (var date in dates) {
      currentColumn.add(date);
      if (currentColumn.length == 7) {
        columns.add(currentColumn);
        currentColumn = [];
      }
    }

    if (currentColumn.isNotEmpty) {
      while (currentColumn.length < 7) {
        currentColumn.add(DateTime(1970));
      }
      columns.add(currentColumn);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((col) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Column(
            children: col.map((date) {
              if (date.year == 1970) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: SizedBox(width: 14, height: 14),
                );
              }

              int count = heatmapData[date] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Tooltip(
                  message:
                      '${date.day}/${date.month}/${date.year}: $count tasks',
                  child: _buildCell(count, maxTasks),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCell(int count, int maxTasks) {
    Color color;

    if (count == 0) {
      color = AppTheme.background;
    } else {
      double ratio = count / maxTasks;
      if (ratio <= 0.25) {
        color = AppTheme.primary.withOpacity(0.2);
      } else if (ratio <= 0.5) {
        color = AppTheme.primary.withOpacity(0.4);
      } else if (ratio <= 0.75) {
        color = AppTheme.primary.withOpacity(0.65);
      } else {
        color = AppTheme.primary;
      }
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLegendBox(int intensity) {
    Color color;
    switch (intensity) {
      case 0:
        color = AppTheme.background;
        break;
      case 1:
        color = AppTheme.primary.withOpacity(0.2);
        break;
      case 2:
        color = AppTheme.primary.withOpacity(0.4);
        break;
      case 3:
        color = AppTheme.primary.withOpacity(0.65);
        break;
      case 4:
        color = AppTheme.primary;
        break;
      default:
        color = AppTheme.background;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
