import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules a re-assessment reminder after each assessment.
///
/// - Mobile: fires a real local notification on the due date.
/// - Web: notifications aren't supported, so we only store the due date and
///   the home screen shows a reminder card.
class ReminderService {
  static const String _dateKey = 'next_reassessment_date';
  static const int _notifId = 7001;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  /// Call once at app startup.
  static Future<void> init() async {
    if (kIsWeb || _inited) return;
    try {
      tzdata.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      // Android 13+ runtime permission.
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _inited = true;
    } catch (e) {
      debugPrint('[Reminder] init failed: $e');
    }
  }

  /// Schedule a reminder [days] from now (default 30). Stores the date so the
  /// UI can show it, and on mobile schedules the local notification.
  static Future<void> scheduleReassessment({int days = 30}) async {
    final due = DateTime.now().add(Duration(days: days));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dateKey, due.toIso8601String());
    } catch (e) {
      debugPrint('[Reminder] save date failed: $e');
    }

    if (kIsWeb) return;
    try {
      await init();
      final tzDue = tz.TZDateTime.from(due, tz.local);
      await _plugin.zonedSchedule(
        _notifId,
        'Waqtigii dib-u-qiimeynta',
        'Dib u qiimee khatartaada anemia si aad ula socoto caafimaadkaaga.',
        tzDue,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reassessment_channel',
            'Re-assessment reminders',
            channelDescription:
                'Reminds you to re-check your anemia risk periodically.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[Reminder] schedule failed: $e');
    }
  }

  /// The stored next-reassessment date, or null if none.
  static Future<DateTime?> nextReassessment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_dateKey);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }

  /// Days remaining until the next reassessment (negative if overdue).
  static Future<int?> daysUntilNext() async {
    final due = await nextReassessment();
    if (due == null) return null;
    return due.difference(DateTime.now()).inDays;
  }

  static Future<void> cancel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dateKey);
      if (!kIsWeb) await _plugin.cancel(_notifId);
    } catch (e) {
      debugPrint('[Reminder] cancel failed: $e');
    }
  }
}
