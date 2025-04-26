import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  bool get isAuthenticated => user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  // Function to save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String uid) async {
    try {
      print("👉 Trying to get FCM token for $uid");

      // Request permission to receive notifications (for iOS devices)
      await FirebaseMessaging.instance.requestPermission();

      // Get FCM token
      final token = await FirebaseMessaging.instance.getToken();

      if (token == null) {
        print("❌ FCM Token is NULL");
        return;
      }

      print("✅ FCM Token mil gaya: $token");

      // Save the token to Firestore under the 'token' collection
      await FirebaseFirestore.instance.collection('token').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields

      print("✅ Token Firestore me save ho gaya");

    } catch (e) {
      print("🔥 Error saving FCM token: $e");
    }
  }

  // Login function
  Future<void> login(String email, String pass) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      user = userCred.user;
      await _saveTokenToFirestore(user!.uid); // Save token after login
    } catch (e) {
      print("🔥 Error during login: $e");
    }
  }

  // Signup function
  Future<void> signup(String email, String pass) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      user = userCred.user;

      // Save user details to Firestore after signup
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': email,
      });

      // Save the FCM token to Firestore after signup
      await _saveTokenToFirestore(user!.uid);
    } catch (e) {
      print("🔥 Error during signup: $e");
    }
  }

  // Logout function
  Future<void> logout() async {
    await _auth.signOut();
  }
}
