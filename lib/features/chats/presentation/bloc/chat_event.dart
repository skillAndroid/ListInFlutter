import 'package:list_in/features/chats/data/model/chat_message.dart';
import 'package:list_in/features/chats/data/model/chat_room.dart';

abstract class ChatEvent {}

class ChatConnectEvent extends ChatEvent {
  final String token;
  ChatConnectEvent({required this.token});
}

class ChatDisconnectEvent extends ChatEvent {}

class ChatLoadRoomsEvent extends ChatEvent {}

class ChatLoadMessagesEvent extends ChatEvent {
  final String roomId;
  final int? limit;
  final String? lastMessageId;

  ChatLoadMessagesEvent({
    required this.roomId,
    this.limit,
    this.lastMessageId,
  });
}

class ChatSendMessageEvent extends ChatEvent {
  final String roomId;
  final String content;

  ChatSendMessageEvent({
    required this.roomId,
    required this.content,
  });
}

class ChatCreateRoomEvent extends ChatEvent {
  final String name;
  final List<String> participants;

  ChatCreateRoomEvent({
    required this.name,
    required this.participants,
  });
}

class ChatJoinRoomEvent extends ChatEvent {
  final String roomId;
  ChatJoinRoomEvent({required this.roomId});
}

class ChatLeaveRoomEvent extends ChatEvent {
  final String roomId;
  ChatLeaveRoomEvent({required this.roomId});
}

class ChatNewMessageReceivedEvent extends ChatEvent {
  final ChatMessage message;
  ChatNewMessageReceivedEvent({required this.message});
}

class ChatRoomUpdatedEvent extends ChatEvent {
  final ChatRoom room;
  ChatRoomUpdatedEvent({required this.room});
}
