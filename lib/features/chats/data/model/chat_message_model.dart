// ignore_for_file: use_super_parameters
import 'package:list_in/features/chats/domain/entity/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required String id,
    required String senderId,
    required String recipientId,
    required String publicationId,
    required String content,
    required String status,
    required DateTime sentAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          senderId: senderId,
          recipientId: recipientId,
          publicationId: publicationId,
          content: content,
          status: status,
          sentAt: sentAt,
          updatedAt: updatedAt,
        );

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // Add null checks for all fields
    final String id = json['id'] ?? '';
    final String senderId = json['senderId'] ?? '';
    final String recipientId = json['recipientId'] ?? '';
    final String publicationId = json['publicationId'] ?? '';
    final String content = json['content'] ?? '';
    final String status = json['status'] ?? 'UNKNOWN';

    // Handle date parsing with null safety
    DateTime sentAt;
    try {
      sentAt = json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : DateTime.now();
    } catch (e) {
      sentAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now();
    } catch (e) {
      updatedAt = DateTime.now();
    }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'senderId': senderId,
      'recipientId': recipientId,
      'publicationId': publicationId,
      'content': content,
      'status': status,
      'sentAt': sentAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
