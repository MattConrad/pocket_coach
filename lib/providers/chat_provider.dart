import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/coach_persona.dart';
import '../services/database_service.dart';

final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, int?>((
  ref,
  taskId,
) async {
  final db = DatabaseService.instance;
  return await db.getChatMessages(taskId: taskId);
});

final recentChatMessagesProvider =
    FutureProvider.family<List<ChatMessage>, int?>((ref, taskId) async {
      final db = DatabaseService.instance;
      return await db.getRecentChatMessages(taskId: taskId);
    });

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> loadMessages({int? taskId}) async {
    try {
      final db = DatabaseService.instance;
      final messages = await db.getChatMessages(taskId: taskId);
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addUserMessage(
    String text, {
    int? taskId,
    required String coachPersonaId,
  }) async {
    try {
      final db = DatabaseService.instance;
      final message = ChatMessage()
        ..taskId = taskId
        ..sender = MessageSender.user
        ..text = text
        ..timestamp = DateTime.now()
        ..coachPersonaId = coachPersonaId;

      await db.createChatMessage(message);

      // Reload messages to update UI
      await loadMessages(taskId: taskId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCoachMessage(
    String text, {
    int? taskId,
    required String coachPersonaId,
    required CoachExpression expression,
  }) async {
    try {
      final db = DatabaseService.instance;
      final message = ChatMessage()
        ..taskId = taskId
        ..sender = MessageSender.coach
        ..text = text
        ..timestamp = DateTime.now()
        ..coachPersonaId = coachPersonaId
        ..coachExpression = expression;

      await db.createChatMessage(message);

      // Reload messages to update UI
      await loadMessages(taskId: taskId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearMessages({int? taskId}) async {
    try {
      final db = DatabaseService.instance;
      final messages = await db.getChatMessages(taskId: taskId);

      for (final message in messages) {
        await db.deleteChatMessage(message.id);
      }

      await loadMessages(taskId: taskId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatMessage>>>((ref) {
      return ChatNotifier(ref);
    });

class CurrentExpressionNotifier extends StateNotifier<CoachExpression> {
  CurrentExpressionNotifier() : super(CoachExpression.defaultExpression);

  void setExpression(CoachExpression expression) => state = expression;
}

final currentExpressionProvider =
    StateNotifierProvider<CurrentExpressionNotifier, CoachExpression>((ref) {
      return CurrentExpressionNotifier();
    });
