class ChatMessage {
  String conversationId;
  String content;

  ChatMessage({
    required this.conversationId,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      conversationId: json['id'],
      content: json['content'],
    );
  }

  @override
  String toString() {
    return 'ChatMessage: conversationId=$conversationId content=$content';
  }
}
