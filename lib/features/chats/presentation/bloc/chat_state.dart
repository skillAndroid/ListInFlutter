import 'package:equatable/equatable.dart';
import 'package:list_in/features/chats/data/model/chat_message.dart';
import 'package:list_in/features/chats/data/model/chat_room.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitialState extends ChatState {}

class ChatConnectingState extends ChatState {}

class ChatConnectedState extends ChatState {}

class ChatDisconnectedState extends ChatState {}

class ChatLoadingRoomsState extends ChatState {}

class ChatRoomsLoadedState extends ChatState {
  final List<ChatRoom> rooms;

  ChatRoomsLoadedState({required this.rooms});

  @override
  List<Object?> get props => [rooms];
}

class ChatLoadingMessagesState extends ChatState {
  final String roomId;

  ChatLoadingMessagesState({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ChatMessagesLoadedState extends ChatState {
  final String roomId;
  final List<ChatMessage> messages;
  final bool hasMore;

  ChatMessagesLoadedState({
    required this.roomId,
    required this.messages,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [roomId, messages, hasMore];
}

class ChatSendingMessageState extends ChatState {
  final String roomId;

  ChatSendingMessageState({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ChatMessageSentState extends ChatState {
  final String roomId;

  ChatMessageSentState({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ChatErrorState extends ChatState {
  final String error;

  ChatErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class ChatCreatingRoomState extends ChatState {}

class ChatRoomCreatedState extends ChatState {
  final ChatRoom room;

  ChatRoomCreatedState({required this.room});

  @override
  List<Object?> get props => [room];
}
