// lib/notification_helper.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _runningId = 1;
  static const String _channelId = 'cartenz_data_waster_channel';
  static const String _channelName = 'Cartenz Data Waster';
  static const String _channelDescription =
      'Shows current status of Cartenz Data Waster tests.';

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> _showOrUpdateRunning({
    required double totalMb,
    required double currentSpeed,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      onlyAlertOnce: true,
    );

    final details = NotificationDetails(android: androidDetails);

    final title = 'Cartenz Data Waster';
    final body =
        'Running test • ${currentSpeed.toStringAsFixed(2)} MB/s • '
        '${totalMb.toStringAsFixed(2)} MB used';

    await _plugin.show(_runningId, title, body, details);
  }

  static Future<void> showRunningNotification({
    required double totalMb,
    required double currentSpeed,
  }) async {
    await _showOrUpdateRunning(totalMb: totalMb, currentSpeed: currentSpeed);
  }

  static Future<void> updateRunningNotification({
    required double totalMb,
    required double currentSpeed,
  }) async {
    await _showOrUpdateRunning(totalMb: totalMb, currentSpeed: currentSpeed);
  }

  static Future<void> cancelRunningNotification() async {
    await _plugin.cancel(_runningId);
  }
}
