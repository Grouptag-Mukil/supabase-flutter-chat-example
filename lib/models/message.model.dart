class Message {
  int id;
  String senderId;
  int conversationId;
  String content;
  String? parentMessageId;
  DateTime createdAt;
  bool isMine;

  Message({
    required this.id,
    required this.senderId,
    required this.conversationId,
    required this.content,
    this.parentMessageId,
    required this.createdAt,
    required this.isMine
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['message_id'],
    senderId: json['sender_id'],
    conversationId: json['conversation_id'],
    content: json['content'],
    parentMessageId: json['parent_message_id'],
    createdAt: DateTime.parse(json['created_at']),
    isMine: json['sender_id'] == json['currentUser'],
  );

  Message.fromMap({
    required Map<String, dynamic> map,
    required String currentUser,
  }) :  id = map['id'],
        senderId = map['sender_id'],
        conversationId = map['conversation_id'],
        content = map['content'],
        parentMessageId = map['parent_message_id'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = currentUser == map['sender_id'];

  Map<String, dynamic> toJson() => {
    'message_id': id,
    'sender_id': senderId,
    'conversation_id': conversationId,
    'content': content,
    'parent_message_id': parentMessageId,
    'created_at': createdAt.toIso8601String(),
    'isMine': isMine,
  };
}
