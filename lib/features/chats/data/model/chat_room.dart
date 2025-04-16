class ChatRoom {
  final String id;
  final String name;
  final List<String> participants;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      participants: List<String>.from(json['participants']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participants': participants,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
