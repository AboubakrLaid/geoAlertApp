import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geoalert/core/network/api_client.dart';
import 'package:geoalert/core/storage/local_storage.dart';
import 'package:geoalert/data/repositories/firebase_repository_impl.dart';
import 'package:geoalert/domain/usecases/register_fcm_token_usecase.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup message handlers
    await _setupMessageHandlers();

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    LocalStorage.instance.setFcmToken(token!);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false, announcement: false, carPlay: false, criticalAlert: false);
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    // android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // // ios setup
    // final initializationSettingsDarwin = DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id, title, body, payload) async {
    //     // Handle iOS foreground notification
    //   },
    // );

    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    // flutter notification setup
    await _localNotifications.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {});

    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    final data = message.data;
    print('Background message data: $data');
  }
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:geoalert/core/storage/local_storage.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await NotificationService.instance.setupFlutterNotifications();
//   await NotificationService.instance.showNotification(message);
// }

// class NotificationService {
//   NotificationService._();
//   static final NotificationService instance = NotificationService._();

//   final _messaging = FirebaseMessaging.instance;
//   final _localNotifications = FlutterLocalNotificationsPlugin();
//   bool _isFlutterLocalNotificationsInitialized = false;

//   Future<void> initialize() async {
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Request permission
//     await _requestPermission();

//     // Setup message handlers
//     await _setupMessageHandlers();

//     // Get FCM token
//     final token = await _messaging.getToken();
//     print('FCM Token: $token');
//     LocalStorage.instance.setFcmToken(token!);
//   }

//   Future<void> _requestPermission() async {
//     final settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//       announcement: false,
//       carPlay: false,
//       criticalAlert: false,
//     );
//   }

//   Future<void> setupFlutterNotifications() async {
//     if (_isFlutterLocalNotificationsInitialized) {
//       return;
//     }

//     // Android setup
//     const channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );

//     await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS setup (optional, but you can add custom logic here if needed)
//     // final initializationSettingsDarwin = DarwinInitializationSettings(
//     //   onDidReceiveLocalNotification: (id, title, body, payload) async {
//     //     // Handle iOS foreground notification
//     //   },
//     // );

//     final initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

//     // Flutter notification setup
//     await _localNotifications.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {});

//     _isFlutterLocalNotificationsInitialized = true;
//   }

//   Future<void> showNotification(RemoteMessage message) async {
//     // For data-only messages, you can handle your custom notification logic here
//     final data = message.data;
//     final title = data['title'] ?? 'No title';
//     final body = data['body'] ?? 'No body';

//     // Show notification using Flutter Local Notifications
//     await _localNotifications.show(
//       message.hashCode,  // Use the hashcode for a unique ID
//       title,  // Title of the notification
//       body,   // Body of the notification
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel',
//           'High Importance Notifications',
//           channelDescription: 'This channel is used for important notifications.',
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/ic_launcher',
//         ),
//         iOS: const DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//       payload: jsonEncode(data),  // Pass the data payload for use later
//     );
//   }

//   Future<void> _setupMessageHandlers() async {
//     // Foreground message handler
//     FirebaseMessaging.onMessage.listen((message) {
//       showNotification(message); // Show the notification in the foreground
//     });

//     // Background message handler (when the app is in the background)
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

//     // Handle the initial message when the app is opened from a terminated state
//     final initialMessage = await _messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleBackgroundMessage(initialMessage);
//     }
//   }

//   void _handleBackgroundMessage(RemoteMessage message) {
//     // Handle background message (when app is opened via tapping notification)
//     final data = message.data;
//     print('Background message data: $data');

//     // You can use data to navigate to a specific screen if needed
//     // For example, if your notification has an `alert_id` you can handle navigation:
//     if (data['alert_id'] != null) {
//       // Navigate to a specific screen using the alert_id
//       // Navigator.pushNamed(context, '/alert', arguments: data['alert_id']);
//     }
//   }
// }
