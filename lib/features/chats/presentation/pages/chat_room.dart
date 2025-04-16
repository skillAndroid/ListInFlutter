import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/chats/data/model/chat_message.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_bloc.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_event.dart';
import 'package:list_in/features/chats/presentation/bloc/chat_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Join the room and load initial messages
    context.read<ChatBloc>().add(ChatJoinRoomEvent(roomId: widget.roomId));
    context
        .read<ChatBloc>()
        .add(ChatLoadMessagesEvent(roomId: widget.roomId, limit: 20));

    // Set up scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading) {
      final state = context.read<ChatBloc>().state;
      if (state is ChatMessagesLoadedState && state.hasMore) {
        setState(() {
          _isLoading = true;
        });

        // Load older messages
        final lastMessageId =
            state.messages.isNotEmpty ? state.messages.last.id : null;
        context.read<ChatBloc>().add(ChatLoadMessagesEvent(
              roomId: widget.roomId,
              limit: 20,
              lastMessageId: lastMessageId,
            ));
      }
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(ChatSendMessageEvent(
            roomId: widget.roomId,
            content: message,
          ));
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatMessagesLoadedState) {
            setState(() {
              _isLoading = false;
            });

            // Scroll to bottom on initial load
            if (state.messages.isNotEmpty &&
                _scrollController.hasClients &&
                _scrollController.position.pixels == 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.jumpTo(0);
              });
            }
          } else if (state is ChatErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoadingMessagesState &&
              _scrollController.position.pixels == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatMessagesLoadedState) {
            final messages = state.messages;

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text('No messages yet'))
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Newest messages at the bottom
                          itemCount: messages.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == messages.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final message = messages[index];
                            final isMe = message.senderId ==
                                'currentUserId'; // Replace with your user ID

                            return MessageBubble(
                              message: message,
                              isMe: isMe,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Today, show only time
      return '${_padZero(timestamp.hour)}:${_padZero(timestamp.minute)}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday, ${_padZero(timestamp.hour)}:${_padZero(timestamp.minute)}';
    } else {
      // Other days
      return '${_padZero(timestamp.day)}/${_padZero(timestamp.month)}/${timestamp.year} ${_padZero(timestamp.hour)}:${_padZero(timestamp.minute)}';
    }
  }

  String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }
}
