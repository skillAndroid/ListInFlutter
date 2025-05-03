// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/assets/app_images.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_provider.dart';
import 'package:list_in/features/chats/presentation/widgets/message_bubble.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

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
  final FocusNode _focusNode = FocusNode();
  final Uuid _uuid = Uuid();

  // Set to track messages that have been marked as viewed
  final Set<String> _viewedMessageIds = {};

  @override
  void initState() {
    super.initState();

    // Load chat history
    context.read<ChatProvider>().loadChatHistory(
          publicationId: widget.publicationId,
          senderId: widget.userId,
          recipientId: widget.recipientId,
        );

    // Mark messages as viewed when page becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markUnreadMessagesAsViewed();
    });
  }

  // Scroll to bottom (for reversed list)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void _markUnreadMessagesAsViewed() {
    final messages = context.read<ChatProvider>().historyState.messages;

    final unreadMessages = messages
        .where((msg) =>
            msg.senderId != widget.userId &&
            msg.status != 'VIEWED' &&
            !_viewedMessageIds.contains(msg.id))
        .toList();

    if (unreadMessages.isEmpty) return;

    // Get IDs of messages to mark as viewed
    final messageIds = unreadMessages.map((msg) => msg.id).toList();

    // Add to our tracking set
    messageIds.forEach(_viewedMessageIds.add);

    // Send viewed status to server
    context
        .read<ChatProvider>()
        .sendMessageViewedStatus(widget.recipientId, messageIds);
  }

  // Send a message
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Generate a unique ID for the message
    final messageId = _uuid.v4();

    // Create the message object with the generated ID
    final message = ChatMessage(
      id: messageId,
      senderId: widget.userId,
      recipientId: widget.recipientId,
      publicationId: widget.publicationId,
      content: text,
      status: 'SENT',
      sentAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Provider.of<ChatProvider>(context, listen: false).sendMessage(message);

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scrollToBottom();
    });
  }

  // Get formatted date for message headers
  String getFormattedDate(BuildContext context, DateTime date) {
    final AppLocalizations? locale = AppLocalizations.of(context);
    if (locale == null) return "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    // Get current language from BLoC
    final languageState = context.watch<LanguageBloc>().state;
    String languageCode = 'en';

    if (languageState is LanguageLoaded) {
      languageCode = languageState.languageCode;
    }

    if (messageDate == today) {
      return locale.today;
    } else if (messageDate == yesterday) {
      return locale.yesterday;
    } else if (now.difference(messageDate).inDays < 7) {
      // Day name based on language
      switch (languageCode) {
        case 'uz':
          final weekdays = [
            locale.sunday,
            locale.monday,
            locale.tuesday,
            locale.wednesday,
            locale.thursday,
            locale.friday,
            locale.saturday,
          ];
          return weekdays[date.weekday % 7];

        case 'ru':
          final weekdays = [
            locale.sunday,
            locale.monday,
            locale.tuesday,
            locale.wednesday,
            locale.thursday,
            locale.friday,
            locale.saturday,
          ];
          return weekdays[date.weekday % 7];

        default:
          return DateFormat('EEEE', languageCode).format(date);
      }
    } else {
      // Format based on language
      switch (languageCode) {
        case 'uz':
          return DateFormat('d MMM, yyyy', 'uz').format(date);
        case 'ru':
          return DateFormat('d MMMM, yyyy', 'ru').format(date);
        default:
          return DateFormat('MMM d, yyyy', 'en').format(date);
      }
    }
  }

  // Format time string based on locale
  String getFormattedTime(BuildContext context, DateTime date) {
    final languageState = context.watch<LanguageBloc>().state;
    String languageCode = 'en';

    if (languageState is LanguageLoaded) {
      languageCode = languageState.languageCode;
    }

    // Format according to language
    switch (languageCode) {
      case 'ru':
        return DateFormat('HH:mm').format(date);
      case 'uz':
        return DateFormat('HH:mm').format(date);
      default:
        return DateFormat('h:mm a').format(date);
    }
  }

  // Build message input area
  Widget _buildMessageInput() {
    final locale = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.paperclip,
              size: 22,
            ),
            onPressed: () {
              // Attachment functionality
            },
          ),
          Expanded(
            child: SmoothClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CupertinoTextField(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.all(12),
                controller: _messageController,
                focusNode: _focusNode,
                minLines: 1,
                placeholder: locale.writeMessage,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // Text color set to black
                  fontFamily: Constants.Arial,
                ),
                placeholderStyle: TextStyle(
                  color: Colors.grey[400], // Placeholder color
                  fontFamily: Constants.Arial,
                ),
                maxLines: 5,
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
    );
  }

  // Build publication banner
  Widget _buildPublicationBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.6),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Publication image
          SmoothClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: CachedNetworkImage(
                imageUrl: widget.publicationImagePath.startsWith('http')
                    ? widget.publicationImagePath
                    : 'https://${widget.publicationImagePath}',
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Publication details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.publicationTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        shadowColor: AppColors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
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
                    overflow: TextOverflow.ellipsis,
                  ),
                  Consumer<ChatProvider>(
                    builder: (context, provider, child) {
                      final userStatus = provider
                              .historyState.userStatuses[widget.recipientId] ??
                          UserStatus.OFFLINE;
                      return Text(
                        userStatus == UserStatus.ONLINE
                            ? locale.online
                            : locale.offline,
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
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildPublicationBanner(),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  final state = provider.historyState;

                  if (state.isLoading) {
                    return const Progress();
                  } else if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: widget.publicationImagePath
                                        .startsWith('http')
                                    ? widget.publicationImagePath
                                    : 'https://${widget.publicationImagePath}',
                                fit: BoxFit.cover,
                                errorWidget: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            locale.interestedIn(widget.publicationTitle),
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locale.sendMessageToStart,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      reverse: true, // This is the key change
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        // For reversed list, index 0 is the newest message
                        final reversedIndex = state.messages.length - 1 - index;
                        final message = state.messages[reversedIndex];
                        final isMe = message.senderId == widget.userId;

                        // Date header logic
                        bool showDateHeader = false;
                        String dateHeader = '';

                        if (reversedIndex == 0) {
                          showDateHeader = true;
                          dateHeader =
                              getFormattedDate(context, message.sentAt);
                        } else {
                          // Check if date changed from the previous message
                          final prevMessage = state.messages[reversedIndex - 1];
                          final prevMessageDate = prevMessage.sentAt;
                          final messageDate = message.sentAt;

                          if (prevMessageDate.day != messageDate.day ||
                              prevMessageDate.month != messageDate.month ||
                              prevMessageDate.year != messageDate.year) {
                            showDateHeader = true;
                            dateHeader = getFormattedDate(context, messageDate);
                          }
                        }

                        // Message grouping logic for bubble tails
                        bool showTail = true;
                        final nextMessageIndex = reversedIndex + 1;
                        if (nextMessageIndex < state.messages.length) {
                          final nextMessage = state.messages[nextMessageIndex];
                          // Don't show tail if next message is from same sender and within 5 minutes
                          if (nextMessage.senderId == message.senderId &&
                              nextMessage.sentAt
                                      .difference(message.sentAt)
                                      .inMinutes <
                                  5) {
                            showTail = false;
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
                                    time: getFormattedTime(
                                        context, message.sentAt),
                                    status: message.status,
                                    showTail: showTail,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
