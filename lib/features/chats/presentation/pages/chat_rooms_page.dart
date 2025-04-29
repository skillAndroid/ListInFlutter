import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:list_in/config/theme/app_colors.dart';
import 'package:list_in/core/router/routes.dart';
import 'package:list_in/core/utils/const.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/presentation/provider/chats/chat_bloc.dart';
import 'package:list_in/features/explore/presentation/widgets/formaters.dart';
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

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 2, vsync: this);

    // Initialize the chat system
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.initializeChat(widget.userId);

    // Load chat rooms
    if (chatProvider.roomsState.chatRooms.isEmpty) {
      chatProvider.loadChatRooms(widget.userId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  labelColor: Colors.black,
                  indicatorPadding: EdgeInsets.zero,
                  labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  tabAlignment: TabAlignment.center,
                  indicatorWeight: 0.1,
                  isScrollable: true,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  tabs: const [
                    Tab(text: 'Chats'),
                    Tab(text: 'In Box'),
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
              // Separate chat rooms into two lists
              final toYouRooms = state.chatRooms
                  .where((room) => room.recipientId == widget.userId)
                  .toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  // "To You" tab
                  _buildChatRoomsList(state.chatRooms, chatProvider),

                  // "Your Messages" tab
                  _buildChatRoomsList(toYouRooms, chatProvider),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildChatRoomsList(List<ChatRoom> rooms, ChatProvider chatProvider) {
    if (rooms.isEmpty) {
      return const Center(
        child: Text('No messages yet'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        chatProvider.loadChatRooms(widget.userId);
        return Future.delayed(const Duration(milliseconds: 1000));
      },
      child: ListView.builder(
        itemCount: rooms.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final chatRoom = rooms[index];
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
                    // Modified Stack for publication image with user avatar
                    Container(
                      // Adding padding to make space for the avatar overflow
                      margin: const EdgeInsets.only(right: 10, top: 10),
                      child: Stack(
                        clipBehavior: Clip.none, // Allow overflow
                        children: [
                          SmoothClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://${chatRoom.publicationImagePath}",
                              width: 50,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // User avatar positioned with positive offset
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  "https://${chatRoom.recipientImagePath}",
                                ),
                                onBackgroundImageError:
                                    (exception, stackTrace) {
                                  // Handle image loading errors
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            chatRoom.publicationTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          // Price
                          Text(
                            formatPrice(chatRoom.publicationPrice.toString()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Last message with sender indication
                          Row(
                            children: [
                              Expanded(
                                  child: RichText(
                                text: TextSpan(
                                  children: chatRoom.lastMessage == null
                                      ? [
                                          TextSpan(
                                            text: 'No messages yet',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ]
                                      : chatRoom.lastMessage!.senderId ==
                                              widget.userId
                                          ? [
                                              TextSpan(
                                                text: 'You: ',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        Constants.Arial),
                                              ),
                                              TextSpan(
                                                text: chatRoom
                                                    .lastMessage!.content,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontFamily: Constants.Arial,
                                                ),
                                              ),
                                            ]
                                          : [
                                              TextSpan(
                                                text: chatRoom
                                                    .lastMessage!.content,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                  fontFamily: Constants.Arial,
                                                ),
                                              ),
                                            ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              if (chatRoom.lastMessage != null)
                                Text(
                                  DateFormat('hh:mm a')
                                      .format(chatRoom.lastMessage!.sentAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
