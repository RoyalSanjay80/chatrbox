import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> messagesFor(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Message.fromDoc(d)).toList());
  }

  Future<void> sendMessage(String chatId, Message msg) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(msg.toMap());
  }
}