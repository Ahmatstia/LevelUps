import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/locale_provider.dart';

class InsightsCards extends ConsumerWidget {
  final AnalyticsData analytics;

  const InsightsCards({required this.analytics, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.access_time_filled,
                iconColor: Colors.blue,
                title: l10n.get('insight_prod_time'),
                value: analytics.mostProductiveTime,
                subtitle: l10n.get('insight_prod_time_desc'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInsightCard(
                icon: Icons.calendar_today,
                iconColor: Colors.purple,
                title: l10n.get('insight_best_day'),
                value: analytics.mostProductiveDay,
                subtitle: l10n.get('insight_best_day_desc'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.timer,
                iconColor: Colors.green,
                title: l10n.get('insight_avg_time'),
                value: _formatDuration(analytics.averageCompletionTime, l10n),
                subtitle: l10n.get('insight_avg_time_desc'),
              ),
            ),
            const SizedBox(width: 16),
            if (analytics.isBurnoutRisk)
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.red,
                  title: l10n.get('insight_burnout'),
                  value: l10n.get('insight_burnout_val'),
                  subtitle: l10n.get('insight_burnout_desc'),
                  isAlert: true,
                ),
              )
            else
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.spa,
                  iconColor: Colors.teal,
                  title: l10n.get('insight_pace'),
                  value: l10n.get('insight_pace_val'),
                  subtitle: l10n.get('insight_pace_desc'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.withValues(alpha: 0.1) : Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAlert
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isAlert ? Colors.red[300] : Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration, dynamic l10n) {
    if (duration.inDays > 0) {
      return '${duration.inDays}${l10n.get('time_d')} ${duration.inHours % 24}${l10n.get('time_h')}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}${l10n.get('time_h')} ${duration.inMinutes % 60}${l10n.get('time_m')}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}${l10n.get('time_m')}';
    } else {
      return '< 1${l10n.get('time_m')}';
    }
  }
}
