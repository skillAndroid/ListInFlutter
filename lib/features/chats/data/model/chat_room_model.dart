// ignore_for_file: use_super_parameters

import 'package:list_in/features/chats/data/model/chat_message_model.dart';
import 'package:list_in/features/chats/domain/entity/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  ChatRoomModel({
    required String chatRoomId,
    required String publicationId,
    required String publicationImagePath,
    required String publicationTitle,
    required double publicationPrice,
    required String recipientId,
    required String recipientImagePath,
    required String recipientNickname,
    ChatMessageModel? lastMessage,
  }) : super(
          chatRoomId: chatRoomId,
          publicationId: publicationId,
          publicationImagePath: publicationImagePath,
          publicationTitle: publicationTitle,
          publicationPrice: publicationPrice,
          recipientId: recipientId,
          recipientImagePath: recipientImagePath,
          recipientNickname: recipientNickname,
          lastMessage: lastMessage,
        );

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomId: json['chatRoomId'],
      publicationId: json['publicationId'],
      publicationImagePath: json['publicationImagePath'],
      publicationTitle: json['publicationTitle'],
      publicationPrice: json['publicationPrice'],
      recipientId: json['recipientId'],
      recipientImagePath: json['recipientImagePath'] ?? '',
      recipientNickname: json['recipientNickname'],
      lastMessage: json['lastMessage'] != null
          ? ChatMessageModel.fromJson(json['lastMessage'])
          : null,
    );
  }
}
