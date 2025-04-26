import 'package:chatrbox/providers/auth_provider.dart';
import 'package:chatrbox/providers/chat_provider.dart';
import 'package:chatrbox/screens/chat_list_screen.dart';
import 'package:chatrbox/screens/chat_screen.dart';
import 'package:chatrbox/screens/login_screen.dart';
import 'package:chatrbox/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Call _printServerKey after Firebase initialization
  await _printServerKey();

  // Handle opening app from a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final chatId = message.data['chatId'];
    if (chatId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chatId, chatName: 'Chat'),
        ),
      );
    }
  });

  runApp(MyApp());
}

Future<void> _printServerKey() async {
  // Simulate retrieval of the server key and print it
  String serverKey = await NotificationService.getServerKey();
  print('Server Key: $serverKey');
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Ensure that we are printing the server key after Firebase has been initialized
    _printServerKey();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Handle authentication
        ChangeNotifierProvider(create: (_) => ChatProvider()), // Handle chat-related logic
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Required for navigation from background
        title: 'SecureChat',
        theme: ThemeData(primarySwatch: Colors.blue), // App theme
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => auth.isAuthenticated
              ? ChatListScreen() // Navigate to chat list screen if authenticated
              : LoginScreen(), // Navigate to login screen if not authenticated
        ),
        debugShowCheckedModeBanner: false,
      ),

    );

  }
}
