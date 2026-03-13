import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/sfx_service.dart';
import '../../core/widgets/xp_floating_text.dart';
import 'widgets/add_task_bottom_sheet.dart';
import 'widgets/calendar_view.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _selectedMainTab = 0; // 0: Today, 1: All Tasks, 2: Calendar
  int _selectedSubTab = 0; // 0: To Do, 1: Completed (for All Tasks)

  @override
  Widget build(BuildContext context) {
    final todayTasks = ref.watch(todayTasksProvider);
    final overdueTasks = ref.watch(overdueTasksProvider);
    final incompleteTasks = ref.watch(incompleteTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          l10n.get('nav_tasks'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppTheme.primary,
              size: 24,
            ),
            onPressed: () {
              ref.invalidate(taskProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.surface,
                  content: Text(
                    'Tasks refreshed',
                    style: TextStyle(color: AppTheme.primaryDark),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Game-styled Main Tab Bar ─────────────────────────────
          _buildMainRpgTabs(
            todayTasks.length + overdueTasks.length,
            incompleteTasks.length,
          ),
          // ── Content ─────────────────────────────────────────────
          Expanded(
            child: _selectedMainTab == 0
                ? _buildTodayView(todayTasks, overdueTasks, l10n)
                : _selectedMainTab == 1
                ? _buildAllTasksView(incompleteTasks, completedTasks, l10n)
                : _buildCalendarView(),
          ),
        ],
      ),
      floatingActionButton: _buildGameFAB(l10n),
    );
  }

  // ── Tab Bars ────────────────────────────────────────────────────

  Widget _buildMainRpgTabs(int todayCount, int allCount) {
    final tabs = [('TODAY', todayCount), ('ALL', allCount), ('MAP', 0)];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedMainTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMainTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tabs[i].$1,
                      style: AppTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (tabs[i].$2 > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tabs[i].$2.toString(),
                          style: AppTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 8,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubRpgTabs(
    String label1,
    int count1,
    String label2,
    int count2,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [_subTab(label1, count1, 0), _subTab(label2, count2, 1)],
      ),
    );
  }

  Widget _subTab(String label, int count, int index) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              count > 0 ? '$label ($count)' : label,
              style: AppTheme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.accent : Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Views ────────────────────────────────────────────────────────

  Widget _buildTodayView(
    List<TaskModel> todayTasks,
    List<TaskModel> overdueTasks,
    dynamic l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            _getTodayDate(),
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primary,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MISSION LOG',
            style: AppTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),

          // ── Overdue Tasks
          if (overdueTasks.isNotEmpty) ...[
            _buildSectionHeader('⚠  OVERDUE', AppTheme.hpRed),
            const SizedBox(height: 8),
            ...overdueTasks.asMap().entries.map(
              (e) => _buildTaskCard(e.value, isOverdue: true)
                  .animate(delay: (e.key * 60).ms)
                  .slideX(begin: -0.3, duration: 300.ms)
                  .fadeIn(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Today Tasks
          if (todayTasks.isNotEmpty) ...[
            _buildSectionHeader('ACTIVE QUESTS', AppTheme.primary),
            const SizedBox(height: 8),
            ...todayTasks.asMap().entries.map(
              (e) => _buildTaskCard(e.value)
                  .animate(delay: (e.key * 60).ms)
                  .slideX(begin: -0.3, duration: 300.ms)
                  .fadeIn(),
            ),
          ],

          // ── Empty State
          if (overdueTasks.isEmpty && todayTasks.isEmpty)
            _buildEmptyState(l10n),
        ],
      ),
    );
  }

  Widget _buildAllTasksView(
    List<TaskModel> incomplete,
    List<TaskModel> completed,
    dynamic l10n,
  ) {
    return Column(
      children: [
        _buildSubRpgTabs(
          l10n.get('task_tab_active'),
          incomplete.length,
          l10n.get('task_tab_completed'),
          completed.length,
        ),
        Expanded(
          child: _selectedSubTab == 0
              ? _buildGameTaskList(
                  incomplete,
                  emptyMessage: 'NO ACTIVE QUESTS\nPress [+] to add one',
                )
              : _buildGameTaskList(
                  completed,
                  emptyMessage: 'NO COMPLETED QUESTS YET',
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() => const CalendarView();

  Widget _buildGameTaskList(
    List<TaskModel> tasks, {
    required String emptyMessage,
  }) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[800]),
            const SizedBox(height: 16),
            ...emptyMessage
                .split('\n')
                .map(
                  (line) => Text(
                    line,
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index])
            .animate(delay: (index * 50).ms)
            .slideX(begin: -0.2, duration: 250.ms)
            .fadeIn();
      },
    );
  }

  // ── Task Card ────────────────────────────────────────────────────

  Widget _buildTaskCard(TaskModel task, {bool isOverdue = false}) {
    final borderColor = isOverdue
        ? AppTheme.hpRed.withOpacity(0.5)
        : task.isCompleted
        ? AppTheme.staminaGreen.withOpacity(0.5)
        : Colors.transparent;

    final bgColor = task.isCompleted ? AppTheme.background : AppTheme.surface;

    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: task.isCompleted ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Action Button (Checkbox) ──────────────
          _buildActionButton(task, isOverdue),
          const SizedBox(width: 14),

          // ── Task Body ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.grey[400] : AppTheme.primaryDark,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.description,
                    style: AppTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                _buildTaskBadges(task, isOverdue),
              ],
            ),
          ),

          // ── Right side: XP + delete ───────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.goldYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${task.difficulty.xpValue} XP',
                  style: AppTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldYellow,
                  ),
                ),
              ),
              if (task.isCompleted) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _deleteTask(task.id),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppTheme.hpRed.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(TaskModel task, bool isOverdue) {
    final color = isOverdue
        ? AppTheme.hpRed
        : task.isCompleted
        ? AppTheme.staminaGreen
        : AppTheme.primary;

    return Builder(
      builder: (ctx) {
        return GestureDetector(
          onTap: task.isCompleted ? null : () => _completeTask(task, ctx),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? Icon(Icons.check, color: color, size: 18)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTaskBadges(TaskModel task, bool isOverdue) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (task.dueDate != null)
          _badge(
            isOverdue ? '⚠ OVERDUE' : _formatDueTime(task.dueDate!),
            _getDueDateColor(task),
          ),
        if (task.energyLevel != null)
          _badge(
            task.energyLevel!.displayName,
            _getEnergyColor(task.energyLevel!),
          ),
        _badge(
          task.difficulty.displayName,
          _getDifficultyColor(task.difficulty),
        ),
        _badge(task.statType.name.toUpperCase(), _getStatColor(task.statType)),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: AppTheme.textTheme.bodySmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: AppTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: color.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(dynamic l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.beach_access, size: 56, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'NO MISSIONS TODAY',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'REST, OR START A NEW QUEST',
            style: AppTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showAddTaskSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+ NEW QUEST',
                style: AppTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameFAB(dynamic l10n) {
    return GestureDetector(
      onTap: _showAddTaskSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'NEW QUEST',
              style: AppTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────

  Future<void> _completeTask(TaskModel task, BuildContext cardCtx) async {
    // Show floating +XP text
    final renderBox = cardCtx.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      XpFloatingText.show(
        context,
        renderBox: renderBox,
        xp: task.difficulty.xpValue,
      );
    }

    // Play SFX
    SfxService.instance.playTaskComplete();

    try {
      await ref.read(taskProvider.notifier).completeTask(task.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.hpRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await ref.read(taskProvider.notifier).deleteTask(taskId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.hpRed,
          ),
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

  // ── Helpers ──────────────────────────────────────────────────────

  String _getTodayDate() {
    final now = DateTime.now();
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${days[now.weekday % 7]}  ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatDueTime(DateTime dueDate) {
    final now = DateTime.now();
    if (dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day) {
      return 'TODAY ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day) {
      return 'TOMORROW ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
    }
    return '${dueDate.day}/${dueDate.month} ${dueDate.hour}:${dueDate.minute.toString().padLeft(2, '0')}';
  }

  Color _getDueDateColor(TaskModel task) {
    if (task.isCompleted) return AppTheme.staminaGreen;
    if (task.isOverdue) return AppTheme.hpRed;
    final timeLeft = task.timeLeft;
    if (timeLeft == null) return Colors.grey;
    if (timeLeft.inHours < 6) return Colors.orange;
    if (timeLeft.inHours < 24) return AppTheme.goldYellow;
    return Colors.grey[600]!;
  }

  Color _getEnergyColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return AppTheme.staminaGreen;
      case EnergyLevel.medium:
        return AppTheme.goldYellow;
      case EnergyLevel.high:
        return AppTheme.hpRed;
    }
  }

  Color _getStatColor(StatType stat) {
    switch (stat) {
      case StatType.intelligence:
        return AppTheme.manaBlue;
      case StatType.discipline:
        return AppTheme.staminaGreen;
      case StatType.health:
        return AppTheme.hpRed;
      case StatType.wealth:
        return AppTheme.goldYellow;
    }
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return AppTheme.staminaGreen;
      case TaskDifficulty.medium:
        return AppTheme.goldYellow;
      case TaskDifficulty.hard:
        return AppTheme.hpRed;
    }
  }
}
