import 'package:list_in/features/chats/domain/entity/chat_message.dart';

class ChatRoom {
  final String chatRoomId;
  final String publicationId;
  final String publicationImagePath;
  final String publicationTitle;
  final double publicationPrice;
  final String recipientId;
  final String recipientImagePath;
  final String recipientNickname;
  final ChatMessage? lastMessage;
  final int unreadMessages;

  ChatRoom({
    required this.chatRoomId,
    required this.publicationId,
    required this.publicationImagePath,
    required this.publicationTitle,
    required this.publicationPrice,
    required this.recipientId,
    required this.recipientImagePath,
    required this.recipientNickname,
    required this.unreadMessages,
    this.lastMessage,
  });
  ChatRoom copyWith({
    String? chatRoomId,
    String? publicationId,
    String? publicationImagePath,
    String? publicationTitle,
    double? publicationPrice,
    String? recipientId,
    String? recipientImagePath,
    String? recipientNickname,
    int? unreadMessages,
    ChatMessage? lastMessage,
  }) {
    return ChatRoom(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      publicationId: publicationId ?? this.publicationId,
      publicationImagePath: publicationImagePath ?? this.publicationImagePath,
      publicationTitle: publicationTitle ?? this.publicationTitle,
      publicationPrice: publicationPrice ?? this.publicationPrice,
      recipientId: recipientId ?? this.recipientId,
      recipientImagePath: recipientImagePath ?? this.recipientImagePath,
      recipientNickname: recipientNickname ?? this.recipientNickname,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
