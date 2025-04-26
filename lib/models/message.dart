import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String content;
  final String type; // text/image
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  factory Message.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'],
      content: data['content'],
      type: data['type'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'content': content,
    'type': type,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
