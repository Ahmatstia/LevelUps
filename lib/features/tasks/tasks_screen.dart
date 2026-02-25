import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/task_model.dart';
import 'widgets/add_task_bottom_sheet.dart';
import 'widgets/calendar_view.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _selectedMainTab = 0; // 0: Today, 1: All Tasks, 2: Calendar
  int _selectedSubTab = 0; // 0: To Do, 1: Completed (untuk All Tasks)

  @override
  Widget build(BuildContext context) {
    final todayTasks = ref.watch(todayTasksProvider);
    final overdueTasks = ref.watch(overdueTasksProvider);
    // Hapus variable allTasks yang tidak dipakai
    final incompleteTasks = ref.watch(incompleteTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              ref.invalidate(taskProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tasks refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Tab Bar (Today, All Tasks, Calendar)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildMainTab(
                  'Today',
                  0,
                  todayTasks.length + overdueTasks.length,
                ),
                _buildMainTab('All Tasks', 1, incompleteTasks.length),
                _buildMainTab('Calendar', 2, 0),
              ],
            ),
          ),

          // Content based on main tab
          Expanded(
            child: _selectedMainTab == 0
                ? _buildTodayView(todayTasks, overdueTasks)
                : _selectedMainTab == 1
                ? _buildAllTasksView(incompleteTasks, completedTasks)
                : _buildCalendarView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMainTab(String label, int index, int count) {
    final isSelected = _selectedMainTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMainTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // TODAY VIEW
  Widget _buildTodayView(
    List<TaskModel> todayTasks,
    List<TaskModel> overdueTasks,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Text(
            _getTodayDate(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            "Today's Focus",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Overdue Tasks Section
          if (overdueTasks.isNotEmpty) ...[
            const Text(
              '⚠️ Overdue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ...overdueTasks.map(
              (task) => _buildTaskCard(task, isOverdue: true),
            ),
            const SizedBox(height: 20),
          ],

          // Today's Tasks Section
          if (todayTasks.isNotEmpty) ...[
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...todayTasks.map((task) => _buildTaskCard(task)),
          ],

          // Empty State
          if (overdueTasks.isEmpty && todayTasks.isEmpty)
            _buildEmptyTodayView(),
        ],
      ),
    );
  }

  // ALL TASKS VIEW
  Widget _buildAllTasksView(
    List<TaskModel> incomplete,
    List<TaskModel> completed,
  ) {
    return Column(
      children: [
        // Sub Tab (To Do / Completed)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _buildSubTab('To Do', 0, incomplete.length),
              _buildSubTab('Completed', 1, completed.length),
            ],
          ),
        ),

        // Tasks List
        Expanded(
          child: _selectedSubTab == 0
              ? _buildTaskList(incomplete, isEmptyMessage: 'No tasks yet')
              : _buildTaskList(completed, isEmptyMessage: 'No completed tasks'),
        ),
      ],
    );
  }

  Widget _buildSubTab(String label, int index, int count) {
    final isSelected = _selectedSubTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              count > 0 ? '$label ($count)' : label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // CALENDAR VIEW (Placeholder)
  Widget _buildCalendarView() {
    return const CalendarView();
  }

  Widget _buildTaskList(
    List<TaskModel> tasks, {
    required String isEmptyMessage,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              isEmptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTaskCard(task),
        );
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, {bool isOverdue = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : task.isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: task.isCompleted ? null : () => _completeTask(task.id),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted
                      ? Colors.green
                      : isOverdue
                      ? Colors.red
                      : Colors.grey.withValues(alpha: 0.5),
                  width: task.isCompleted ? 2 : 1,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.green, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),

                // Description (if any)
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 8),

                // Metadata Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Due Date Badge
                    if (task.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDueDateColor(task).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOverdue ? Icons.warning : Icons.access_time,
                              size: 12,
                              color: _getDueDateColor(task),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOverdue
                                  ? 'Overdue'
                                  : _formatDueTime(task.dueDate!),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getDueDateColor(task),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Energy Level Badge
                    if (task.energyLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getEnergyColor(
                            task.energyLevel!,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getEnergyIcon(task.energyLevel!),
                              size: 12,
                              color: _getEnergyColor(task.energyLevel!),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.energyLevel!.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getEnergyColor(task.energyLevel!),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Difficulty Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          task.difficulty,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.difficulty.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getDifficultyColor(task.difficulty),
                        ),
                      ),
                    ),

                    // Stat Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatColor(
                          task.statType,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatIcon(task.statType),
                            size: 10,
                            color: _getStatColor(task.statType),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${task.difficulty.xpValue} XP',
                            style: TextStyle(
                              fontSize: 10,
                              color: _getStatColor(task.statType),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Time Left (if not completed and not overdue)
                if (!task.isCompleted && !isOverdue && task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      task.timeLeftText,
                      style: TextStyle(
                        // Perbaiki null safety dengan mengecek timeLeft
                        fontSize: 11,
                        color:
                            (task.timeLeft != null &&
                                task.timeLeft!.inHours < 6)
                            ? Colors.orange
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Delete Button (for completed tasks)
          if (task.isCompleted)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => _deleteTask(task.id),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyTodayView() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.beach_access, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text(
            'All done for today!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tasks due today. Enjoy your day or add new tasks.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddTaskSheet,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeTask(String taskId) async {
    try {
      await ref.read(taskProvider.notifier).completeTask(taskId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task completed! +XP'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
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

  Future<void> _deleteTask(String taskId) async {
    try {
      await ref.read(taskProvider.notifier).deleteTask(taskId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 1),
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

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  // Helper Methods
  String _getTodayDate() {
    final now = DateTime.now();
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatDueTime(DateTime dueDate) {
    final now = DateTime.now();

    if (dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day) {
      return 'Today ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
    }

    final tomorrow = now.add(const Duration(days: 1));
    if (dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day) {
      return 'Tomorrow ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
    }

    return '${dueDate.day}/${dueDate.month} ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
  }

  Color _getDueDateColor(TaskModel task) {
    if (task.isCompleted) return Colors.green;
    if (task.isOverdue) return Colors.red;

    final timeLeft = task.timeLeft;
    if (timeLeft == null) return Colors.grey;

    if (timeLeft.inHours < 6) {
      return Colors.orange;
    } else if (timeLeft.inHours < 24) {
      return Colors.yellow;
    }
    return Colors.grey;
  }

  Color _getEnergyColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return Colors.green;
      case EnergyLevel.medium:
        return Colors.orange;
      case EnergyLevel.high:
        return Colors.red;
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

  Color _getStatColor(StatType stat) {
    switch (stat) {
      case StatType.intelligence:
        return Colors.blue;
      case StatType.discipline:
        return Colors.green;
      case StatType.health:
        return Colors.red;
      case StatType.wealth:
        return Colors.amber;
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

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return Colors.green;
      case TaskDifficulty.medium:
        return Colors.orange;
      case TaskDifficulty.hard:
        return Colors.red;
    }
  }
}
