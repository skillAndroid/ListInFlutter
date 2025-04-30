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
    return ChatMessageModel(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      publicationId: json['publicationId'],
      content: json['content'],
      status: json['status'],
      sentAt: DateTime.parse(json['sentAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'publicationId': publicationId,
      'content': content,
    };
  }
}
