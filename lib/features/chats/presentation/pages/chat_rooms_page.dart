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
  // final String userNickName;
  // final String userEmail;
  // final String userProfileImage;

  const ChatRoomsPage({
    super.key,
    required this.userId,
    // required this.userNickName,
    // required this.userEmail,
    // required this.userProfileImage,
  });

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize WebSocket connection
    context.read<ChatBloc>().add(InitializeChatEvent(widget.userId));

    // Load chat rooms when page initializes
    context.read<ChatBloc>().add(LoadChatRoomsEvent(widget.userId));

    // // Connect user to WebSocket
    // final userInfo = UserConnectionInfo(
    //   nickName: widget.userNickName,
    //   email: widget.userEmail,
    //   status: UserStatus.ONLINE,
    // );
    // context.read<ChatBloc>().add(ConnectUserEvent(userInfo));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // // Update user status based on app lifecycle
    // final userInfo = UserConnectionInfo(
    //   nickName: widget.userNickName,
    //   email: widget.userEmail,
    //   status: state == AppLifecycleState.resumed
    //       ? UserStatus.ONLINE
    //       : UserStatus.OFFLINE,
    // );

    // if (state == AppLifecycleState.resumed) {
    //   context.read<ChatBloc>().add(ConnectUserEvent(userInfo));
    // } else if (state == AppLifecycleState.paused ||
    //            state == AppLifecycleState.detached) {
    //   context.read<ChatBloc>().add(DisconnectUserEvent(userInfo));
    // }
  }

  @override
  void dispose() {
    // Disconnect user when leaving the page
    // final userInfo = UserConnectionInfo(
    //   nickName: widget.userNickName,
    //   email: widget.userEmail,
    //   status: UserStatus.OFFLINE,
    // );
    // context.read<ChatBloc>().add(DisconnectUserEvent(userInfo));
    WidgetsBinding.instance.removeObserver(this);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh chat rooms
              context.read<ChatBloc>().add(LoadChatRoomsEvent(widget.userId));
            },
          ),
        ],
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
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<ChatBloc>()
                          .add(LoadChatRoomsEvent(widget.userId));
                      return Future.delayed(const Duration(milliseconds: 1000));
                    },
                    child: ListView.builder(
                      itemCount: state.chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = state.chatRooms[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                "https://" + chatRoom.recipientImagePath),
                            onBackgroundImageError: (exception, stackTrace) {
                              // Handle image loading errors
                            },
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  chatRoom.recipientNickname,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
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
                            ).then((_) {
                              // Refresh chat rooms when returning from chat detail
                              context
                                  .read<ChatBloc>()
                                  .add(LoadChatRoomsEvent(widget.userId));
                            });
                          },
                        );
                      },
                    ),
                  );
          } else if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ChatBloc>()
                          .add(LoadChatRoomsEvent(widget.userId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
