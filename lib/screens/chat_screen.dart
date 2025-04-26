import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  ChatScreen({required this.chatId, required this.chatName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Send Text Message
  _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final msg = Message(
      senderId: Provider.of<AuthProvider>(context, listen: false).user?.uid ?? '',
      content: text,
      type: 'text',
      timestamp: DateTime.now(),
    );
    if (msg.senderId.isEmpty) {
      print('Error: User is not authenticated!');
      return;
    }
    Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(widget.chatId, msg);
    _msgCtrl.clear();
  }

  // Pick and Send Image
  _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (userId == null || userId.isEmpty) return;

    final file = File(pickedFile.path);
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      final msg = Message(
        senderId: userId,
        content: imageUrl,
        type: 'image',
        timestamp: DateTime.now(),
      );

      Provider.of<ChatProvider>(context, listen: false)
          .sendMessage(widget.chatId, msg);
    } catch (e) {
      print("Upload failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context).user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: Provider.of<ChatProvider>(context).messagesFor(widget.chatId),
              builder: (ctx, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final msgs = snap.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: msgs.length,
                  itemBuilder: (ctx, i) {
                    final m = msgs[i];
                    final isMe = m.senderId == userId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.deepPurple[100] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                            bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                          ),
                        ),
                        child: m.type == 'text'
                            ? Text(m.content)
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            m.content,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (ctx, error, stack) =>
                                Text("Image failed"),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Colors.blueAccent),
                  onPressed: (){
                    _pickImage();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
