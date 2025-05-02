// ignore_for_file: avoid_print

import 'package:list_in/features/chats/domain/entity/chat_message.dart';
import 'package:list_in/features/chats/domain/entity/user_status.dart';

/// State for chat history/conversation
class ChatHistoryState {
  final bool isLoading;
  final String publicationId;
  final String recipientId;
  final List<ChatMessage> messages;
  final Map<String, UserStatus> userStatuses;
  final String? errorMessage;

  const ChatHistoryState({
    this.isLoading = false,
    this.publicationId = '',
    this.recipientId = '',
    this.messages = const [],
    this.userStatuses = const {},
    this.errorMessage,
  });

  ChatHistoryState copyWith({
    bool? isLoading,
    String? publicationId,
    String? recipientId,
    List<ChatMessage>? messages,
    Map<String, UserStatus>? userStatuses,
    String? errorMessage,
  }) {
    return ChatHistoryState(
      isLoading: isLoading ?? this.isLoading,
      publicationId: publicationId ?? this.publicationId,
      recipientId: recipientId ?? this.recipientId,
      messages: messages ?? this.messages,
      userStatuses: userStatuses ?? this.userStatuses,
      errorMessage: errorMessage,
    );
  }
}
