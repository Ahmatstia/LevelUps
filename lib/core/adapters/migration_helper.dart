import 'package:hive/hive.dart';
import '../models/task_model.dart';

class MigrationHelper {
  // Migrasi task lama ke format baru
  static Future<void> migrateOldTasks() async {
    final box = await Hive.openBox<TaskModel>('tasks');
    final tasks = box.values.toList();

    for (var task in tasks) {
      // Cek apakah task perlu dimigrasi (tidak memiliki quadrant atau subtasks)
      // Dengan Hive resilience, we just need to ensure values are saved back
      // if they were missing (which copyWith will handle)

      final updatedTask = task.copyWith(
        quadrant: task.quadrant, // Will use default if missing
        subtasks: task.subtasks, // Will use default if missing
        tagIds: task.tagIds, // Will use default if missing
      );

      await box.put(task.id, updatedTask);
    }
  }
}
