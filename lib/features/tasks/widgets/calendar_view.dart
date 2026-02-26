import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/task_provider.dart';
import '../../../core/models/task_model.dart';
import '../../../core/providers/locale_provider.dart';
import 'package:intl/intl.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(taskProvider);
    final l10n = ref.watch(l10nProvider);

    return Column(
      children: [
        // Calendar Header
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                      1,
                    );
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                      1,
                    );
                  });
                },
              ),
            ],
          ),
        ),

        // Day Headers
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                [
                      l10n.get('cal_mon'),
                      l10n.get('cal_tue'),
                      l10n.get('cal_wed'),
                      l10n.get('cal_thu'),
                      l10n.get('cal_fri'),
                      l10n.get('cal_sat'),
                      l10n.get('cal_sun'),
                    ]
                    .map(
                      (day) => Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar Grid
        Expanded(child: _buildCalendarGrid(allTasks)),

        // Selected Date Tasks
        if (_selectedDate != null) _buildSelectedDateTasks(allTasks, l10n),
      ],
    );
  }

  Widget _buildCalendarGrid(List<TaskModel> allTasks) {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 42, // 6 weeks
      itemBuilder: (context, index) {
        final day = index - startingWeekday + 2;
        final isCurrentMonth = day >= 1 && day <= daysInMonth;

        if (!isCurrentMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected =
            _selectedDate != null && _isSameDay(date, _selectedDate!);

        // Get tasks for this day
        final dayTasks = allTasks.where((task) {
          if (task.dueDate == null) return false;
          return _isSameDay(task.dueDate!, date);
        }).toList();

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.3)
                  : isToday
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isToday ? Colors.blue : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    color: isToday ? Colors.blue : Colors.white,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (dayTasks.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getTaskColor(dayTasks),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (dayTasks.length > 1)
                          Text(
                            ' +${dayTasks.length - 1}',
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDateTasks(List<TaskModel> allTasks, dynamic l10n) {
    if (_selectedDate == null) return const SizedBox.shrink();

    final tasksForDay = allTasks.where((task) {
      if (task.dueDate == null) return false;
      return _isSameDay(task.dueDate!, _selectedDate!);
    }).toList();

    return Container(
      height: 200,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: tasksForDay.isEmpty
                ? Center(
                    child: Text(
                      l10n.get('dash_empty_tasks').split('\n')[0],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasksForDay.length,
                    itemBuilder: (context, index) {
                      final task = tasksForDay[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getTaskColorForTask(task),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (task.isCompleted)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getTaskColor(List<TaskModel> tasks) {
    if (tasks.any((t) => t.isOverdue && !t.isCompleted)) {
      return Colors.red;
    }
    if (tasks.any((t) => !t.isCompleted)) {
      return Colors.blue;
    }
    return Colors.green;
  }

  Color _getTaskColorForTask(TaskModel task) {
    if (task.isCompleted) return Colors.green;
    if (task.isOverdue) return Colors.red;
    return Colors.blue;
  }
}
