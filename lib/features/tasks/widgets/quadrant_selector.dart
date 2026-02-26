import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/locale_provider.dart';

class QuadrantSelector extends ConsumerWidget {
  final QuadrantType selectedQuadrant;
  final Function(QuadrantType) onSelected;

  const QuadrantSelector({
    super.key,
    required this.selectedQuadrant,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);

    final quadrants = [
      {
        'type': QuadrantType.doFirst,
        'title': l10n.get('task_quadrant_do'),
        'desc': l10n.get('task_quadrant_do_desc'),
        'color': Colors.red,
        'icon': Icons.priority_high,
      },
      {
        'type': QuadrantType.schedule,
        'title': l10n.get('task_quadrant_schedule'),
        'desc': l10n.get('task_quadrant_schedule_desc'),
        'color': Colors.blue,
        'icon': Icons.calendar_today,
      },
      {
        'type': QuadrantType.delegate,
        'title': l10n.get('task_quadrant_delegate'),
        'desc': l10n.get('task_quadrant_delegate_desc'),
        'color': Colors.orange,
        'icon': Icons.person_outline,
      },
      {
        'type': QuadrantType.eliminate,
        'title': l10n.get('task_quadrant_eliminate'),
        'desc': l10n.get('task_quadrant_eliminate_desc'),
        'color': Colors.grey,
        'icon': Icons.delete_outline,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('task_quadrant'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...quadrants.map(
          (q) => GestureDetector(
            onTap: () => onSelected(q['type'] as QuadrantType),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedQuadrant == q['type']
                    ? (q['color'] as Color).withValues(alpha: 0.2)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedQuadrant == q['type']
                      ? q['color'] as Color
                      : Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (q['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      q['icon'] as IconData,
                      color: q['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedQuadrant == q['type']
                                ? q['color'] as Color
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          q['desc'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedQuadrant == q['type'])
                    Icon(
                      Icons.check_circle,
                      color: q['color'] as Color,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
