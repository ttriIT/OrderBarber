import '../models/message_model.dart';

/// Fake chat service for in-memory messaging
/// TODO: Replace with real-time messaging when backend is ready
class FakeChatService {
  // In-memory storage for messages
  final Map<String, List<MessageModel>> _conversations = {};

  /// Initialize with some mock messages
  FakeChatService() {
    _initMockMessages();
  }

  void _initMockMessages() {
    final now = DateTime.now();

    // Conversation between customer_1 and barber_1
    _conversations['customer_1_barber_1'] = [
      MessageModel(
        id: 'msg_1',
        senderId: 'barber_1',
        senderName: 'Phạm Minh Đức',
        receiverId: 'customer_1',
        content: 'Xin chào! Tôi có thể giúp gì cho bạn?',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_2',
        senderId: 'customer_1',
        senderName: 'Nguyễn Văn An',
        receiverId: 'barber_1',
        content: 'Chào anh! Tôi muốn hỏi về kiểu tóc Undercut.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 55)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_3',
        senderId: 'barber_1',
        senderName: 'Phạm Minh Đức',
        receiverId: 'customer_1',
        content: 'Undercut là kiểu tóc rất phổ biến, phù hợp với nhiều khuôn mặt. Bạn có thể đặt lịch để tôi tư vấn chi tiết hơn nhé!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 50)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_4',
        senderId: 'customer_1',
        senderName: 'Nguyễn Văn An',
        receiverId: 'barber_1',
        content: 'Vâng, tôi đã đặt lịch vào 10h sáng mai rồi ạ.',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ];

    // Conversation between customer_1 and admin
    _conversations['customer_1_admin_1'] = [
      MessageModel(
        id: 'msg_5',
        senderId: 'admin_1',
        senderName: 'Admin System',
        receiverId: 'customer_1',
        content: 'Xin chào! Cảm ơn bạn đã sử dụng dịch vụ của BarberShop.',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg_6',
        senderId: 'customer_1',
        senderName: 'Nguyễn Văn An',
        receiverId: 'admin_1',
        content: 'Cảm ơn! Dịch vụ rất tuyệt vời.',
        createdAt: now.subtract(const Duration(hours: 23)),
        isRead: true,
      ),
    ];
  }

  /// Get conversation key
  String _getConversationKey(String user1, String user2) {
    final ids = [user1, user2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Get messages between two users
  Future<List<MessageModel>> getMessages(String userId1, String userId2) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final key = _getConversationKey(userId1, userId2);
    return _conversations[key] ?? [];
  }

  /// Send a message
  Future<MessageModel> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final message = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now(),
    );

    final key = _getConversationKey(senderId, receiverId);
    _conversations[key] ??= [];
    _conversations[key]!.add(message);

    // Simulate auto-reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _generateAutoReply(senderId, senderName, receiverId, content);
    });

    return message;
  }

  /// Generate auto-reply (simulates realtime)
  void _generateAutoReply(String originalSenderId, String originalSenderName, String receiverId, String originalContent) {
    final replies = [
      'Cảm ơn bạn đã nhắn tin!',
      'Tôi sẽ phản hồi sớm nhất có thể.',
      'Vâng, tôi đã nhận được tin nhắn của bạn.',
      'Để tôi kiểm tra và trả lời bạn nhé.',
      'OK, tôi hiểu rồi!',
    ];

    final reply = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: receiverId,
      senderName: receiverId.contains('barber') ? 'Thợ cắt tóc' : 'Admin',
      receiverId: originalSenderId,
      content: replies[DateTime.now().second % replies.length],
      createdAt: DateTime.now(),
    );

    final key = _getConversationKey(originalSenderId, receiverId);
    _conversations[key]?.add(reply);
  }

  /// Get all conversations for a user
  Future<List<ConversationModel>> getConversations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final conversations = <ConversationModel>[];

    _conversations.forEach((key, messages) {
      if (key.contains(userId) && messages.isNotEmpty) {
        final otherUserId = key.replaceAll(userId, '').replaceAll('_', '');
        final lastMessage = messages.last;
        final unreadCount = messages.where((m) => m.receiverId == userId && !m.isRead).length;

        String recipientName = 'User';
        String recipientAvatar = 'https://i.pravatar.cc/150?img=1';

        if (otherUserId.contains('barber')) {
          recipientName = 'Phạm Minh Đức';
          recipientAvatar = 'https://i.pravatar.cc/150?img=11';
        } else if (otherUserId.contains('admin')) {
          recipientName = 'Admin Support';
          recipientAvatar = 'https://i.pravatar.cc/150?img=60';
        }

        conversations.add(ConversationModel(
          id: key,
          recipientId: otherUserId,
          recipientName: recipientName,
          recipientAvatar: recipientAvatar,
          lastMessage: lastMessage.content,
          lastMessageTime: lastMessage.createdAt,
          unreadCount: unreadCount,
        ));
      }
    });

    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }

  /// Mark messages as read
  Future<void> markAsRead(String senderId, String receiverId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final key = _getConversationKey(senderId, receiverId);
    final messages = _conversations[key];
    if (messages != null) {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].receiverId == receiverId && !messages[i].isRead) {
          _conversations[key]![i] = messages[i].copyWith(isRead: true);
        }
      }
    }
  }
}
