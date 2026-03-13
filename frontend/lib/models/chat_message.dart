class ChatMessage {
  final String id;
  final String eventId;
  final String userId;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

