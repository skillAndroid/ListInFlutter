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
import 'package:list_in/features/chats/presentation/provider/chats/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/widgets/message_bubble.dart';
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
  bool _isFirstLoad = true;
  bool _userScrolledUp = false;
  double _previousMaxScrollExtent = 0;
  double _keyboardHeight = 0;
  late FocusNode _focusNode;
  final Set<String> _processedMessageIds = {};
  final Uuid _uuid = Uuid();
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Add a listener to detect when user has manually scrolled up
    _scrollController.addListener(_scrollListener);

    // Load chat history when page initializes
    Provider.of<ChatProvider>(context, listen: false).loadChatHistory(
      publicationId: widget.publicationId,
      senderId: widget.userId,
      recipientId: widget.recipientId,
    );

    // Add listener to keyboard visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).addListener(() {
        if (!_userScrolledUp) {
          _scrollToBottomWithoutAnimation();
        }
      });
      _focusNode.addListener(_onFocusChange);
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Keyboard is appearing - schedule a scroll after keyboard appears
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_userScrolledUp) {
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Save previous scroll extent for comparison
      _previousMaxScrollExtent = _scrollController.position.maxScrollExtent;

      // Check if user has scrolled up
      final isAtBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 50;
      setState(() {
        _userScrolledUp = !isAtBottom;
      });
    }
  }

  // Improved scroll function with animation
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // Non-animated scroll function (for keyboard appearance)
  void _scrollToBottomWithoutAnimation() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Method to keep scroll position stable when text field expands
  void _maintainScrollPosition() {
    if (_scrollController.hasClients) {
      final currentPosition = _scrollController.offset;
      final diff =
          _scrollController.position.maxScrollExtent - _previousMaxScrollExtent;

      if (diff > 0 && !_userScrolledUp) {
        // If content grew and user is at bottom, scroll to new bottom
        _scrollController.jumpTo(currentPosition + diff);
      }
      _previousMaxScrollExtent = _scrollController.position.maxScrollExtent;
    }
  }

  // 3. Update the _sendMessage method to generate UUID at the UI level
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      // Generate UUID for the message
      final messageId = _uuid.v4();

      // Create the message with the generated UUID
      final message = ChatMessage(
        id: messageId, // Include the generated UUID
        senderId: widget.userId,
        recipientId: widget.recipientId,
        publicationId: widget.publicationId,
        content: _messageController.text,
        status: 'SENT',
        sentAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Send the message with ID through the provider
      Provider.of<ChatProvider>(context, listen: false).sendMessage(message);

      // Clear the input field
      _messageController.clear();

      // Reset user scrolled state when sending a message
      setState(() {
        _userScrolledUp = false;
      });

      // Scroll to the bottom after a short delay
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  // Helper function to get formatted date string with multilingual support
  String getFormattedDate(BuildContext context, DateTime date) {
    final AppLocalizations? locale = AppLocalizations.of(context);
    if (locale == null) return ""; // Safety check

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    // Get current language from BLoC
    final languageState = context.watch<LanguageBloc>().state;
    String languageCode = 'en'; // Default to English

    if (languageState is LanguageLoaded) {
      languageCode = languageState.languageCode;
    }

    if (messageDate == today) {
      return locale.today; // "Today" in current language
    } else if (messageDate == yesterday) {
      return locale.yesterday; // "Yesterday" in current language
    } else if (now.difference(messageDate).inDays < 7) {
      // Day name based on language
      switch (languageCode) {
        case 'uz':
          // Uzbek weekday names
          final weekdays = [
            locale.sunday, // "Yakshanba"
            locale.monday, // "Dushanba"
            locale.tuesday, // "Seshanba"
            locale.wednesday, // "Chorshanba"
            locale.thursday, // "Payshanba"
            locale.friday, // "Juma"
            locale.saturday, // "Shanba"
          ];
          return weekdays[date.weekday % 7]; // weekday is 1-7, array is 0-6

        case 'ru':
          // Russian weekday names
          final weekdays = [
            locale.sunday, // "Воскресенье"
            locale.monday, // "Понедельник"
            locale.tuesday, // "Вторник"
            locale.wednesday, // "Среда"
            locale.thursday, // "Четверг"
            locale.friday, // "Пятница"
            locale.saturday, // "Суббота"
          ];
          return weekdays[date.weekday % 7];

        default:
          // English or any other language using DateFormat
          // This will use the system locale, but we can override it
          return DateFormat('EEEE', languageCode).format(date);
      }
    } else {
      // Format the date according to language convention
      switch (languageCode) {
        case 'uz':
          // Uzbek date format: 15 Mart, 2025
          return DateFormat('d MMM, yyyy', 'uz').format(date);

        case 'ru':
          // Russian date format: 15 марта, 2025
          return DateFormat('d MMMM, yyyy', 'ru').format(date);

        default:
          // English date format: Mar 15, 2025
          return DateFormat('MMM d, yyyy', 'en').format(date);
      }
    }
  }

  // Format time string based on locale
  String getFormattedTime(BuildContext context, DateTime date) {
    final languageState = context.watch<LanguageBloc>().state;
    String languageCode = 'en'; // Default to English

    if (languageState is LanguageLoaded) {
      languageCode = languageState.languageCode;
    }

    // Format time according to language conventions
    switch (languageCode) {
      case 'ru':
        // Russian time format (24-hour)
        return DateFormat('HH:mm').format(date);

      case 'uz':
        // Uzbek time format (can be adjusted as needed)
        return DateFormat('HH:mm').format(date);

      default:
        // English (12-hour with AM/PM)
        return DateFormat('h:mm a').format(date);
    }
  }

  // Modified build method for message input
  Widget _buildMessageInput() {
    final AppLocalizations locale = AppLocalizations.of(context)!;

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
              // Would implement attachment functionality
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
                style: const TextStyle(fontFamily: Constants.Arial),
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  // Maintain scroll position when text field expands
                  if (text.contains('\n')) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _maintainScrollPosition();
                    });
                  }
                },
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;

    // Calculate available height with MediaQuery to adjust for keyboard
    final viewInsets = MediaQuery.of(context).viewInsets;
    final keyboardHeight = viewInsets.bottom;

    // Detect keyboard height changes
    if (_keyboardHeight != keyboardHeight) {
      _keyboardHeight = keyboardHeight;
      // If keyboard appears and user isn't scrolled up, scroll to bottom
      if (keyboardHeight > 0 && !_userScrolledUp) {
        // Use a slight delay to ensure the layout is updated first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        shadowColor: AppColors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        flexibleSpace: Card(
          shadowColor: Theme.of(context).cardColor.withOpacity(0.2),
          margin: EdgeInsets.zero,
          elevation: 1, // Shadow for the card
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
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
                    IconButton(
                      icon: const Icon(Icons.more_vert),
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
                            locale.interestedIn(widget.publicationTitle),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locale.sendMessageToStart,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (_isFirstLoad && state.messages.isNotEmpty) {
                      _isFirstLoad = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                        _markUnreadMessagesAsViewed(provider, state.messages);
                      });
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollEndNotification) {
                          // Update user scroll state when scrolling ends
                          if (_scrollController.hasClients) {
                            final isAtBottom = _scrollController.offset >=
                                _scrollController.position.maxScrollExtent - 50;
                            setState(() {
                              _userScrolledUp = !isAtBottom;
                            });
                          }
                        }
                        return false;
                      },
                      child: KeyboardDismissOnTap(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          // Add physics to improve scrolling behavior
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == widget.userId;

                            // Process any unread received messages
                            if (!isMe &&
                                message.id != null &&
                                message.status != 'VIEWED' &&
                                !_processedMessageIds.contains(message.id)) {
                              _processedMessageIds.add(message.id!);
                              // Schedule marking as viewed (outside of build method)
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _markMessageAsViewed(provider, message);
                              });
                            }
                            // Date header logic
                            bool showDateHeader = false;
                            String dateHeader = '';

                            if (index == 0) {
                              // First message always shows date
                              showDateHeader = true;
                              dateHeader =
                                  getFormattedDate(context, message.sentAt);
                            } else {
                              // Check if date changed from previous message
                              final previousMessageDate =
                                  state.messages[index - 1].sentAt;
                              final messageDate = message.sentAt;

                              if (previousMessageDate.day != messageDate.day ||
                                  previousMessageDate.month !=
                                      messageDate.month ||
                                  previousMessageDate.year !=
                                      messageDate.year) {
                                showDateHeader = true;
                                dateHeader =
                                    getFormattedDate(context, messageDate);
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                          context,
                                          message.sentAt,
                                        ),
                                        status: message.status,
                                        showTail: showAvatar,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                            );
                          },
                        ),
                      ),
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

  // Add a new method to mark unread messages as viewed
  void _markUnreadMessagesAsViewed(
      ChatProvider provider, List<ChatMessage> messages) {
    // Collect all unread messages not sent by the current user
    final unreadMessages = messages
        .where((msg) =>
            msg.id != null &&
            msg.senderId != widget.userId &&
            msg.status != 'VIEWED' &&
            !_processedMessageIds.contains(msg.id))
        .toList();

    if (unreadMessages.isEmpty) return;

    // Mark messages as processed in our local tracking
    for (final message in unreadMessages) {
      if (message.id != null) {
        _processedMessageIds.add(message.id!);
      }
    }

    // Collect message IDs for the viewed status update
    final messageIds = unreadMessages
        .where((msg) => msg.id != null)
        .map((msg) => msg.id!)
        .toList();

    if (messageIds.isNotEmpty) {
      // Send the viewed status to the provider
      provider.sendMessageViewedStatus(widget.recipientId, messageIds);
    }
  }

  // Method to mark a single message as viewed
  void _markMessageAsViewed(ChatProvider provider, ChatMessage message) {
    if (message.id == null || message.senderId == widget.userId) return;

    // Send the viewed status for this message
    provider.sendMessageViewedStatus(widget.recipientId, [message.id!]);
  }

  // New method to build a publication banner/card
  Widget _buildPublicationBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Publication image
          SmoothClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 50,
              height: 50,
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
                // Title
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

                // Normally we'd have price here, add it from ChatRoom if available
                // For now, placeholder text
                Text(
                  "View Details",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // View details button
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              // Show publication details (using the existing modal)
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 180,
                        child: SmoothClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl:
                                widget.publicationImagePath.startsWith('http')
                                    ? widget.publicationImagePath
                                    : 'https://${widget.publicationImagePath}',
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.publicationTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text("View details"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper widget to dismiss keyboard when tapping on the chat list
class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;

  const KeyboardDismissOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
