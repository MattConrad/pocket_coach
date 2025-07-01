import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = DatabaseService.instance;
  return await db.getAllTasks();
});

final taskListProvider = FutureProvider<List<Task>>((ref) async {
  final db = DatabaseService.instance;
  final backlogTasks = await db.getTasksByStatus(TaskStatus.backlog);
  final pausedTasks = await db.getTasksByStatus(TaskStatus.paused);
  final activeTasks = await db.getTasksByStatus(TaskStatus.active);
  return [...activeTasks, ...backlogTasks, ...pausedTasks];
});

final completedTasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = DatabaseService.instance;
  return await db.getTasksByStatus(TaskStatus.completed);
});

final cancelledTasksProvider = FutureProvider<List<Task>>((ref) async {
  final db = DatabaseService.instance;
  return await db.getTasksByStatus(TaskStatus.cancelled);
});

final activeTaskFromDbProvider = FutureProvider<Task?>((ref) async {
  final db = DatabaseService.instance;
  return await db.getActiveTask();
});

final taskStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = DatabaseService.instance;
  return await db.getTaskStatistics();
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  TaskNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  final Ref ref;

  Future<void> _loadTasks() async {
    try {
      final db = DatabaseService.instance;
      final tasks = await db.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTask(String title, {String? details, bool isDailyRecurring = false}) async {
    try {
      final db = DatabaseService.instance;
      final task = Task()
        ..title = title
        ..details = details
        ..status = TaskStatus.backlog
        ..isDailyRecurring = isDailyRecurring
        ..creationTimestamp = DateTime.now();

      await db.createTask(task);
      await _loadTasks();
      ref.invalidate(taskListProvider);
      ref.invalidate(tasksProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final db = DatabaseService.instance;
      await db.updateTask(task);
      await _loadTasks();
      ref.invalidate(tasksProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(completedTasksProvider);
      ref.invalidate(cancelledTasksProvider);
      ref.invalidate(activeTaskFromDbProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final db = DatabaseService.instance;
      await db.deleteTask(taskId);
      await _loadTasks();
      ref.invalidate(tasksProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(completedTasksProvider);
      ref.invalidate(cancelledTasksProvider);
      ref.invalidate(activeTaskFromDbProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> activateTask(Task task, {int? checkInInterval, String? coachOverride}) async {
    try {
      final db = DatabaseService.instance;

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
      ref.invalidate(tasksProvider);
      //      ref.invalidate(backlogTasksProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(activeTaskFromDbProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> completeTask(Task task) async {
    try {
      final db = DatabaseService.instance;
      task.status = TaskStatus.completed;
      task.completionTimestamp = DateTime.now();

      await db.updateTask(task);
      await _loadTasks();
      ref.invalidate(tasksProvider);
      //      ref.invalidate(backlogTasksProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(completedTasksProvider);
      ref.invalidate(activeTaskFromDbProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> cancelTask(Task task) async {
    try {
      final db = DatabaseService.instance;
      task.status = TaskStatus.cancelled;
      task.completionTimestamp = DateTime.now();

      await db.updateTask(task);
      await _loadTasks();
      ref.invalidate(tasksProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(cancelledTasksProvider);
      ref.invalidate(activeTaskFromDbProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> pauseTask(Task task) async {
    try {
      final db = DatabaseService.instance;
      task.status = TaskStatus.paused;

      await db.updateTask(task);
      await _loadTasks();
      ref.invalidate(tasksProvider);
      ref.invalidate(taskListProvider);
      ref.invalidate(activeTaskFromDbProvider);
      ref.invalidate(taskStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref);
});
