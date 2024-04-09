import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {

  final _messageController = TextEditingController();
  final FocusNode _newMessageFocus = FocusNode();

  void _submitMessage() async {

    final message = _messageController.text;
    if(message.trim().isEmpty){
      return;
    }
    // hide keyboard
    FocusScope.of(context).unfocus();
    // Clear text
    _messageController.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text':message,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userdata.data()!['user_name'],
      'userImage': userdata.data()!['image_url'],
    });

  }
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              focusNode: _newMessageFocus,
              onSubmitted: (value) {
                // hide keyboard
                _newMessageFocus.unfocus();
                _submitMessage();
              },
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                labelText: 'Send message...'
              ),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
