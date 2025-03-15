// import 'dart:convert';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/home2.dart';
// import 'package:auradot_icheck_mobile_c82b4f96ec40/main.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Future<void> handleBakcgroundMessage(RemoteMessage message) async {
//   print("Title : ${message.notification?.title}");
//   print("Body : ${message.notification?.body}");
//   print("Payload : ${message.data}");
// }

// class FirebaseApi {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   final _androidChannel = const AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: "This channel is used for important notifications",
//     importance: Importance.defaultImportance,
//   );

//   final _localNotifications = FlutterLocalNotificationsPlugin();

//   void handleMessage(RemoteMessage? message2) async {
//     if (message2 == null) return;
//     navigatorKey.currentState?.pushNamed(Home2.route, arguments: message2);
//   }

//   Future initLocalNotifications() async {
//     const ios = DarwinInitializationSettings();
//     const android = AndroidInitializationSettings('@drawable/new_logo');
//     const settings = InitializationSettings(android: android, iOS: ios);

//     await _localNotifications.initialize(settings,
//         onDidReceiveNotificationResponse: (payload) {});
//   }

//   Future initPushNotifications() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//             alert: true, badge: true, sound: true);
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBakcgroundMessage);

//     FirebaseMessaging.onMessage.listen((mesg) {
//       final notifcation = mesg.notification;
//       if (notifcation == null) return;

//       _localNotifications.show(
//           notifcation.hashCode,
//           notifcation.title,
//           notifcation.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               _androidChannel.id,
//               _androidChannel.name,
//               channelDescription: _androidChannel.description,
//               icon: '@drawable/new_logo',
//               priority: Priority.high,
//               playSound: true,
//               sound: _androidChannel.sound,
//               ticker: 'ticker',
//             ),
//             iOS: DarwinNotificationDetails(
//               presentAlert: true,
//               presentBadge: true,
//               presentSound: true,
//             ),
//           ),
//           payload: jsonEncode(mesg.toMap()));
//     });
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fcmToken = await _firebaseMessaging.getToken();

//     print("Token $fcmToken");
//     initPushNotifications();
//     initLocalNotifications();
//   }
// }
