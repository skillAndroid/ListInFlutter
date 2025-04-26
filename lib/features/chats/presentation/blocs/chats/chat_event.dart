import 'package:equatable/equatable.dart';
import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeChatEvent extends ChatEvent {
  final String userId;

  InitializeChatEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ConnectUserEvent extends ChatEvent {
  final UserConnectionInfo userInfo;

  ConnectUserEvent(this.userInfo);

  @override
  List<Object?> get props => [userInfo];
}

class DisconnectUserEvent extends ChatEvent {
  final UserConnectionInfo userInfo;

  DisconnectUserEvent(this.userInfo);

  @override
  List<Object?> get props => [userInfo];
}

class LoadChatRoomsEvent extends ChatEvent {
  final String userId;

  LoadChatRoomsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadChatHistoryEvent extends ChatEvent {
  final String publicationId;
  final String senderId;
  final String recipientId;

  LoadChatHistoryEvent({
    required this.publicationId,
    required this.senderId,
    required this.recipientId,
  });

  @override
  List<Object?> get props => [publicationId, senderId, recipientId];
}

class SendMessageEvent extends ChatEvent {
  final ChatMessage message;

  SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceivedEvent extends ChatEvent {
  final ChatMessage message;

  MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class UserStatusUpdatedEvent extends ChatEvent {
  final UserConnectionInfo userStatus;

  UserStatusUpdatedEvent(this.userStatus);

  @override
  List<Object?> get props => [userStatus];
}
