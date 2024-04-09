import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUsre = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Chats Found'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }

        final loadChats = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(
            bottom: 40,
            left: 30,
            right: 30,
          ),

          /// reverse true means chat will show bottom to top
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadChats[index].data();
            final nextChatMessage = index + 1 < loadChats.length
                ? loadChats[index + 1].data()
                : null;
            final currentChatMessageUserId = chatMessage['userId'];
            final nextChatMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame =
                currentChatMessageUserId == nextChatMessageUserId;
            if (nextUserIsSame) {
              MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUsre!.uid == currentChatMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['userName'],
                message: chatMessage['text'],
                isMe: authenticatedUsre!.uid == currentChatMessageUserId,
              );
            }
            return Text(loadChats[index].data()['text']);
          },
          itemCount: loadChats.length,
        );
      },
    );
  }
}
