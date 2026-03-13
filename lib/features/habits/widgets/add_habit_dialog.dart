import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/habit_model.dart';
import '../../../core/providers/habit_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const AddHabitDialog(),
      ),
    );
  }

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedStat = 'discipline';
  HabitFrequency _frequency = HabitFrequency.daily;
  int _xpReward = 15;

  final _stats = [
    {'key': 'intelligence', 'label': 'Intelligence', 'icon': Icons.school},
    {'key': 'discipline', 'label': 'Discipline', 'icon': Icons.fitness_center},
    {'key': 'health', 'label': 'Health', 'icon': Icons.favorite},
    {'key': 'wealth', 'label': 'Wealth', 'icon': Icons.attach_money},
  ];

  Color _statColor(String stat) {
    switch (stat) {
      case 'intelligence':
        return AppTheme.manaBlue;
      case 'health':
        return AppTheme.hpRed;
      case 'wealth':
        return AppTheme.goldYellow;
      default:
        return AppTheme.staminaGreen;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  'NEW HABIT',
                  style: AppTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title field
              _buildTextField(
                _titleController,
                'Habit name (e.g. "Read 30 min")',
              ),
              const SizedBox(height: 12),
              _buildTextField(_descController, 'Description (optional)'),
              const SizedBox(height: 16),

              // Stat selector
              Text(
                'STAT',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _stats.map((s) {
                  final key = s['key'] as String;
                  final isSelected = _selectedStat == key;
                  final color = _statColor(key);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStat = key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.1)
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(s['icon'] as IconData, color: color, size: 18),
                            const SizedBox(height: 4),
                            Text(
                              (s['label'] as String)
                                  .substring(0, 3)
                                  .toUpperCase(),
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? color : Colors.grey[600],
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Frequency
              Text(
                'FREQUENCY',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: HabitFrequency.values.map((f) {
                  final isSelected = _frequency == f;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _frequency = f;
                        _xpReward = f == HabitFrequency.daily ? 15 : 40;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withOpacity(0.1)
                              : AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              f.displayName.toUpperCase(),
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.grey[600],
                                ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+$_xpReward XP',
                                style: AppTheme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.goldYellow,
                                ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_titleController.text.trim().isEmpty) return;
                    await ref
                        .read(habitProvider.notifier)
                        .addHabit(
                          title: _titleController.text.trim(),
                          description: _descController.text.trim(),
                          statType: _selectedStat,
                          frequency: _frequency,
                          xpReward: _xpReward,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    'ADD HABIT',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: AppTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.primaryDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
