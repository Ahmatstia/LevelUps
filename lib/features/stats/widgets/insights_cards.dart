import 'package:flutter/material.dart';
import '../../../core/providers/analytics_provider.dart';

class InsightsCards extends StatelessWidget {
  final AnalyticsData analytics;

  const InsightsCards({required this.analytics, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.access_time_filled,
                iconColor: Colors.blue,
                title: 'Most Productive Time',
                value: analytics.mostProductiveTime,
                subtitle: 'Based on completion hours',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInsightCard(
                icon: Icons.calendar_today,
                iconColor: Colors.purple,
                title: 'Best Day',
                value: analytics.mostProductiveDay,
                subtitle: 'Day with most completions',
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
                title: 'Avg. Completion Time',
                value: _formatDuration(analytics.averageCompletionTime),
                subtitle: 'From creation to done',
              ),
            ),
            const SizedBox(width: 16),
            if (analytics.isBurnoutRisk)
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.red,
                  title: 'Burnout Risk',
                  value: 'High Load Detected',
                  subtitle: 'Take a break! >25 tasks',
                  isAlert: true,
                ),
              )
            else
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.spa,
                  iconColor: Colors.teal,
                  title: 'Pace',
                  value: 'Healthy',
                  subtitle: 'Sustainable workload',
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

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '< 1m';
    }
  }
}
