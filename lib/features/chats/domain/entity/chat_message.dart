import 'package:list_in/features/chats/data/model/chat_message_model.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String publicationId;
  final String content;
  final String status;
  final DateTime sentAt;
  final DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.publicationId,
    required this.content,
    required this.status,
    required this.sentAt,
    required this.updatedAt,
  });
  ChatMessageModel toModel() {
    return ChatMessageModel(
      id: id,
      senderId: senderId,
      recipientId: recipientId,
      publicationId: publicationId,
      content: content,
      status: status,
      sentAt: sentAt,
      updatedAt: updatedAt,
    );
  }
}
