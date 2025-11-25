enum MessageType { user, bot, service }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final List<dynamic>? services;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.services,
    this.isTyping = false,
  });
}