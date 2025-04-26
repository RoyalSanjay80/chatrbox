import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';

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


  static Future<String> getServerKey() async {
    final scopes = [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
      // Add other scopes as needed
    ];

    // Replace the JSON credentials path with your service account JSON file
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
        '''{
  "type": "service_account",
  "project_id": "test-9f415",
  "private_key_id": "63fab5a22a80eb4cfcb4784984b42473f99a7101",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDQyzbNgzz8/svy\\n5ADOiLJbD315KDS29z9jtNpM/kU12JZSKBe5afz6/tZD3HFRYyIBtOBFiLltY6gZ\\npOjP0bAan7H9y+hdIExISar7K5f9BO0w6Bgz8BkzzZ2XBorl8PiiW8AK5Ks1wkFa\\ncGtjLiKY4T+puYeKrdzlhw8Q99ZZIB1aLb2Dkfa3cv5ZBkK+8UazjT6vYf58weaj\\nUfUjnLyuLFHUtG8f+8Dbz5iLlMfGcUxsHpAybe2P0A1U810n1WkjaS6se4M4y9J0\\nplUgeRnjWTJE3zFhhWTCa7Db1QqO6YGp5wwPv0kbSKo16IGY7k3wMbO4JUmbwrkm\\nWeUXSkKVAgMBAAECggEAAn2WEQQCf3sTmDlfiBcp13u7Ea2o2VDgNPKEkxwKW87S\\nVjcLt2a8AYt2J1eTE3c1AeO0NCgiHBuu9uVYcJgt+1dR0nby9d9rgYY9b6MQvFAp\\neyadmUsBJfTLLzDBCeaitJ8XDpo1L546VNeX9FYpy/yN25qusvkJdER06c0nBaee\\no0c/akFT0PfErKopdvJRUpYSeIjsWyxAapRuijcfF5j6fpgyVNvie7j1ByX8l0zo\\n+iK0NWZ11KQX+/EUR+IpZnfl+0eysXraTkRt6/WPTE23uytCxJmGe5EEpBCvPyRy\\n/o2LTv/5IvdHUtG3fCgtmnIv7L935eVrcGzhhaQhqQKBgQDZQvii1Jet9IGoj4mk\\nEMsKcg5ER0aaTEDWPdGrKNw1dodO5mIAU/s6PDwwPdoeV6E2aEv73VlIdBKrIK7K\\nHi4J6o6FnRhTwYs/+arjTJe5u9iMxPkXU64D/90Z1KRsQr0T8I5292OZexQzjrhc\\nyzXG79USDR8wDHB/7jZ5Hf25SQKBgQD2BbmqmxYYhtL/W1i4L/sVukkCOx1PXRYy\\nlymiRDdhkYMWjiWX9UY/Mx7o4hGG32FkWOfVi/VgtzssUt2YCzplJ+RBW3crelke\\n7QdV3Yv8PRxD81W1PSWI2FVg4uXaXPlhXH7cJEznuZyWDuaw1qw+bRGZ6XEihxy8\\nbAT7+MHq7QKBgAmUpHY5vb6UC6utOLqdava49NwZ8IkZV7qa20Ya9Sr+YRUfn664\\nBVoaEeVmtNmlr5xAmSkwJ6HETJZzSIHtNsaFK2fE96+p10Qo9Fo1pHMyT2hVv05C\\nCGhwvgVHlUCY6NGaSA4C9sdr4AYuAv9EjsiJBvJW1cs+oS9jB8/rfKbRAoGBAJ7/\\nlj3HWyFgyS6VZ6IqCDjDmvmhINEw1O6/OP4Q3kXlV/YUygEKWGrx6/EQYclrxrKm\\nrrYZbO0jnk+IAoSIBSZpAKCorzzfJofRImOA+j57dDAKLIMkUIS/Y3ZpTamxWs5s\\ni+RUZYuBLszgNoFlTA5QSQbSkvaAoba4jQQXgaQFAoGBAJxG/Afhz0XbxD4mJTQS\\nb0qG8rEpz6/2R3LbntT3BTttRws4DuYui9IsDNA9/wo1sqtNXu+FUn4NJzobn0FW\\nHgnCzbOYGCF7fYR+kXNmd9u9jqVVsDdvG2nCiSHLt0V8mOHI6M0IGaFeOMcGlzbq\\nKWMxOlh9YdPPwXM1p95wWjFF\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-t37sf@test-9f415.iam.gserviceaccount.com",
  "client_id": "100155303209363166975",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-t37sf%40test-9f415.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}'''
    );

    // Create an authenticated client
    final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);
    final accesskey=client.credentials.accessToken.data;

    return accesskey;
  }


}

