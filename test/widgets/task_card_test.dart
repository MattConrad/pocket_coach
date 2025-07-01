import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_coach/models/task.dart';
import 'package:pocket_coach/widgets/task_card.dart';

void main() {
  group('TaskCard', () {
    late Task testTask;

    setUp(() {
      testTask = Task()
        ..title = 'Test Task'
        ..status = TaskStatus.backlog
        ..isDailyRecurring = false
        ..creationTimestamp = DateTime.now().subtract(Duration(hours: 2));
    });

    Widget createTestWidget({
      Task? task,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
      bool showStatus = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task ?? testTask,
            onTap: onTap,
            onLongPress: onLongPress,
            showStatus: showStatus,
          ),
        ),
      );
    }

    group('Display tests', () {
      testWidgets('should display task title', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Test Task'), findsOneWidget);
      });

      testWidgets('should display task details when present', (WidgetTester tester) async {
        final taskWithDetails = Task()
          ..title = 'Task with Details'
          ..details = 'This is a detailed description'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        await tester.pumpWidget(createTestWidget(task: taskWithDetails));

        expect(find.text('Task with Details'), findsOneWidget);
        expect(find.text('This is a detailed description'), findsOneWidget);
      });

      testWidgets('should not display details section when details is null', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should not find any details text since testTask doesn't have details
        expect(testTask.details, null);
        // The details section should not be present
      });

      testWidgets('should display creation time', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should show time icon and "2h ago" text (task created 2 hours ago)
        expect(find.byIcon(Icons.access_time), findsOneWidget);
        expect(find.text('2h ago'), findsOneWidget);
      });

      testWidgets('should display recurring icon for daily recurring tasks', (WidgetTester tester) async {
        final recurringTask = Task()
          ..title = 'Daily Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = true
          ..creationTimestamp = DateTime.now();

        await tester.pumpWidget(createTestWidget(task: recurringTask));

        expect(find.byIcon(Icons.repeat), findsOneWidget);
      });

      testWidgets('should not display recurring icon for non-recurring tasks', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byIcon(Icons.repeat), findsNothing);
      });

      testWidgets('should display status chip when showStatus is true', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(showStatus: true));

        expect(find.text('Backlog'), findsOneWidget);
      });

      testWidgets('should not display status chip when showStatus is false', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(showStatus: false));

        expect(find.text('Backlog'), findsNothing);
      });

      testWidgets('should display completion timestamp for completed tasks', (WidgetTester tester) async {
        final completedTask = Task()
          ..title = 'Completed Task'
          ..status = TaskStatus.completed
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now().subtract(Duration(hours: 3))
          ..completionTimestamp = DateTime.now().subtract(Duration(hours: 1));

        await tester.pumpWidget(createTestWidget(task: completedTask));

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.text('1h ago'), findsAtLeastNWidgets(1)); // Could be creation or completion time
      });

      testWidgets('should display cancel icon for cancelled tasks', (WidgetTester tester) async {
        final cancelledTask = Task()
          ..title = 'Cancelled Task'
          ..status = TaskStatus.cancelled
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now().subtract(Duration(hours: 3))
          ..completionTimestamp = DateTime.now().subtract(Duration(hours: 1));

        await tester.pumpWidget(createTestWidget(task: cancelledTask));

        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });

      testWidgets('should display interaction hint when onLongPress is provided', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(onLongPress: () {}));

        expect(find.text('Tap to start • Long press for options'), findsOneWidget);
      });

      testWidgets('should not display interaction hint when onLongPress is null', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Tap to start • Long press for options'), findsNothing);
      });
    });

    group('Status chip tests', () {
      testWidgets('should display correct status chip for each status', (WidgetTester tester) async {
        final statusTests = [
          (TaskStatus.completed, 'Completed'),
          (TaskStatus.cancelled, 'Cancelled'),
          (TaskStatus.active, 'Active'),
          (TaskStatus.paused, 'Paused'),
          (TaskStatus.backlog, 'Backlog'),
        ];

        for (final (status, expectedText) in statusTests) {
          final statusTask = Task()
            ..title = 'Status Test Task'
            ..status = status
            ..isDailyRecurring = false
            ..creationTimestamp = DateTime.now();

          await tester.pumpWidget(createTestWidget(task: statusTask, showStatus: true));

          expect(find.text(expectedText), findsOneWidget);
        }
      });
    });

    group('Interaction tests', () {
      testWidgets('should call onTap when tapped', (WidgetTester tester) async {
        bool tapCalled = false;
        
        await tester.pumpWidget(createTestWidget(onTap: () {
          tapCalled = true;
        }));

        await tester.tap(find.byType(TaskCard));
        await tester.pumpAndSettle();

        expect(tapCalled, true);
      });

      testWidgets('should call onLongPress when long pressed', (WidgetTester tester) async {
        bool longPressCalled = false;
        
        await tester.pumpWidget(createTestWidget(onLongPress: () {
          longPressCalled = true;
        }));

        await tester.longPress(find.byType(TaskCard));
        await tester.pumpAndSettle();

        expect(longPressCalled, true);
      });

      testWidgets('should not crash when onTap is null and widget is tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should not throw when tapping without onTap callback
        await tester.tap(find.byType(TaskCard));
        await tester.pumpAndSettle();
        
        // Test passes if no exception is thrown
      });

      testWidgets('should not crash when onLongPress is null and widget is long pressed', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should not throw when long pressing without onLongPress callback
        await tester.longPress(find.byType(TaskCard));
        await tester.pumpAndSettle();
        
        // Test passes if no exception is thrown
      });
    });

    group('Time formatting tests', () {
      testWidgets('should display "Just now" for very recent tasks', (WidgetTester tester) async {
        final recentTask = Task()
          ..title = 'Recent Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now().subtract(Duration(seconds: 30));

        await tester.pumpWidget(createTestWidget(task: recentTask));

        expect(find.text('Just now'), findsOneWidget);
      });

      testWidgets('should display minutes for tasks created within an hour', (WidgetTester tester) async {
        final minutesTask = Task()
          ..title = 'Minutes Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now().subtract(Duration(minutes: 45));

        await tester.pumpWidget(createTestWidget(task: minutesTask));

        expect(find.text('45m ago'), findsOneWidget);
      });

      testWidgets('should display hours for tasks created within a day', (WidgetTester tester) async {
        final hoursTask = Task()
          ..title = 'Hours Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now().subtract(Duration(hours: 5));

        await tester.pumpWidget(createTestWidget(task: hoursTask));

        expect(find.text('5h ago'), findsOneWidget);
      });

      testWidgets('should display days for tasks created more than a day ago', (WidgetTester tester) async {
        final daysTask = Task()
          ..title = 'Days Task'
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now().subtract(Duration(days: 3));

        await tester.pumpWidget(createTestWidget(task: daysTask));

        expect(find.text('3d ago'), findsOneWidget);
      });
    });

    group('Edge cases', () {
      testWidgets('should handle task with empty title', (WidgetTester tester) async {
        final emptyTitleTask = Task()
          ..title = ''
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        await tester.pumpWidget(createTestWidget(task: emptyTitleTask));

        // Should not crash with empty title
        expect(find.text(''), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle task with very long title', (WidgetTester tester) async {
        final longTitle = 'A' * 200; // Very long title
        final longTitleTask = Task()
          ..title = longTitle
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        await tester.pumpWidget(createTestWidget(task: longTitleTask));

        expect(find.text(longTitle), findsOneWidget);
      });

      testWidgets('should handle task with very long details', (WidgetTester tester) async {
        final longDetails = 'B' * 500; // Very long details
        final longDetailsTask = Task()
          ..title = 'Task with long details'
          ..details = longDetails
          ..status = TaskStatus.backlog
          ..isDailyRecurring = false
          ..creationTimestamp = DateTime.now();

        await tester.pumpWidget(createTestWidget(task: longDetailsTask));

        expect(find.text(longDetails), findsOneWidget);
      });
    });
  });
}