import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../navigation/app_shell.dart';

const String _reminderChannelId = 'reminders';
const String _reminderChannelName = 'Rappels';
const String _reminderChannelDescription = 'Rappels contextuels';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Background handler required by flutter_local_notifications.
}

class LocalNotificationsService {
  LocalNotificationsService._();

  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;
  Map<String, String>? _pendingRouteArgs;

  void configureNavigator(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    _flushPendingRoute();
  }

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'reminder_actions',
          actions: [
            DarwinNotificationAction.plain('later', 'Plus tard'),
            DarwinNotificationAction.plain('not_now', 'Pas le bon moment'),
          ],
        ),
      ],
    );
    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final response = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp == true && response != null) {
      _queueRouteFromResponse(response);
    }

    await _requestPermissions();
    await _createChannels();
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _createChannels() async {
    const channel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showReminderNotification({
    required String contactId,
    required String contactName,
    String? message,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannelId,
        _reminderChannelName,
        channelDescription: _reminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        actions: const [
          AndroidNotificationAction('later', 'Plus tard'),
          AndroidNotificationAction('not_now', 'Pas le bon moment'),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'reminder_actions',
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Rappel: $contactName',
      message ?? 'Prenez des nouvelles.',
      details,
      payload: contactId,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    _queueRouteFromResponse(response);
    _flushPendingRoute();
  }

  void _queueRouteFromResponse(NotificationResponse response) {
    final args = buildRouteArgs(response.actionId, response.payload);
    if (args == null) {
      return;
    }
    _pendingRouteArgs = args;
  }

  void _flushPendingRoute() {
    final navigator = _navigatorKey?.currentState;
    final args = _pendingRouteArgs;
    if (navigator == null || args == null) {
      return;
    }
    _pendingRouteArgs = null;
    navigator.pushNamed(
      AppShell.routeName,
      arguments: args,
    );
  }

  static Map<String, String>? buildRouteArgs(
    String? actionId,
    String? contactId,
  ) {
    if (!isDeferralAction(actionId)) {
      return null;
    }
    if (contactId == null || contactId.isEmpty) {
      return null;
    }
    return {
      'action': actionId!,
      'contactId': contactId,
    };
  }

  static bool isDeferralAction(String? actionId) {
    return actionId == 'later' || actionId == 'not_now';
  }
}
