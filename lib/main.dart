import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'firebase_options.dart'; // Import firebase_options.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Initialize with platform-specific options
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Optionally handle the error (e.g., show an error screen or fallback)
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'SecureChat',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) => auth.isAuthenticated
              ? ChatListScreen()
              : LoginScreen(),
        ),
      ),
    );
  }
}
