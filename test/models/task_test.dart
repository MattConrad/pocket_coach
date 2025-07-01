import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_coach/models/task.dart';

void main() {
  group('Task', () {
    group('TaskStatus enum', () {
      test('should have all expected status values', () {
        final expectedStatuses = {
          TaskStatus.backlog,
          TaskStatus.active,
          TaskStatus.paused,
          TaskStatus.completed,
          TaskStatus.cancelled,
        };
        
        expect(TaskStatus.values.toSet(), expectedStatuses);
        expect(TaskStatus.values.length, 5);
      });

      test('should have correct enum order for business logic', () {
        // This test ensures the enum order makes sense for status transitions
        expect(TaskStatus.values.indexOf(TaskStatus.backlog), 0);
        expect(TaskStatus.values.indexOf(TaskStatus.active), 1);
        expect(TaskStatus.values.indexOf(TaskStatus.paused), 2);
        expect(TaskStatus.values.indexOf(TaskStatus.completed), 3);
        expect(TaskStatus.values.indexOf(TaskStatus.cancelled), 4);
      });
    });

    group('Task creation and properties', () {
      test('should create task with required properties', () {
        final now = DateTime.now();
        final task = Task()
          ..title = 'Test Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = now;

        expect(task.title, 'Test Task');
        expect(task.status, TaskStatus.backlog);
        expect(task.isDailyRecurring, false);
        expect(task.creationTimestamp, now);
        // Note: Isar.autoIncrement starts with a large negative value until saved to DB
        expect(task.id, isA<int>());
      });

      test('should create task with optional properties', () {
        final now = DateTime.now();
        final completionTime = now.add(Duration(hours: 1));
        
        final task = Task()
          ..title = 'Test Task with Details'
          ..details = 'This is a detailed description'
          ..status = TaskStatus.completed
          ..isDailyRecurring = true
          ..creationTimestamp = now
          ..completionTimestamp = completionTime
          ..checkInIntervalOverride = 30
          ..coachPersonaOverride = 'willow';

        expect(task.title, 'Test Task with Details');
        expect(task.details, 'This is a detailed description');
        expect(task.status, TaskStatus.completed);
        expect(task.isDailyRecurring, true);
        expect(task.creationTimestamp, now);
        expect(task.completionTimestamp, completionTime);
        expect(task.checkInIntervalOverride, 30);
        expect(task.coachPersonaOverride, 'willow');
      });

      test('should allow null optional properties', () {
        final now = DateTime.now();
        final task = Task()
          ..title = 'Minimal Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = now;

        expect(task.details, null);
        expect(task.completionTimestamp, null);
        expect(task.checkInIntervalOverride, null);
        expect(task.coachPersonaOverride, null);
      });
    });

    group('Task status transitions (business logic validation)', () {
      late Task task;
      late DateTime now;

      setUp(() {
        now = DateTime.now();
        task = Task()
          ..title = 'Status Test Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = now;
      });

      test('should allow transition from backlog to active', () {
        expect(task.status, TaskStatus.backlog);
        
        task.status = TaskStatus.active;
        expect(task.status, TaskStatus.active);
      });

      test('should allow transition from active to paused', () {
        task.status = TaskStatus.active;
        
        task.status = TaskStatus.paused;
        expect(task.status, TaskStatus.paused);
      });

      test('should allow transition from active to completed', () {
        task.status = TaskStatus.active;
        
        task.status = TaskStatus.completed;
        task.completionTimestamp = now.add(Duration(hours: 1));
        
        expect(task.status, TaskStatus.completed);
        expect(task.completionTimestamp, isNotNull);
      });

      test('should allow transition from active to cancelled', () {
        task.status = TaskStatus.active;
        
        task.status = TaskStatus.cancelled;
        task.completionTimestamp = now.add(Duration(hours: 1));
        
        expect(task.status, TaskStatus.cancelled);
        expect(task.completionTimestamp, isNotNull);
      });

      test('should allow transition from paused back to active', () {
        task.status = TaskStatus.active;
        task.status = TaskStatus.paused;
        
        task.status = TaskStatus.active;
        expect(task.status, TaskStatus.active);
      });
    });

    group('Task property validation', () {
      test('should handle empty title', () {
        // NOTE: Current implementation doesn't validate title length
        // If validation is added to the Task model later, this test should be updated
        final task = Task()
          ..title = ''
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        expect(task.title, '');
      });

      test('should handle long title', () {
        final longTitle = 'A' * 1000; // Very long title
        final task = Task()
          ..title = longTitle
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        expect(task.title, longTitle);
      });

      test('should handle checkInIntervalOverride edge values', () {
        final task = Task()
          ..title = 'Interval Test'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        // Test zero
        task.checkInIntervalOverride = 0;
        expect(task.checkInIntervalOverride, 0);

        // Test negative (though this might not make business sense)
        task.checkInIntervalOverride = -1;
        expect(task.checkInIntervalOverride, -1);

        // Test large value
        task.checkInIntervalOverride = 999999;
        expect(task.checkInIntervalOverride, 999999);
      });

      test('should handle various coach persona override values', () {
        final task = Task()
          ..title = 'Coach Test'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        // Test valid coach names
        final validCoaches = ['sterling', 'willow', 'john', 'callum'];
        for (final coach in validCoaches) {
          task.coachPersonaOverride = coach;
          expect(task.coachPersonaOverride, coach);
        }

        // Test invalid coach name (implementation should handle gracefully)
        task.coachPersonaOverride = 'invalid_coach';
        expect(task.coachPersonaOverride, 'invalid_coach');

        // Test empty string
        task.coachPersonaOverride = '';
        expect(task.coachPersonaOverride, '');
      });
    });

    group('Task timestamps', () {
      test('should handle creation and completion timestamps', () {
        final creationTime = DateTime.now();
        final completionTime = creationTime.add(Duration(hours: 2));
        
        final task = Task()
          ..title = 'Timestamp Test'
          ..status = TaskStatus.completed
          ..isDailyRecurring = false
          ..creationTimestamp = creationTime
          ..completionTimestamp = completionTime;

        expect(task.creationTimestamp, creationTime);
        expect(task.completionTimestamp, completionTime);
        expect(task.completionTimestamp!.isAfter(task.creationTimestamp), true);
      });

      test('should handle same creation and completion timestamps', () {
        final timestamp = DateTime.now();
        
        final task = Task()
          ..title = 'Same Timestamp Test'
          ..status = TaskStatus.completed
          ..isDailyRecurring = false
          ..creationTimestamp = timestamp
          ..completionTimestamp = timestamp;

        expect(task.creationTimestamp, task.completionTimestamp);
      });

      test('should handle completion timestamp before creation timestamp', () {
        // This is a data integrity issue that should be caught by business logic
        // but the model itself should allow it for testing edge cases
        final creationTime = DateTime.now();
        final completionTime = creationTime.subtract(Duration(hours: 1));
        
        final task = Task()
          ..title = 'Invalid Timestamp Test'
          ..status = TaskStatus.completed
          ..isDailyRecurring = false
          ..creationTimestamp = creationTime
          ..completionTimestamp = completionTime;

        expect(task.completionTimestamp!.isBefore(task.creationTimestamp), true);
        
        // TODO: Add business logic validation to prevent this scenario
        // When validation is added, this test should expect an exception
      });
    });

    group('Daily recurring tasks', () {
      test('should create daily recurring task', () {
        final task = Task()
          ..title = 'Daily Exercise'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = true
          ..creationTimestamp = DateTime.now();

        expect(task.isDailyRecurring, true);
      });

      test('should create non-recurring task', () {
        final task = Task()
          ..title = 'One-time Project'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        expect(task.isDailyRecurring, false);
      });
    });
  });
}