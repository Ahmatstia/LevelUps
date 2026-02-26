import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/task_provider.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/game_theme.dart';
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
      backgroundColor: GameTheme.background,
      appBar: AppBar(
        backgroundColor: GameTheme.background,
        elevation: 0,
        title: Text(
          l10n.get('nav_tasks'),
          style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: GameTheme.neonCyan.withValues(alpha: 0.7),
              size: 20,
            ),
            onPressed: () {
              ref.invalidate(taskProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: GameTheme.surface,
                  content: Text(
                    'Tasks refreshed',
                    style: TextStyle(color: Colors.white),
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
        color: GameTheme.surface,
        border: Border.all(color: Colors.white12, width: 1.5),
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
                        color: GameTheme.neonCyan.withValues(alpha: 0.15),
                        border: Border.all(
                          color: GameTheme.neonCyan,
                          width: 1.5,
                        ),
                      )
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tabs[i].$1,
                      style: GameTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: isSelected
                            ? GameTheme.neonCyan
                            : Colors.grey[600],
                        letterSpacing: 1,
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
                              ? GameTheme.neonCyan
                              : Colors.grey[700],
                        ),
                        child: Text(
                          tabs[i].$2.toString(),
                          style: TextStyle(
                            fontSize: 8,
                            color: isSelected
                                ? GameTheme.background
                                : Colors.white,
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
        color: GameTheme.surface,
        border: Border.all(color: Colors.white10, width: 1),
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
          color: isSelected
              ? GameTheme.neonPink.withValues(alpha: 0.15)
              : Colors.transparent,
          child: Center(
            child: Text(
              count > 0 ? '$label ($count)' : label,
              style: GameTheme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: isSelected ? GameTheme.neonPink : Colors.grey[600],
                letterSpacing: 0.8,
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
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: GameTheme.neonCyan.withValues(alpha: 0.6),
              letterSpacing: 1,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MISSION LOG',
            style: GameTheme.neonTextStyle(GameTheme.neonCyan, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // ── Overdue Tasks
          if (overdueTasks.isNotEmpty) ...[
            _buildSectionHeader('⚠  OVERDUE', GameTheme.hpRed),
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
            _buildSectionHeader('►  ACTIVE QUESTS', GameTheme.neonCyan),
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
                    style: GameTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontSize: 10,
                      letterSpacing: 1.5,
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
        ? GameTheme.hpRed
        : task.isCompleted
        ? GameTheme.staminaGreen
        : GameTheme.neonCyan.withValues(alpha: 0.3);

    final glowColor = isOverdue
        ? GameTheme.hpRed
        : task.isCompleted
        ? GameTheme.staminaGreen
        : GameTheme.neonCyan;

    return Container(
      key: ValueKey(task.id),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: task.isCompleted ? Colors.grey[600] : Colors.white,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.grey[600],
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
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
                  color: GameTheme.goldYellow.withValues(alpha: 0.1),
                  border: Border.all(
                    color: GameTheme.goldYellow.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '+${task.difficulty.xpValue} XP',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.goldYellow,
                  ),
                ),
              ),
              if (task.isCompleted) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _deleteTask(task.id),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.grey[700],
                    size: 18,
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
        ? GameTheme.hpRed
        : task.isCompleted
        ? GameTheme.staminaGreen
        : GameTheme.neonCyan;

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
                  ? color.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: color,
                width: task.isCompleted ? 2 : 1.5,
              ),
              boxShadow: task.isCompleted
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
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
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: GameTheme.textTheme.bodySmall?.copyWith(
            color: color,
            fontSize: 9,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(height: 1, color: color.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(dynamic l10n) {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: GameTheme.surface,
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.beach_access, size: 56, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text(
            'NO MISSIONS TODAY',
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'REST, OR START A NEW QUEST',
            style: GameTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 8,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _showAddTaskSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: GameTheme.goldYellow.withValues(alpha: 0.1),
                border: Border.all(color: GameTheme.goldYellow, width: 2),
              ),
              child: Text(
                '[ + NEW QUEST ]',
                style: GameTheme.textTheme.bodySmall?.copyWith(
                  color: GameTheme.goldYellow,
                  fontSize: 10,
                  letterSpacing: 2,
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
          color: GameTheme.goldYellow,
          boxShadow: [
            BoxShadow(
              color: GameTheme.goldYellow.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              'NEW QUEST',
              style: GameTheme.textTheme.bodySmall?.copyWith(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
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
            backgroundColor: GameTheme.hpRed,
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
            backgroundColor: GameTheme.hpRed,
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
    if (task.isCompleted) return GameTheme.staminaGreen;
    if (task.isOverdue) return GameTheme.hpRed;
    final timeLeft = task.timeLeft;
    if (timeLeft == null) return Colors.grey;
    if (timeLeft.inHours < 6) return Colors.orange;
    if (timeLeft.inHours < 24) return GameTheme.goldYellow;
    return Colors.grey[600]!;
  }

  Color _getEnergyColor(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return GameTheme.staminaGreen;
      case EnergyLevel.medium:
        return GameTheme.goldYellow;
      case EnergyLevel.high:
        return GameTheme.hpRed;
    }
  }

  Color _getStatColor(StatType stat) {
    switch (stat) {
      case StatType.intelligence:
        return GameTheme.manaBlue;
      case StatType.discipline:
        return GameTheme.staminaGreen;
      case StatType.health:
        return GameTheme.hpRed;
      case StatType.wealth:
        return GameTheme.goldYellow;
    }
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return GameTheme.staminaGreen;
      case TaskDifficulty.medium:
        return GameTheme.goldYellow;
      case TaskDifficulty.hard:
        return GameTheme.hpRed;
    }
  }
}
