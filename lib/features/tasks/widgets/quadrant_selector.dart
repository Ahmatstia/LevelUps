import 'package:flutter/material.dart';
import '../../../core/models/task_model.dart';

class QuadrantSelector extends StatelessWidget {
  final QuadrantType selectedQuadrant;
  final Function(QuadrantType) onSelected;

  const QuadrantSelector({
    super.key,
    required this.selectedQuadrant,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final quadrants = [
      {
        'type': QuadrantType.doFirst,
        'title': 'Do First',
        'desc': 'Important & Urgent',
        'color': Colors.red,
        'icon': Icons.priority_high,
      },
      {
        'type': QuadrantType.schedule,
        'title': 'Schedule',
        'desc': 'Important & Not Urgent',
        'color': Colors.blue,
        'icon': Icons.calendar_today,
      },
      {
        'type': QuadrantType.delegate,
        'title': 'Delegate',
        'desc': 'Not Important & Urgent',
        'color': Colors.orange,
        'icon': Icons.person_outline,
      },
      {
        'type': QuadrantType.eliminate,
        'title': 'Eliminate',
        'desc': 'Not Important & Not Urgent',
        'color': Colors.grey,
        'icon': Icons.delete_outline,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Quadrant',
          style: TextStyle(
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
