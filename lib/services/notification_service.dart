// --- START OF FILE lib/services/notification_service.dart ---
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart'; // Impor ini untuk Color dan debugPrint
import 'package:doable_todo_list_app/models/todo.dart'; // Import Todo model
// import 'package:flutter/foundation.dart'; // Alternatif jika hanya butuh debugPrint, tapi material.dart juga sudah mencakup

class NotificationService {
  static const String channelKey = 'task_reminders';

  // Inisialisasi Awesome Notifications
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      // Atur null jika tidak menggunakan ikon kecil kustom
      null,
      [
        NotificationChannel(
          channelKey: channelKey,
          channelName: 'Task Reminders',
          channelDescription: 'Notifications for upcoming tasks',
          defaultColor: const Color(0xFF9D50DD), // Fix: Color sudah diimpor
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        )
      ],
      debug: true, // Set to false in production
    );
    debugPrint('NotificationService: Awesome Notifications initialized.'); // Fix: debugPrint sudah bisa diakses
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Check if notifications are enabled by the user (system-wide)
  static Future<bool> areNotificationsEnabledByUser() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Cancel all scheduled notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
    debugPrint('NotificationService: All scheduled notifications cancelled.');
  }

  // Schedule a single notification for a Todo
  static Future<void> scheduleNotification(Todo todo) async {
    final int notificationId = int.parse(todo.id.hashCode.toString().substring(0, 9));

    if (!todo.hasNotification || todo.scheduledDate == null || todo.scheduledTime == null) {
      await AwesomeNotifications().cancel(notificationId);
      debugPrint('NotificationService: Cancelled notification for ${todo.title} due to incomplete info or no reminder.');
      return;
    }

    final scheduleDateTime = DateTime(
      todo.scheduledDate!.year,
      todo.scheduledDate!.month,
      todo.scheduledDate!.day,
      todo.scheduledTime!.hour,
      todo.scheduledTime!.minute,
    );

    if (scheduleDateTime.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      debugPrint('NotificationService: Skipping past notification for todo: ${todo.title} at $scheduleDateTime');
      await AwesomeNotifications().cancel(notificationId);
      return;
    }

    bool repeats = false;
    List<int>? weekdays;

    if (todo.repeatRule != null && todo.repeatRule != 'No repeat') {
      repeats = true;
      if (todo.repeatRule!.startsWith('Weekly:')) {
        weekdays = _parseWeeklyRepeatRule(todo.repeatRule!);
        if (weekdays == null || weekdays.isEmpty) {
          repeats = false;
        }
      }
    }

    final payload = {'task_id': todo.id};
    NotificationCalendar? schedule;

    if (repeats && todo.repeatRule == 'Daily') {
      schedule = NotificationCalendar(
        hour: scheduleDateTime.hour,
        minute: scheduleDateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      );
    } else if (repeats && todo.repeatRule == 'Monthly') {
      schedule = NotificationCalendar(
        day: scheduleDateTime.day,
        hour: scheduleDateTime.hour,
        minute: scheduleDateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      );
    } else if (repeats && weekdays != null && weekdays.isNotEmpty) {
      for (int weekday in weekdays) {
         await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId + weekday,
            channelKey: channelKey,
            title: todo.title,
            body: todo.description ?? 'Don\'t forget your task!',
            category: NotificationCategory.Reminder,
            payload: payload,
            wakeUpScreen: true,
            notificationLayout: NotificationLayout.Default,
            autoDismissible: false,
            locked: false,
          ),
          schedule: NotificationCalendar(
            weekday: weekday,
            hour: scheduleDateTime.hour,
            minute: scheduleDateTime.minute,
            second: 0,
            millisecond: 0,
            repeats: true,
          ),
        );
        debugPrint('Scheduled WEEKLY notification for: ${todo.title} on weekday $weekday at ${scheduleDateTime.hour}:${scheduleDateTime.minute}');
      }
      return;
    } else {
      schedule = NotificationCalendar(
        year: scheduleDateTime.year,
        month: scheduleDateTime.month,
        day: scheduleDateTime.day,
        hour: scheduleDateTime.hour,
        minute: scheduleDateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      );
    }

    if (schedule != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: channelKey,
          title: todo.title,
          body: todo.description ?? 'Don\'t forget your task!',
          category: NotificationCategory.Reminder,
          payload: payload,
          wakeUpScreen: true,
          notificationLayout: NotificationLayout.Default,
          autoDismissible: false,
          locked: false,
        ),
        schedule: schedule,
      );
      debugPrint('Scheduled notification for: ${todo.title} at $scheduleDateTime (Rule: ${todo.repeatRule ?? 'Once'})');
    }
  }

  static Future<void> rescheduleAllNotifications(List<Todo> todos) async {
    await cancelAllNotifications();
    debugPrint('NotificationService: Rescheduling all notifications for ${todos.length} todos.');
    for (var todo in todos) {
      if (!todo.completed) {
        await scheduleNotification(todo);
      }
    }
    debugPrint('NotificationService: Finished rescheduling all notifications.');
  }

  static List<int>? _parseWeeklyRepeatRule(String repeatRule) {
    final regex = RegExp(r'Weekly:\[(\d+(,\s*\d+)*)\]');
    final match = regex.firstMatch(repeatRule);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.split(',').map((s) => int.parse(s.trim())).toList();
    }
    return null;
  }
}
// --- END OF FILE lib/services/notification_service.dart ---