import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/task_provider.dart';
import 'quadrant_selector.dart';
import 'tag_selector.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskDifficulty _selectedDifficulty = TaskDifficulty.medium;
  StatType _selectedStat = StatType.intelligence;
  RecurringType _selectedRecurring = RecurringType.none;
  EnergyLevel _selectedEnergy = EnergyLevel.medium;
  QuadrantType _selectedQuadrant = QuadrantType.doFirst;
  List<String> _selectedTagIds = [];

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Add New Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    const Text(
                      'Task Title',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter task title',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    const Text(
                      'Description (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter task description',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Due Date & Time
                    const Text(
                      'Due Date & Time',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTimePicker()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Recurring
                    const Text(
                      'Repeat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildRecurringChip(RecurringType.none),
                        _buildRecurringChip(RecurringType.daily),
                        _buildRecurringChip(RecurringType.weekly),
                        _buildRecurringChip(RecurringType.monthly),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Energy Level
                    const Text(
                      'Energy Level',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildEnergyChip(EnergyLevel.low),
                        const SizedBox(width: 12),
                        _buildEnergyChip(EnergyLevel.medium),
                        const SizedBox(width: 12),
                        _buildEnergyChip(EnergyLevel.high),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quadrant Selector
                    QuadrantSelector(
                      selectedQuadrant: _selectedQuadrant,
                      onSelected: (quadrant) =>
                          setState(() => _selectedQuadrant = quadrant),
                    ),
                    const SizedBox(height: 20),

                    // Tag Selector
                    TagSelector(
                      selectedTagIds: _selectedTagIds,
                      onChanged: (tagIds) =>
                          setState(() => _selectedTagIds = tagIds),
                    ),
                    const SizedBox(height: 20),

                    // Difficulty Selection
                    const Text(
                      'Difficulty',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDifficultyChip(TaskDifficulty.easy),
                        const SizedBox(width: 12),
                        _buildDifficultyChip(TaskDifficulty.medium),
                        const SizedBox(width: 12),
                        _buildDifficultyChip(TaskDifficulty.hard),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stat Selection
                    const Text(
                      'Stat to Increase',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildStatChip(StatType.intelligence),
                        _buildStatChip(StatType.discipline),
                        _buildStatChip(StatType.health),
                        _buildStatChip(StatType.wealth),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Task',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDueDate == null
                    ? 'Select date'
                    : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                style: TextStyle(
                  color: _selectedDueDate == null
                      ? Colors.grey[600]
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDueTime == null
                    ? 'Select time'
                    : _selectedDueTime!.format(context),
                style: TextStyle(
                  color: _selectedDueTime == null
                      ? Colors.grey[600]
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedDueTime = time;
      });
    }
  }

  Widget _buildRecurringChip(RecurringType type) {
    final isSelected = _selectedRecurring == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedRecurring = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[800]!,
          ),
        ),
        child: Text(
          type.displayName,
          style: TextStyle(color: isSelected ? Colors.blue : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEnergyChip(EnergyLevel level) {
    final isSelected = _selectedEnergy == level;
    Color color;

    switch (level) {
      case EnergyLevel.low:
        color = Colors.green;
        break;
      case EnergyLevel.medium:
        color = Colors.orange;
        break;
      case EnergyLevel.high:
        color = Colors.red;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedEnergy = level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Icon(
                _getEnergyIcon(level),
                size: 20,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                level.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(TaskDifficulty difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    Color color;

    switch (difficulty) {
      case TaskDifficulty.easy:
        color = Colors.green;
        break;
      case TaskDifficulty.medium:
        color = Colors.orange;
        break;
      case TaskDifficulty.hard:
        color = Colors.red;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDifficulty = difficulty),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Text(
                difficulty.displayName,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+${difficulty.xpValue} XP',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(StatType stat) {
    final isSelected = _selectedStat == stat;
    Color color;

    switch (stat) {
      case StatType.intelligence:
        color = Colors.blue;
        break;
      case StatType.discipline:
        color = Colors.green;
        break;
      case StatType.health:
        color = Colors.red;
        break;
      case StatType.wealth:
        color = Colors.amber;
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedStat = stat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatIcon(stat),
              size: 16,
              color: isSelected ? color : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              stat.displayName,
              style: TextStyle(color: isSelected ? color : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Combine date and time if both selected
        DateTime? dueDate;
        if (_selectedDueDate != null) {
          if (_selectedDueTime != null) {
            dueDate = DateTime(
              _selectedDueDate!.year,
              _selectedDueDate!.month,
              _selectedDueDate!.day,
              _selectedDueTime!.hour,
              _selectedDueTime!.minute,
            );
          } else {
            // Default to end of the day if time is not selected
            dueDate = DateTime(
              _selectedDueDate!.year,
              _selectedDueDate!.month,
              _selectedDueDate!.day,
              23,
              59,
              59,
            );
          }
        }

        await ref
            .read(taskProvider.notifier)
            .addTask(
              title: _titleController.text,
              description: _descriptionController.text,
              difficulty: _selectedDifficulty,
              statType: _selectedStat,
              dueDate: dueDate,
              recurringType: _selectedRecurring,
              energyLevel: _selectedEnergy,
              quadrant: _selectedQuadrant,
              tagIds: _selectedTagIds,
            );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  IconData _getStatIcon(StatType stat) {
    switch (stat) {
      case StatType.intelligence:
        return Icons.school;
      case StatType.discipline:
        return Icons.fitness_center;
      case StatType.health:
        return Icons.favorite;
      case StatType.wealth:
        return Icons.attach_money;
    }
  }

  IconData _getEnergyIcon(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return Icons.battery_1_bar;
      case EnergyLevel.medium:
        return Icons.battery_3_bar;
      case EnergyLevel.high:
        return Icons.battery_full;
    }
  }
}
