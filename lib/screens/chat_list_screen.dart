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
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => auth.logout(),
            tooltip: 'Logout',
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.8), Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
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
                'chatId': doc.id,
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent, // You can customize the background color
                        child: Icon(
                          Icons.person, // Default profile icon
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        chat['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat['lastMessage'],
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTimestamp(chat['lastUpdated'].toDate()),
                            style: TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                          SizedBox(height: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat['chatId'],
                            chatName: chat['name'],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    // You can customize this format to your needs
    return '${timestamp.hour}:${timestamp.minute < 10 ? '0${timestamp.minute}' : timestamp.minute}';
  }
}
