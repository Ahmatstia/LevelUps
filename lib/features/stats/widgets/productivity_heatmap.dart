import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';

class ProductivityHeatmap extends ConsumerWidget {
  final Map<DateTime, int> heatmapData;

  const ProductivityHeatmap({required this.heatmapData, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    // Generate dates for the last 90 days (approx 13 weeks)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate start date so that the grid aligns nicely (ending on today's weekday)
    final startDate = today.subtract(
      const Duration(days: 89),
    ); // 90 days including today

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.get('stats_heatmap'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                l10n.get('stats_heatmap_desc'),
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Scrollable Heatmap horizontally
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, // Start scrolled to the right (most recent)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekday labels (optional, simplified here)
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.get('cal_mon'),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('cal_wed'),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.get('cal_fri'),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<DateTime> dates, int maxTasks) {
    // A grid representing weeks as columns and days as rows.
    // In Flutter, a Wrap or customized Table works well for this.

    // Split dates into weeks (roughly 13-14 columns)
    List<List<DateTime>> columns = [];
    List<DateTime> currentColumn = [];

    // To align correctly, we need to know what day of week the first date is
    int paddingDays = dates.first.weekday - 1; // 1 = Monday, padding is 0.

    for (int i = 0; i < paddingDays; i++) {
      currentColumn.add(DateTime(1970)); // Dummy empty date
    }

    for (var date in dates) {
      currentColumn.add(date);
      if (currentColumn.length == 7) {
        columns.add(currentColumn);
        currentColumn = [];
      }
    }

    if (currentColumn.isNotEmpty) {
      // pad the rest of the last column
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
      color = const Color(0xFF2D2D2D);
    } else {
      // Determine intensity (1 to 4 scaling similar to Github)
      double ratio = count / maxTasks;
      if (ratio <= 0.25) {
        color = Colors.green[800]!;
      } else if (ratio <= 0.5) {
        color = Colors.green[600]!;
      } else if (ratio <= 0.75) {
        color = Colors.green[400]!;
      } else {
        color = Colors.greenAccent[400]!;
      }
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildLegendBox(int intensity) {
    Color color;
    switch (intensity) {
      case 0:
        color = const Color(0xFF2D2D2D);
        break;
      case 1:
        color = Colors.green[800]!;
        break;
      case 2:
        color = Colors.green[600]!;
        break;
      case 3:
        color = Colors.green[400]!;
        break;
      case 4:
        color = Colors.greenAccent[400]!;
        break;
      default:
        color = const Color(0xFF2D2D2D);
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
