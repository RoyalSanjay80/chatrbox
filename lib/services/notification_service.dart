import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      _showLocalNotification(msg.notification!);
    });

    // Get token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    // TODO: send token to Firestore under user profile
  }

  Future<void> _showLocalNotification(RemoteNotification notif) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel', 'Chat Messages',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);
    await _local.show(
      notif.hashCode,
      notif.title,
      notif.body,
      details,
    );
  }
}