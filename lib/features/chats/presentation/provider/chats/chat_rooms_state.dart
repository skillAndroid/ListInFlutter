// ignore_for_file: avoid_print

import 'package:list_in/features/chats/domain/entity/chat_room.dart';

/// State for chat rooms list
class ChatRoomsState {
  final bool isLoading;
  final List<ChatRoom> chatRooms;
  final String? errorMessage;

  const ChatRoomsState({
    this.isLoading = false,
    this.chatRooms = const [],
    this.errorMessage,
  });

  ChatRoomsState copyWith({
    bool? isLoading,
    List<ChatRoom>? chatRooms,
    String? errorMessage,
  }) {
    return ChatRoomsState(
      isLoading: isLoading ?? this.isLoading,
      chatRooms: chatRooms ?? this.chatRooms,
      errorMessage: errorMessage,
    );
  }
}
