// import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final NotificationService instance = NotificationService._internal();
//   factory NotificationService() => instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   Future<void> initialize() async {
//     // Initialize Firebase
//     await Firebase.initializeApp();

//     // Setup local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

//     final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       notificationCategories: [
//         DarwinNotificationCategory('default', options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle}),
//       ],
//     );

//     final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) async {
//         // Handle notification tap
//       },
//     );

//     // Create notification channel for Android
//     if (Platform.isAndroid) {
//       await _createNotificationChannel();
//     }

//     // Firebase Messaging setup
//     await _setupFirebaseMessaging();
//   }

//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications', importance: Importance.max);

//     await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
//   }

//   Future<void> _setupFirebaseMessaging() async {
//     // Request notification permissions
//     NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     // Get FCM token
//     String? token = await FirebaseMessaging.instance.getToken();
//     // debugPrint('FCM Token: $token');

//     // Foreground message handling
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(message);
//     });

//     // Background message handling
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // Handle notification when app is opened from terminated state
//     });
//   }

//   Future<void> _showNotification(RemoteMessage message) async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     DarwinNotificationDetails iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

//     NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

//     await flutterLocalNotificationsPlugin.show(message.hashCode, message.notification?.title, message.notification?.body, platformChannelSpecifics, payload: message.data.toString());
//   }
// }
