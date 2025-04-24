import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats available.'));
          }

          var chatData = snapshot.data!.docs.map((doc) {
            return {
              'chatId': doc.id,  // Extract chatId (Document ID)
              'name': doc['name'] ?? 'No name',
              'lastMessage': doc['lastMessage'] ?? 'No message',
              'lastUpdated': doc['lastUpdated'] ?? Timestamp.now(),
              'participants': List<String>.from(doc['participants'] ?? []),
            };
          }).toList();

          return ListView.builder(
            itemCount: chatData.length,
            itemBuilder: (context, index) {
              var chat = chatData[index];
              return ListTile(
                title: Text(chat['name']),
                subtitle: Text(chat['lastMessage']),
                trailing: Text(chat['lastUpdated'].toDate().toString()),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatId: chat['chatId'],  // Pass chatId here
                      chatName: chat['name'],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
