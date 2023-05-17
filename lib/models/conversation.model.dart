class Conversation {
  int id;
  bool isGroup;
  String? name;
  List<String> members;

  Conversation({
    required this.id,
    required this.isGroup,
    this.name,
    required this.members,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    isGroup: json['is_group'],
    name: json['name'] ?? '',
    members: List<String>.from(json['members']),
  );

  Map<String, dynamic> toJson() => {
    'conversation_id': id,
    'is_group': isGroup,
    'name': name,
    'members': members,
  };
}