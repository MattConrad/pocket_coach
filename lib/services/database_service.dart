import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';
import '../models/chat_message.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  DatabaseService._internal();

  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = await Isar.open(
      [TaskSchema, ChatMessageSchema],
      directory: dir.path,
    );
  }

  Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call DatabaseService.initialize() first.');
    }
    return _isar!;
  }

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  // Task operations
  Future<int> createTask(Task task) async {
    return await isar.writeTxn(() async {
      return await isar.tasks.put(task);
    });
  }

  Future<List<Task>> getAllTasks() async {
    return await isar.tasks.where().findAll();
  }

  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    return await isar.tasks.filter().statusEqualTo(status).findAll();
  }

  Future<Task?> getActiveTask() async {
    return await isar.tasks.filter().statusEqualTo(TaskStatus.active).findFirst();
  }

  Future<void> updateTask(Task task) async {
    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });
  }

  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.tasks.delete(id);
    });
  }

  // Chat message operations  
  Future<int> createChatMessage(ChatMessage message) async {
    return await isar.writeTxn(() async {
      return await isar.chatMessages.put(message);
    });
  }

  Future<List<ChatMessage>> getChatMessages({int? taskId, int limit = 50}) async {
    if (taskId != null) {
      return await isar.chatMessages
          .filter()
          .taskIdEqualTo(taskId)
          .sortByTimestamp()
          .limit(limit)
          .findAll();
    } else {
      return await isar.chatMessages
          .where()
          .sortByTimestamp()
          .limit(limit)
          .findAll();
    }
  }

  Future<List<ChatMessage>> getRecentChatMessages({int? taskId, int limit = 5}) async {
    if (taskId != null) {
      return await isar.chatMessages
          .filter()
          .taskIdEqualTo(taskId)
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();
    } else {
      return await isar.chatMessages
          .where()
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();
    }
  }

  Future<void> deleteChatMessage(int id) async {
    await isar.writeTxn(() async {
      await isar.chatMessages.delete(id);
    });
  }

  // Statistics
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final completedTasks = await getTasksByStatus(TaskStatus.completed);
    final cancelledTasks = await getTasksByStatus(TaskStatus.cancelled);
    final totalTasks = completedTasks.length + cancelledTasks.length;
    
    final successRate = totalTasks > 0 ? (completedTasks.length / totalTasks) : 0.0;
    
    // Calculate success streak
    final allTasks = await isar.tasks
        .filter()
        .statusEqualTo(TaskStatus.completed)
        .or()
        .statusEqualTo(TaskStatus.cancelled)
        .sortByCompletionTimestampDesc()
        .findAll();
    
    int currentStreak = 0;
    for (final task in allTasks) {
      if (task.status == TaskStatus.completed) {
        currentStreak++;
      } else {
        break;
      }
    }
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks.length,
      'cancelledTasks': cancelledTasks.length,
      'successRate': successRate,
      'currentStreak': currentStreak,
    };
  }
}