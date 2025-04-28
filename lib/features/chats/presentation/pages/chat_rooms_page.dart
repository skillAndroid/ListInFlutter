import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/chats/presentation/pages/chat_detail_page.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_bloc.dart';
import 'package:provider/provider.dart';

class ChatRoomsPage extends StatefulWidget {
  final String userId;

  const ChatRoomsPage({
    super.key,
    required this.userId,
  });

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  @override
  void initState() {
    super.initState();

    // Initialize the chat system
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.initializeChat(widget.userId);

    // Load chat rooms
    if (chatProvider.roomsState.chatRooms.isEmpty) {
      chatProvider.loadChatRooms(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: AppColors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false)
                  .loadChatRooms(widget.userId);
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final state = chatProvider.roomsState;

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state.chatRooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your conversations will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                chatProvider.loadChatRooms(widget.userId);
                return Future.delayed(const Duration(milliseconds: 1000));
              },
              child: ListView.builder(
                itemCount: state.chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = state.chatRooms[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://${chatRoom.recipientImagePath}"),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Handle image loading errors
                      },
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatRoom.recipientNickname,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Online status indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors
                                .green, // Would be dynamic based on user status
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chatRoom.lastMessage?.content ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chatRoom.lastMessage != null)
                          Text(
                            DateFormat('hh:mm a')
                                .format(chatRoom.lastMessage!.sentAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${chatRoom.publicationPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailPage(
                            userId: widget.userId,
                            publicationId: chatRoom.publicationId,
                            recipientId: chatRoom.recipientId,
                            publicationTitle: chatRoom.publicationTitle,
                            recipientName: chatRoom.recipientNickname,
                            publicationImagePath: chatRoom.publicationImagePath,
                            userProfileImage: chatRoom.recipientImagePath,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
