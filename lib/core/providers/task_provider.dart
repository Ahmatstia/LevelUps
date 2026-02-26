import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
// Hapus import SubtaskModel karena tidak digunakan di sini
import '../repositories/task_repository.dart';
import 'user_provider.dart';

// Repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// State notifier untuk tasks
class TaskNotifier extends StateNotifier<List<TaskModel>> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskNotifier(this._repository, this._ref) : super([]) {
    loadTasks();
  }

  // Load tasks dari Hive
  Future<void> loadTasks() async {
    final tasks = await _repository.getAllTasks();
    state = tasks;
  }

  // Tambah task dengan parameter lengkap
  Future<void> addTask({
    required String title,
    required String description,
    required TaskDifficulty difficulty,
    required StatType statType,
    DateTime? dueDate,
    RecurringType? recurringType,
    EnergyLevel? energyLevel,
    QuadrantType quadrant = QuadrantType.doFirst,
    List<String> tagIds = const [], // Hapus SubtaskModel
  }) async {
    final task = TaskModel.create(
      title: title,
      description: description,
      difficulty: difficulty,
      statType: statType,
      dueDate: dueDate,
      recurringType: recurringType,
      energyLevel: energyLevel,
      quadrant: quadrant,
      subtasks: const [], // Default empty list
      tagIds: tagIds,
    );

    await _repository.addTask(task);
    state = [...state, task];
  }

  // Selesaikan task
  Future<void> completeTask(String taskId) async {
    final taskIndex = state.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state[taskIndex];
    if (task.isCompleted) return;

    // Update task jadi completed
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      subtasks: task.subtasks
          .map((st) => st.copyWith(isCompleted: true))
          .toList(),
    );

    await _repository.updateTask(updatedTask);

    // Update state
    final newState = [...state];
    newState[taskIndex] = updatedTask;
    state = newState;

    // Dapatkan user provider
    final userNotifier = _ref.read(userProvider.notifier);

    // Tambah XP
    await userNotifier.addXp(task.difficulty.xpValue);

    // Tambah stat
    await userNotifier.addStat(task.statType, 1);

    // Update streak
    await userNotifier.updateStreak(DateTime.now());

    // Handle recurring task
    if (task.recurringType != null &&
        task.recurringType != RecurringType.none) {
      _createNextRecurringTask(task);
    }
  }

  // Buat task berikutnya untuk recurring
  void _createNextRecurringTask(TaskModel completedTask) {
    DateTime? nextDueDate;
    final baseDate = DateTime.now(); // Base on current date

    switch (completedTask.recurringType) {
      case RecurringType.daily:
        nextDueDate = baseDate.add(const Duration(days: 1));
        break;
      case RecurringType.weekly:
        nextDueDate = baseDate.add(const Duration(days: 7));
        break;
      case RecurringType.monthly:
        nextDueDate = DateTime(
          baseDate.year,
          baseDate.month + 1,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
        break;
      default:
        return;
    }

    // Preserve the original dueTime
    if (completedTask.dueDate != null) {
      nextDueDate = DateTime(
        nextDueDate.year,
        nextDueDate.month,
        nextDueDate.day,
        completedTask.dueDate!.hour,
        completedTask.dueDate!.minute,
      );
    }

    final newTask = TaskModel.create(
      title: completedTask.title,
      description: completedTask.description,
      difficulty: completedTask.difficulty,
      statType: completedTask.statType,
      dueDate: nextDueDate,
      recurringType: completedTask.recurringType,
      energyLevel: completedTask.energyLevel,
      quadrant: completedTask.quadrant,
      tagIds: completedTask.tagIds,
    );

    _repository.addTask(newTask);
    state = [...state, newTask];
  }

  // Hapus task
  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    state = state.where((task) => task.id != taskId).toList();
  }

  // Edit task
  Future<void> updateTask(TaskModel updatedTask) async {
    final taskIndex = state.indexWhere((t) => t.id == updatedTask.id);
    if (taskIndex == -1) return;

    await _repository.updateTask(updatedTask);

    final newState = [...state];
    newState[taskIndex] = updatedTask;
    state = newState;
  }

  // Dapatkan task berdasarkan filter
  List<TaskModel> getTasksByStatus(String status) {
    return state.where((task) => task.status == status).toList();
  }

  // Dapatkan task berdasarkan kuadran
  List<TaskModel> getTasksByQuadrant(QuadrantType quadrant) {
    return state
        .where((task) => !task.isCompleted && task.quadrant == quadrant)
        .toList();
  }

  // Dapatkan task berdasarkan tag
  List<TaskModel> getTasksByTag(String tagId) {
    return state
        .where((task) => !task.isCompleted && task.tagIds.contains(tagId))
        .toList();
  }

  // Dapatkan task hari ini (due today)
  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return state.where((task) {
      if (task.isCompleted) return false;
      if (task.dueDate == null) return false;
      if (task.isOverdue) return false;

      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
  }

  // Dapatkan task yang belum selesai
  List<TaskModel> get incompleteTasks {
    return state.where((task) => !task.isCompleted).toList();
  }

  // Dapatkan task yang sudah selesai
  List<TaskModel> get completedTasks {
    return state.where((task) => task.isCompleted).toList();
  }

  // Dapatkan task yang overdue
  List<TaskModel> get overdueTasks {
    return state.where((task) => !task.isCompleted && task.isOverdue).toList();
  }

  // Dapatkan task berdasarkan energy level
  List<TaskModel> getTasksByEnergy(EnergyLevel level) {
    return state
        .where((task) => !task.isCompleted && task.energyLevel == level)
        .toList();
  }
}

// Provider untuk tasks
final taskProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((
  ref,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository, ref);
});

// Provider untuk incomplete tasks
final incompleteTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => !task.isCompleted).toList();
});

// Provider untuk completed tasks
final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.isCompleted).toList();
});

// Provider untuk today's tasks
final todayTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  final now = DateTime.now();
  return tasks.where((task) {
    if (task.isCompleted) return false;
    if (task.dueDate == null) return false;
    if (task.isOverdue) return false;

    return task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;
  }).toList();
});

// Provider untuk overdue tasks
final overdueTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => !task.isCompleted && task.isOverdue).toList();
});

// Provider untuk tasks per kuadran
final doFirstTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks
      .where(
        (task) => !task.isCompleted && task.quadrant == QuadrantType.doFirst,
      )
      .toList();
});

final scheduleTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks
      .where(
        (task) => !task.isCompleted && task.quadrant == QuadrantType.schedule,
      )
      .toList();
});

final delegateTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks
      .where(
        (task) => !task.isCompleted && task.quadrant == QuadrantType.delegate,
      )
      .toList();
});

final eliminateTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks
      .where(
        (task) => !task.isCompleted && task.quadrant == QuadrantType.eliminate,
      )
      .toList();
});
