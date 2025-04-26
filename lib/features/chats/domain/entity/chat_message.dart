class ChatMessage {
  final String? id;
  final String senderId;
  final String recipientId;
  final String publicationId;
  final String content;
  final String status;
  final DateTime sentAt;
  final DateTime updatedAt;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.recipientId,
    required this.publicationId,
    required this.content,
    required this.status,
    required this.sentAt,
    required this.updatedAt,
  });
}
