import 'package:equatable/equatable.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatInitialized extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> chatRooms;

  ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object?> get props => [chatRooms];
}

class ChatHistoryLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String publicationId;
  final String recipientId;
  final Map<String, UserStatus> userStatuses;

  ChatHistoryLoaded({
    required this.messages,
    required this.publicationId,
    required this.recipientId,
    required this.userStatuses,
  });

  ChatHistoryLoaded copyWith({
    List<ChatMessage>? messages,
    String? publicationId,
    String? recipientId,
    Map<String, UserStatus>? userStatuses,
  }) {
    return ChatHistoryLoaded(
      messages: messages ?? this.messages,
      publicationId: publicationId ?? this.publicationId,
      recipientId: recipientId ?? this.recipientId,
      userStatuses: userStatuses ?? this.userStatuses,
    );
  }

  @override
  List<Object?> get props =>
      [messages, publicationId, recipientId, userStatuses];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSent extends ChatState {
  final ChatMessage message;

  MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}
