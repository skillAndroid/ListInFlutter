import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/language/language_bloc.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_provider.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
import 'package:list_in/features/explore/presentation/widgets/progress.dart';
import 'package:provider/provider.dart';
import 'package:smooth_corner_updated/smooth_corner.dart';

class ChatRoomsPage extends StatefulWidget {
  final String userId;

  const ChatRoomsPage({
    super.key,
    required this.userId,
  });

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // Initialize chat system - do this after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Connect to chat system
    await chatProvider.initializeChat(widget.userId);

    // Load chat rooms
    await chatProvider.loadChatRooms(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

// Modified: Build chat details with SAME UI regardless of unread status
  Widget _buildChatDetails(ChatRoom chatRoom, AppLocalizations locale) {
    return Expanded(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top row: publication title and time/unread indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publication title - ALWAYS SAME STYLE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          chatRoom.publicationTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w500, // Always same weight
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              // Publication price
              Text(
                formatPrice(chatRoom.publicationPrice.toString()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 2),

              _buildLastMessageIndicator(chatRoom, locale),
            ],
          ),
          // Time and unread count
          if (chatRoom.lastMessage != null)
            Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: _buildTimeAndUnreadCount(chatRoom, locale)),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 8, // Reduced height to minimize space at top
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: TabBar(
                  dividerColor: AppColors.transparent,
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.secondary,
                  indicatorPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  tabAlignment: TabAlignment.center,
                  indicatorWeight: 0.1,
                  isScrollable: true,
                  unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                  indicatorColor: Theme.of(context).colorScheme.secondary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: [
                    Tab(text: locale.chats),
                    Tab(text: locale.inbox),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final state = chatProvider.roomsState;

            if (state.isLoading) {
              return const Progress();
            } else if (state.chatRooms.isEmpty) {
              return _buildEmptyState(locale);
            } else {
              // Separate chat rooms into two lists - all chats and only inbox
              // Inbox = messages sent to the user (where user is recipient)
              final inboxRooms = state.chatRooms
                  .where((room) => room.recipientId == widget.userId)
                  .toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  // "All Chats" tab
                  _buildChatRoomsList(state.chatRooms, chatProvider),

                  // "Inbox" tab (messages to the user)
                  _buildChatRoomsList(inboxRooms, chatProvider),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Empty state when no messages
  Widget _buildEmptyState(AppLocalizations locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            locale.noMessagesYet,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locale.yourConversationsWillAppearHere,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Build the list of chat rooms
  Widget _buildChatRoomsList(List<ChatRoom> rooms, ChatProvider chatProvider) {
    final locale = AppLocalizations.of(context)!;

    if (rooms.isEmpty) {
      return Center(
        child: Text(
          locale.noMessagesYet,
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () async {
        await chatProvider.loadChatRooms(widget.userId);
        return;
      },
      child: ListView.builder(
        itemCount: rooms.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final chatRoom = rooms[index];
          return _buildChatRoomItem(chatRoom, locale);
        },
      ),
    );
  }

  // Build an individual chat room item
  // Modified: Build an individual chat room item
  Widget _buildChatRoomItem(ChatRoom chatRoom, AppLocalizations locale) {
    return Card(
      color: AppColors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      elevation: 0,
      shape: SmoothRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to chat detail page
          context.push(
            Routes.room,
            extra: {
              'userId': widget.userId,
              'publicationId': chatRoom.publicationId,
              'recipientId': chatRoom.recipientId,
              'publicationTitle': chatRoom.publicationTitle,
              'recipientName': chatRoom.recipientNickname,
              'publicationImagePath': chatRoom.publicationImagePath,
              'userProfileImage': chatRoom.recipientImagePath,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Publication image with user avatar
              _buildChatRoomAvatar(chatRoom),

              const SizedBox(width: 8),

              // Chat details (now using the new method)
              _buildChatDetails(chatRoom, locale),
            ],
          ),
        ),
      ),
    );
  }

  // Build publication image with user avatar overlay
  Widget _buildChatRoomAvatar(ChatRoom chatRoom) {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Publication image
          SmoothClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: "https://${chatRoom.publicationImagePath}",
              width: 50,
              height: 60,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                width: 50,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 20),
              ),
            ),
          ),

          // User avatar overlay
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(
                  "https://${chatRoom.recipientImagePath}",
                ),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle image loading error
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAndUnreadCount(ChatRoom chatRoom, AppLocalizations locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time at top
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            getFormattedTime(context, chatRoom.lastMessage!.sentAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ),

        // Unread count badge at bottom right
        if (chatRoom.unreadMessages > 0)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Text(
              chatRoom.unreadMessages > 9
                  ? '9+'
                  : chatRoom.unreadMessages.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

// Build last message preview with status indicators
  Widget _buildLastMessageIndicator(
      ChatRoom chatRoom, AppLocalizations locale) {
    if (chatRoom.lastMessage == null) {
      return Text(
        locale.noMessagesYet,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      );
    }

    // Message sent by current user
    if (chatRoom.lastMessage!.senderId == widget.userId) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${locale.you}: ',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: Constants.Arial,
              ),
            ),
            TextSpan(
              text: chatRoom.lastMessage!.content,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontFamily: Constants.Arial,
              ),
            ),
            // Status indicators
            _getMessageStatusIndicator(chatRoom.lastMessage!.status),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    // Message received from other user - SAME UI REGARDLESS OF UNREAD STATUS
    else {
      return Text(
        chatRoom.lastMessage!.content,
        style: TextStyle(
          color: Colors.grey[600], // Always same color
          fontSize: 12,
          fontWeight: FontWeight.normal, // Always same weight
          fontFamily: Constants.Arial,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  // Get the appropriate message status indicator
  TextSpan _getMessageStatusIndicator(String status) {
    switch (status) {
      case 'VIEWED':
        return const TextSpan(
          text: ' ✓✓',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: Constants.Arial,
          ),
        );
      case 'DELIVERED':
        return const TextSpan(
          text: ' ✓',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: Constants.Arial,
          ),
        );
      case 'SENT':
        return const TextSpan(
          text: ' 🕔',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: Constants.Arial,
          ),
        );
      case 'SENDING':
        return const TextSpan(
          text: ' ⌛',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontFamily: Constants.Arial,
          ),
        );
      case 'ERROR':
        return const TextSpan(
          text: ' ⚠️',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontFamily: Constants.Arial,
          ),
        );
      default:
        return const TextSpan(text: '');
    }
  }
}
