import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Service for managing local notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) return;

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Here we could navigate to the practice screen
    // This would require access to navigation context
  }

  /// Request permissions (mainly for iOS)
  Future<bool> requestPermissions() async {
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android doesn't need explicit permission
  }

  /// Schedule daily practice reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = "Time to practice math facts!",
    String body = "Keep your streak going with a quick practice session.",
  }) async {
    // For now, just show an immediate notification for testing
    await showImmediateNotification(
      title: title,
      body: body,
      payload: 'daily_practice_reminder',
    );
  }

  /// Schedule spaced repetition reminder
  Future<void> scheduleSpacedRepetitionReminder({
    required DateTime scheduledDate,
    String title = "Review time!",
    String body = "Some math facts are ready for review.",
  }) async {
    // For now, just show an immediate notification for testing
    await showImmediateNotification(
      title: title,
      body: body,
      payload: 'spaced_repetition_reminder',
    );
  }

  /// Schedule streak maintenance reminder
  Future<void> scheduleStreakReminder() async {
    // For now, just show an immediate notification for testing
    await showImmediateNotification(
      title: "Don't break your streak! 🔥",
      body: "You haven't practiced today. Keep your ${_getCurrentStreak()}-day streak alive!",
      payload: 'streak_reminder',
    );
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate',
          'Immediate Notifications',
          channelDescription: 'Immediate notifications for testing',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }



  /// Helper method to get current streak (this would normally come from storage service)
  int _getCurrentStreak() {
    // This is a placeholder - in the real app this would come from StorageService
    return 3;
  }

  /// Schedule motivational notifications
  Future<void> scheduleMotivationalNotifications() async {
    // For now, just show an immediate notification for testing
    await showImmediateNotification(
      title: 'Great job! 🌟',
      body: 'You\'re building strong math skills one fact at a time!',
      payload: 'motivational_message',
    );
  }
}