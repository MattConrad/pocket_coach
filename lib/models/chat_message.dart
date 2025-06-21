import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@collection
class ChatMessage {
  Id id = Isar.autoIncrement;

  @Index()
  int? taskId;

  @enumerated
  late MessageSender sender;

  late String text;

  late DateTime timestamp;

  late String coachPersonaId;

  @enumerated
  late CoachExpression coachExpression;
}

enum MessageSender { user, coach }

enum CoachExpression { defaultExpression, happy, disappointed, surprised }
