// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/widgets/message_bubble.dart';
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
  bool _showScrollToBottom = false;
  int _lastReadIndex = -1;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    // Load chat history when page initializes
    _loadChatHistory();

    // Add scroll listener to show/hide scroll button
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show scroll to bottom button when not at bottom
    final isAtBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    if (isAtBottom != !_showScrollToBottom) {
      setState(() {
        _showScrollToBottom = !isAtBottom;
      });
    }
  }

  Future<void> _loadChatHistory() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Load chat history
    await chatProvider.loadChatHistory(
      publicationId: widget.publicationId,
      senderId: widget.userId,
      recipientId: widget.recipientId,
    );

    // Get unread info
    _lastReadIndex = chatProvider.getLastReadMessageIndex();
    _unreadCount = chatProvider.historyState.unreadCount;

    // Mark messages as read
    chatProvider.markMessagesAsRead(
      publicationId: widget.publicationId,
      senderId: widget.userId,
      recipientId: widget.recipientId,
    );

    // Schedule scroll after UI update
    if (_isFirstLoad) {
      _isFirstLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialPosition();
      });
    }
  }

  void _scrollToInitialPosition() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messages = chatProvider.historyState.messages;

    if (messages.isEmpty) return;

    // If there are unread messages, scroll to the first unread message
    if (_unreadCount > 0 &&
        _lastReadIndex >= 0 &&
        _lastReadIndex < messages.length - 1) {
      _scrollToIndex(_lastReadIndex + 1);

      // Show scroll to bottom button
      setState(() {
        _showScrollToBottom = true;
      });
    } else {
      // Otherwise scroll to bottom
      _scrollToBottom();
    }
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients || index < 0) return;

    try {
      // Calculate context position to scroll to (this is approximate)
      final itemHeight = 80.0; // Approximate height of each message
      final position = index * itemHeight;

      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error scrolling to index $index: $e');
      // Fallback to scrolling to bottom
      _scrollToBottom();
    }
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
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Consumer<ChatProvider>(
                    builder: (context, provider, child) {
                      final userStatus = provider
                              .historyState.userStatuses[widget.recipientId] ??
                          UserStatus.OFFLINE;
                      return Text(
                        userStatus == UserStatus.ONLINE ? 'Online' : 'Offline',
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
                        widget.publicationImagePath.startsWith('http')
                            ? widget.publicationImagePath
                            : 'http://listin.uz${widget.publicationImagePath}',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => Container(
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
                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMe = message.senderId == widget.userId;
                          final isLastReadMessage = _lastReadIndex == index;

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
                                previousMessageDate.month !=
                                    messageDate.month ||
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
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

                              // Show unread messages indicator if this is where unread messages start
                              if (isLastReadMessage &&
                                  index < state.messages.length - 1)
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.mark_chat_unread,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${state.messages.length - index - 1} new messages',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
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
                              const SizedBox(
                                  height: 2), // Spacing between messages
                            ],
                          );
                        },
                      ),

                      // Scroll to bottom button
                      if (_showScrollToBottom)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            onPressed: _scrollToBottom,
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ),
                    ],
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
