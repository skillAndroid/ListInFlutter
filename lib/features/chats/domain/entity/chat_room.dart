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

  ChatRoom({
    required this.chatRoomId,
    required this.publicationId,
    required this.publicationImagePath,
    required this.publicationTitle,
    required this.publicationPrice,
    required this.recipientId,
    required this.recipientImagePath,
    required this.recipientNickname,
    this.lastMessage,
  });
}
