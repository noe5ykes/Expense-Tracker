import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications: budget alerts, daily reminders, bill reminders and
/// monthly summaries. All calls are best-effort — a failed notification must
/// never break a user flow, so errors are swallowed and logged in debug.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const int _dailyReminderId = 1;
  static const int _monthlySummaryId = 2;
  static const int _billReminderBase = 1000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  NotificationDetails _details(String channelId, String channelName) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  /// Immediate alert when a budget threshold is crossed.
  Future<void> showBudgetAlert(
      {required String title, required String body}) async {
    if (!_initialized) return;
    try {
      await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title,
          body, _details('budget_alerts', 'Budget alerts'));
    } catch (e) {
      debugPrint('Budget alert failed: $e');
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_dailyReminderId);
      await _plugin.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        _nextInstanceOf(hour, minute),
        _details('daily_reminder', 'Daily reminder'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Daily reminder scheduling failed: $e');
    }
  }

  Future<void> cancelDailyReminder() => _cancel(_dailyReminderId);

  /// Reminder one day before the bill is due (9:00).
  Future<void> scheduleBillReminder({
    required String billId,
    required DateTime dueDate,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      final fireAt = DateTime(dueDate.year, dueDate.month, dueDate.day - 1, 9);
      if (fireAt.isBefore(DateTime.now())) return;
      await _plugin.zonedSchedule(
        _billReminderBase + billId.hashCode.abs() % 100000,
        title,
        body,
        tz.TZDateTime.from(fireAt, tz.local),
        _details('bill_reminders', 'Bill reminders'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Bill reminder scheduling failed: $e');
    }
  }

  Future<void> cancelBillReminder(String billId) =>
      _cancel(_billReminderBase + billId.hashCode.abs() % 100000);

  /// Fires on the 1st of every month at 10:00.
  Future<void> scheduleMonthlySummary(
      {required String title, required String body}) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(_monthlySummaryId);
      final now = tz.TZDateTime.now(tz.local);
      var next = tz.TZDateTime(tz.local, now.year, now.month, 1, 10);
      if (!next.isAfter(now)) {
        next = tz.TZDateTime(tz.local, now.year, now.month + 1, 1, 10);
      }
      await _plugin.zonedSchedule(
        _monthlySummaryId,
        title,
        body,
        next,
        _details('monthly_summary', 'Monthly summary'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } catch (e) {
      debugPrint('Monthly summary scheduling failed: $e');
    }
  }

  Future<void> cancelMonthlySummary() => _cancel(_monthlySummaryId);

  Future<void> _cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Notification cancel failed: $e');
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
