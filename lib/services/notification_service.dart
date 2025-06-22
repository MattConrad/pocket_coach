import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';
import '../models/coach_persona.dart';
import 'preferences_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static Function(String?)? _onNotificationTap;

  static Future<void> initialize({Function(String?)? onNotificationTap}) async {
    if (_isInitialized) return;

    _onNotificationTap = onNotificationTap;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
          defaultActionName: 'Open notification',
          // defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          linux: initializationSettingsLinux,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    _isInitialized = true;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (_onNotificationTap != null) {
      _onNotificationTap!(response.payload);
    }
  }

  static Future<bool> requestPermissions() async {
    if (!PreferencesService.notificationsEnabled) return false;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation
          .requestNotificationsPermission();
      return granted ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosImplementation != null) {
      final bool? granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  static Future<void> scheduleTaskCheckIn({
    required Task task,
    required int checkInMinutes,
    required CoachPersonaId coachPersona,
  }) async {
    if (!PreferencesService.notificationsEnabled) return;

    await initialize();

    final persona = CoachPersona.getPersona(coachPersona);
    final scheduledDate = DateTime.now().add(Duration(minutes: checkInMinutes));

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'task_checkins',
          'Task Check-ins',
          channelDescription: 'Notifications for task progress check-ins',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      task.id, // Use task ID as notification ID
      '${persona.name}: Checking in',
      'How is "${task.title}" going?',
      _convertToTimeZone(scheduledDate),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id.toString(),
    );
  }

  static Future<void> cancelTaskCheckIn(int taskId) async {
    await _notificationsPlugin.cancel(taskId);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!PreferencesService.notificationsEnabled) return;

    await initialize();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'immediate',
          'Immediate Notifications',
          channelDescription: 'Immediate notifications from Pocket Coach',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // Helper method to convert DateTime to timezone-aware datetime
  static _convertToTimeZone(DateTime dateTime) {
    // This would typically use the timezone package
    // For simplicity, we'll use the local timezone
    return dateTime;
  }

  // Method to reschedule notifications for active tasks on app startup
  static Future<void> rescheduleActiveTaskNotifications() async {
    // This would query the database for active tasks and reschedule their notifications
    // Implementation would depend on how the app tracks active tasks and their check-in times
    // For now, this is a placeholder
  }
}
