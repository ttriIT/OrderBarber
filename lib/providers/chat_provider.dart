import 'package:flutter/material.dart';
import '../data/models/message_model.dart';
import '../data/services/fake_chat_service.dart';

/// ChatProvider for managing chat and messaging state
class ChatProvider extends ChangeNotifier {
  final FakeChatService _chatService = FakeChatService();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _currentRecipientId;

  // Getters
  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentRecipientId => _currentRecipientId;

  /// Load all conversations for a user
  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations(userId);
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String userId, String recipientId) async {
    _isLoading = true;
    _currentRecipientId = recipientId;
    notifyListeners();

    try {
      _messages = await _chatService.getMessages(userId, recipientId);
      // Mark messages as read
      await _chatService.markAsRead(userId, recipientId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Send a message
  Future<bool> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String content,
  }) async {
    try {
      final message = await _chatService.sendMessage(
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        content: content,
      );

      _messages.add(message);
      notifyListeners();

      // Auto-refresh after 2s for fake auto-reply
      Future.delayed(const Duration(seconds: 3), () {
        loadMessages(senderId, receiverId);
      });

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  /// Clear current chat
  void clearCurrentChat() {
    _messages = [];
    _currentRecipientId = null;
    notifyListeners();
  }

  /// Get unread count for a user
  int getUnreadCount(String recipientId) {
    final conversation = _conversations.firstWhere(
      (c) => c.recipientId == recipientId,
      orElse: () => ConversationModel(
        id: '',
        recipientId: '',
        recipientName: '',
        recipientAvatar: '',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
    );
    return conversation.unreadCount;
  }

  /// Get total unread count
  int getTotalUnreadCount() {
    return _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  }
}
