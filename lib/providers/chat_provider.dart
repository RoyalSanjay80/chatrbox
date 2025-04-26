import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/message.dart';
import 'package:http/http.dart'as http;

class ChatProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  Future<void> _sendPushNotification(String chatId, Message message) async {
    // 1. Get chat participants (assuming chatId is user1_user2)
    final ids = chatId.split('_');
    final receiverId = ids.firstWhere((id) => id != message.senderId);

    // 2. Get FCM Token from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(receiverId).get();
    final token = userDoc['fcmToken'];

    if (token == null) return;

    // 3. Send POST request to FCM
    final body = {
      "to": token,
      "notification": {
        "title": "New message",
        "body": message.type == 'text' ? message.content : "📷 Image message"
      },
      "data": {
        "chatId": chatId,
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    };

    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=ya29.c.c0ASRK0GbPkZVMLUgQ-lWp1FJzQ5v59oUbwIPHmQni2dvGFULgJyw6YP2d4nBihRcdY6ry9-j3UYWzFIRslVP7cUcLne5t4gaJfa7Xm57mcTeWGjXXOltVROg-SfTqZELcNfCF4zQakb32AogXw_U3yxhQ6MTtvq9gEf_rRCp2Muyuf8ErKUEuVKNzw5VQs8xLlc4MNEaPTjOILAO-AE8rkgTkQpGenRrgg4zy41Kyw9SI0Xx6mfQhOAzsnCBchXlPhGht_c-NrPtI3Uip9vSmAjsLsIGdZ192H7-_bF0El-MdvEloiEoE2KO2xJ8s4PDR8es1IPcXQiYW2qInAro7tkCZCfMed0aEWPZMiZviib8NtUa8oexR5srmHlYN388DwcuexInaUixJfq88qYgUl3V0O91Fve7ORdl0ragyWntFUv-xFOUy8r5YaMYajvkJIdO1j0ut8XbVUBXxpSUBJWzXB4Y7_a7aiI_bxYyrX-6j1VMbo7-Y9a3gnwrkm3Zcdr7rlkz-bvYu147OVhdMRytk2JOBV_mF47Ml8RolfWVwq--kmtc6crUWtliu9_fBYWVjIlYJoY_p2z9OXX8sQUvl91Mno48lcXagBsdks9nBwUdBJFQYooqO6RXjoMq1iltmRqdSOvvcd3r2mn0bisWm0fMxeJyw5kwIlBWm99MqweId5s_ncqRaX1fqB2j_uBdwFsJXzYk23Wnq7mYh3gO50pVcSg-vkp7gqgczlhvaVZ9BZs3ekwiyFpzIF47y_ZFoqzrMXRhcf5ZsooYqoUVo5XXmy6Z4w_8FZJX-t7qOXxxgq_f0kkmsFWsFIp-sMSUzS4k1y58dZyQ8pJ4JxiuS9o0Qo7hYzptsZzoY7sOx-3aqfwrUFeQh6Ot6cg2Zh2YaUp1fpFVpUcxBZY2sSznM_fUiZ8QhY1Z1z9UqnmdhR6-Mbc5S1lR4u0O47tm9h8p0kttZShos9MuOvBk2RxVJOOI14q4ZhyonIgo7Va', // 🔑 Replace this with your FCM server key
      },
      body: json.encode(body),
    );
  }

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

    await _sendPushNotification(chatId, msg);
  }
}
