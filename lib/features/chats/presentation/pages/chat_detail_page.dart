// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/widgets/message_bubble.dart';
import 'package:list_in/features/explore/presentation/widgets/recomendation_widget.dart';
import 'package:provider/provider.dart';
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
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Load chat history when page initializes
    Provider.of<ChatProvider>(context, listen: false).loadChatHistory(
      publicationId: widget.publicationId,
      senderId: widget.userId,
      recipientId: widget.recipientId,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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

      Provider.of<ChatProvider>(context, listen: false).sendMessage(message);
      _messageController.clear();

      // Schedule scroll after UI update
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  // Helper function to get formatted date string
  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d, yyyy').format(date); // Mar 15, 2025
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: AppColors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flexibleSpace: Card(
          shadowColor: Theme.of(context).cardColor.withOpacity(0.3),
          margin: EdgeInsets.zero,
          elevation: 2, // Shadow for the card
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CachedNetworkImage(
                          imageUrl: 'https://${widget.userProfileImage}',
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Image.asset(AppImages.appLogo),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recipientName,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Consumer<ChatProvider>(
                            builder: (context, provider, child) {
                              final userStatus = provider.historyState
                                      .userStatuses[widget.recipientId] ??
                                  UserStatus.OFFLINE;
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
                            },
                          ),
                        ],
                      ),
                    ),
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
                                  widget.publicationImagePath.startsWith('http')
                                      ? widget.publicationImagePath
                                      : 'http://listin.uz${widget.publicationImagePath}',
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    height: 100,
                                    width: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  ),
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
              ],
            ),
          ),
        ),
        toolbarHeight: 65, // Adjust this as needed
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                final state = provider.historyState;

                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.publicationImagePath,
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
                  );
                } else {
                  // For first load, scroll to bottom
                  if (_isFirstLoad && state.messages.isNotEmpty) {
                    _isFirstLoad = false;
                    Future.delayed(
                        const Duration(milliseconds: 100), _scrollToBottom);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == widget.userId;

                      // Date header logic
                      bool showDateHeader = false;
                      String dateHeader = '';

                      if (index == 0) {
                        // First message always shows date
                        showDateHeader = true;
                        dateHeader = _getFormattedDate(message.sentAt);
                      } else {
                        // Check if date changed from previous message
                        final previousMessageDate =
                            state.messages[index - 1].sentAt;
                        final messageDate = message.sentAt;

                        if (previousMessageDate.day != messageDate.day ||
                            previousMessageDate.month != messageDate.month ||
                            previousMessageDate.year != messageDate.year) {
                          showDateHeader = true;
                          dateHeader = _getFormattedDate(messageDate);
                        }
                      }

                      // Message grouping logic
                      bool showAvatar = true;
                      if (index < state.messages.length - 1) {
                        final nextMessage = state.messages[index + 1];
                        // Don't show avatar if next message is from same sender and within 5 minutes
                        if (nextMessage.senderId == message.senderId &&
                            nextMessage.sentAt
                                    .difference(message.sentAt)
                                    .inMinutes <
                                5) {
                          showAvatar = false;
                        }
                      }

                      return Column(
                        children: [
                          if (showDateHeader)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    dateHeader,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: MessageBubble(
                                  message: message.content,
                                  isMe: isMe,
                                  time: DateFormat('hh:mm a')
                                      .format(message.sentAt),
                                  status: message.status,
                                  showTail:
                                      showAvatar, // Show tail on the last message in a group
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2), // Spacing between messages
                        ],
                      );
                    },
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
                      padding: const EdgeInsets.all(12),
                      controller: _messageController,
                      minLines: 1,
                      placeholder: "Write something",
                      style: const TextStyle(fontFamily: Constants.Arial),
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
