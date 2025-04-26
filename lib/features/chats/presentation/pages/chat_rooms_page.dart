// lib/presentation/pages/chat_rooms_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/presentation/blocs/chats/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/blocs/chats/chat_event.dart';
import 'package:list_in/features/chats/presentation/blocs/chats/chat_state.dart';
import 'package:list_in/features/chats/presentation/pages/chat_detail_page.dart';

class ChatRoomsPage extends StatefulWidget {
  final String userId;

  const ChatRoomsPage({super.key, required this.userId});

  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  @override
  void initState() {
    super.initState();
    // Load chat rooms when page initializes
    context.read<ChatBloc>().add(LoadChatRoomsEvent(widget.userId));

    // Connect user to WebSocket
    final userInfo = UserConnectionInfo(
      nickName: 'User', // Get from user profile
      email: 'user@example.com', // Get from user profile
      status: UserStatus.ONLINE,
    );
    context.read<ChatBloc>().add(ConnectUserEvent(userInfo));
  }

  @override
  void dispose() {
    // Disconnect user when leaving the page
    final userInfo = UserConnectionInfo(
      nickName: 'User', // Get from user profile
      email: 'user@example.com', // Get from user profile
      status: UserStatus.OFFLINE,
    );
    context.read<ChatBloc>().add(DisconnectUserEvent(userInfo));
    super.dispose();
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
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is ChatRoomsLoaded) {
            return state.chatRooms.isEmpty
                ? const Center(
                    child: Text('No messages yet'),
                  )
                : ListView.builder(
                    itemCount: state.chatRooms.length,
                    itemBuilder: (context, index) {
                      // lib/presentation/pages/chat_rooms_page.dart (continued)
                      final chatRoom = state.chatRooms[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'http://listin.uz${chatRoom.recipientImagePath}',
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              chatRoom.recipientNickname,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            // This would show online status if available
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
                                chatRoom.lastMessage?.content ??
                                    'No messages yet',
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
                                publicationImagePath:
                                    chatRoom.publicationImagePath,
                                userProfileImage: chatRoom.recipientImagePath,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
          } else if (state is ChatError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          } else {
            return const Center(
              child: Text('No messages yet'),
            );
          }
        },
      ),
    );
  }
}
