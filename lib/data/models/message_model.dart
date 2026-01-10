/// Chat message model
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final MessageType type;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.type = MessageType.text,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

/// Message type enum
enum MessageType {
  text,
  image,
  system,
}

/// Chat conversation model
class ConversationModel {
  final String id;
  final String recipientId;
  final String recipientName;
  final String recipientAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      recipientName: json['recipientName'] ?? '',
      recipientAvatar: json['recipientAvatar'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: DateTime.tryParse(json['lastMessageTime'] ?? '') ?? DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
