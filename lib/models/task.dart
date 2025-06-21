import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  
  late String title;
  
  String? details;
  
  @enumerated
  late TaskStatus status;
  
  late bool isDailyRecurring;
  
  late DateTime creationTimestamp;
  
  DateTime? completionTimestamp;
  
  int? checkInIntervalOverride;
  
  String? coachPersonaOverride;
}

enum TaskStatus {
  backlog,
  active,
  paused,
  completed,
  cancelled,
}