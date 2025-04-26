// lib/presentation/pages/chat_detail_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/presentation/blocs/chats/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/blocs/chats/chat_event.dart';
import 'package:list_in/features/chats/presentation/blocs/chats/chat_state.dart';
import 'package:list_in/features/chats/presentation/widgets/message_bubble.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ChatDetailPage extends StatefulWidget {
  final String userId;
  final String publicationId;
  final String recipientId;
  final String publicationTitle;
  final String recipientName;
  final String publicationImagePath;
  final String userProfileImage;

  const ChatDetailPage({
    super.key,
    required this.userId,
    required this.publicationId,
    required this.recipientId,
    required this.publicationTitle,
    required this.recipientName,
    required this.publicationImagePath,
    required this.userProfileImage,
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load chat history when page initializes
    context.read<ChatBloc>().add(
          LoadChatHistoryEvent(
            publicationId: widget.publicationId,
            senderId: widget.userId,
            recipientId: widget.recipientId,
          ),
        );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = ChatMessage(
        senderId: widget.userId,
        recipientId: widget.recipientId,
        publicationId: widget.publicationId,
        content: _messageController.text,
        status: 'SENT',
        sentAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<ChatBloc>().add(SendMessageEvent(message));
      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
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
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userProfileImage,
              ),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is ChatHistoryLoaded) {
                        final userStatus =
                            state.userStatuses[widget.recipientId];
                        return Text(
                          userStatus == UserStatus.ONLINE
                              ? 'Online'
                              : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: userStatus == UserStatus.ONLINE
                                ? Colors.green
                                : Colors.grey,
                          ),
                        );
                      }
                      return const Text(
                        'Loading status...',
                        style: TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show publication details
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'http://listin.uz${widget.publicationImagePath}',
                        height: 100,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.publicationTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ChatHistoryLoaded) {
                  return state.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'http://listin.uz${widget.publicationImagePath}',
                                height: 100,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Interested in ${widget.publicationTitle}?',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Send a message to start the conversation',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == widget.userId;

                            return MessageBubble(
                              message: message.content,
                              isMe: isMe,
                              time:
                                  DateFormat('hh:mm a').format(message.sentAt),
                              status: message.status,
                            );
                          },
                        );
                } else if (state is ChatError) {
                  return Center(
                    child: Text('Error: ${state.message}'),
                  );
                } else {
                  return const Center(
                    child: Text('Start a conversation'),
                  );
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.paperclip,
                    size: 22,
                  ),
                  onPressed: () {
                    // Would implement attachment functionality
                  },
                ),
                Expanded(
                  child: SmoothClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CupertinoTextField(
                      decoration:
                          BoxDecoration(color: AppColors.containerColor),
                      padding: EdgeInsets.all(12),
                      controller: _messageController,
                      minLines: 1,
                      placeholder: "Write something",
                      style: TextStyle(fontFamily: Constants.Arial),
                      maxLines: 10,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.telegram,
                    size: 28,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
