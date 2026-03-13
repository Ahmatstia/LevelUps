import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

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
                iconColor: AppTheme.manaBlue,
                title: l10n.get('insight_prod_time'),
                value: analytics.mostProductiveTime,
                subtitle: l10n.get('insight_prod_time_desc'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInsightCard(
                icon: Icons.calendar_today,
                iconColor: AppTheme.accent,
                title: l10n.get('insight_best_day'),
                value: analytics.mostProductiveDay,
                subtitle: l10n.get('insight_best_day_desc'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInsightCard(
                icon: Icons.timer,
                iconColor: AppTheme.staminaGreen,
                title: l10n.get('insight_avg_time'),
                value: _formatDuration(analytics.averageCompletionTime, l10n),
                subtitle: l10n.get('insight_avg_time_desc'),
              ),
            ),
            const SizedBox(width: 12),
            if (analytics.isBurnoutRisk)
              Expanded(
                child: _buildInsightCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppTheme.hpRed,
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
                  iconColor: AppTheme.staminaGreen,
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
    final borderColor = isAlert
        ? AppTheme.hpRed.withOpacity(0.4)
        : iconColor.withOpacity(0.2);
    final bgColor = isAlert
        ? AppTheme.hpRed.withOpacity(0.08)
        : AppTheme.surface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor, 
          width: isAlert ? 1.5 : 1
        ),
        boxShadow: isAlert ? [] : [
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isAlert ? AppTheme.hpRed : AppTheme.primaryDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
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
