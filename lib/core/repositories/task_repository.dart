import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskRepository {
  static const String _boxName = 'tasks';

  // Mendapatkan box
  Future<Box<TaskModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<TaskModel>(_boxName);
    }
    return await Hive.openBox<TaskModel>(_boxName);
  }

  // Tambah task
  Future<void> addTask(TaskModel task) async {
    final box = await _getBox();
    await box.put(task.id, task);
  }

  // Ambil semua task
  Future<List<TaskModel>> getAllTasks() async {
    final box = await _getBox();
    return box.values.toList();
  }

  // Ambil task yang belum selesai
  Future<List<TaskModel>> getIncompleteTasks() async {
    final box = await _getBox();
    return box.values.where((task) => !task.isCompleted).toList();
  }

  // Ambil task yang sudah selesai
  Future<List<TaskModel>> getCompletedTasks() async {
    final box = await _getBox();
    return box.values.where((task) => task.isCompleted).toList();
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    final box = await _getBox();
    await box.put(task.id, task);
  }

  // Hapus task
  Future<void> deleteTask(String taskId) async {
    final box = await _getBox();
    await box.delete(taskId);
  }

  // Hapus semua task
  Future<void> deleteAllTasks() async {
    final box = await _getBox();
    await box.clear();
  }
}
