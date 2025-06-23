import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getAllTasks();
});

final backlogTasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTasksByStatus(TaskStatus.backlog);
});

final completedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTasksByStatus(TaskStatus.completed);
});

final cancelledTasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTasksByStatus(TaskStatus.cancelled);
});

final activeTaskFromDbProvider = FutureProvider<Task?>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getActiveTask();
});

final taskStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getTaskStatistics();
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TaskNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  final Ref ref;

  Future<void> _loadTasks() async {
    try {
      final db = ref.read(databaseServiceProvider);
      final tasks = await db.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTask(String title, {String? details, bool isDailyRecurring = false}) async {
    try {
      final db = ref.read(databaseServiceProvider);
      final task = Task()
        ..title = title
        ..details = details
        ..status = TaskStatus.backlog
        ..isDailyRecurring = isDailyRecurring
        ..creationTimestamp = DateTime.now();

      await db.createTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final db = ref.read(databaseServiceProvider);
      await db.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final db = ref.read(databaseServiceProvider);
      await db.deleteTask(taskId);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> activateTask(Task task, {int? checkInInterval, String? coachOverride}) async {
    try {
      final db = ref.read(databaseServiceProvider);

      // First, make sure no other tasks are active
      final activeTasks = await db.getTasksByStatus(TaskStatus.active);
      for (final activeTask in activeTasks) {
        activeTask.status = TaskStatus.paused;
        await db.updateTask(activeTask);
      }

      // Now activate the new task
      task.status = TaskStatus.active;
      task.checkInIntervalOverride = checkInInterval;
      task.coachPersonaOverride = coachOverride;

      await db.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> completeTask(Task task) async {
    try {
      final db = ref.read(databaseServiceProvider);
      task.status = TaskStatus.completed;
      task.completionTimestamp = DateTime.now();

      await db.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> cancelTask(Task task) async {
    try {
      final db = ref.read(databaseServiceProvider);
      task.status = TaskStatus.cancelled;
      task.completionTimestamp = DateTime.now();

      await db.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> pauseTask(Task task) async {
    try {
      final db = ref.read(databaseServiceProvider);
      task.status = TaskStatus.paused;

      await db.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref);
});
