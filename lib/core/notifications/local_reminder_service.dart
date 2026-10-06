import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../data/reminders/reminder_model.dart';

/// Local offline reminder service for Quran recitation and tadbeer alarms.
///
/// EDUCATIONAL NOTE:
/// This service is 100% offline. Notifications are scheduled directly with the
/// host OS (Android AlarmManager / Linux D-Bus notifications / iOS APNS local).
///
/// Notification ID strategy:
/// To manage multiple reminders and repeating weekday occurrences reliably, each
/// reminder receives a base notification ID derived from `id.hashCode.abs() % 100000`.
/// For weekday repeats, each day (1..7) is assigned an offset: `baseId + dayOfWeek`.
class LocalReminderService {
  static final LocalReminderService instance = LocalReminderService._internal();
  LocalReminderService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void Function(String? payload)? onNotificationTapped;

  /// Initializes timezone data and native platform notification channels.
  Future<void> init({void Function(String? payload)? onTapped}) async {
    if (_isInitialized) return;
    onNotificationTapped = onTapped;

    try {
      tz.initializeTimeZones();
      final localName = tz.local.name;
      debugPrint('Local timezone initialized: $localName');
    } catch (e) {
      debugPrint('Failed to initialize timezones: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Tadbeer',
      defaultIcon: AssetsLinuxIcon('assets/icons/app_icon.png'),
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          onNotificationTapped?.call(response.payload);
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification plugin initialize error: $e');
    }
  }

  /// Explicitly requests notification permissions on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return true;
  }

  int _baseNotificationId(String reminderId) {
    return reminderId.hashCode.abs() % 100000;
  }

  /// Cancels all scheduled OS notification slots for a given reminder.
  Future<void> cancelReminder(ReminderItem reminder) async {
    final baseId = _baseNotificationId(reminder.id);
    for (int i = 0; i <= 7; i++) {
      try {
        await _notificationsPlugin.cancel(id: baseId + i);
      } catch (_) {}
    }
  }

  /// Schedules a reminder based on its repeat mode (once, daily, or specific weekdays).
  Future<void> scheduleReminder(ReminderItem reminder) async {
    if (!reminder.isEnabled) {
      await cancelReminder(reminder);
      return;
    }

    await cancelReminder(reminder);

    const androidDetails = AndroidNotificationDetails(
      'tadbeer_reminders',
      'تنبيهات ورد القرآن',
      channelDescription: 'تذكير محلي بقراءة وتدبّر القرآن الكريم',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title = reminder.title.trim().isNotEmpty
        ? reminder.title.trim()
        : 'ورد القرآن الكريم';
    const body = 'حان وقت تلاوة وتدبّر القرآن الكريم';
    const payload = 'quran_resume';

    final baseId = _baseNotificationId(reminder.id);

    try {
      final now = tz.TZDateTime.now(tz.local);

      if (reminder.repeatMode == ReminderRepeatMode.once) {
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          reminder.hour,
          reminder.minute,
        );
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await _notificationsPlugin.zonedSchedule(
          id: baseId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } else if (reminder.repeatMode == ReminderRepeatMode.daily) {
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          reminder.hour,
          reminder.minute,
        );
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await _notificationsPlugin.zonedSchedule(
          id: baseId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } else if (reminder.repeatMode == ReminderRepeatMode.weekdays) {
        final days = reminder.selectedDays.isEmpty
            ? [1, 2, 3, 4, 5, 6, 7]
            : reminder.selectedDays;

        for (final day in days) {
          var scheduledDate = _nextInstanceOfDayAndTime(
            day,
            reminder.hour,
            reminder.minute,
          );
          await _notificationsPlugin.zonedSchedule(
            id: baseId + day,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: payload,
          );
        }
      }
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
