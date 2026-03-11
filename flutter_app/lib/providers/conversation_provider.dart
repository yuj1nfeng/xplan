import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/conversation_service.dart';

class ConversationProvider extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();

  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ConversationProvider() {
    loadConversations();
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationService.getConversations();
    } catch (e) {
      _error = '加载会话失败：$e';
      debugPrint(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建新会话
  Future<Conversation?> createNewConversation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final conversation = await _conversationService.createConversation();
      if (conversation != null) {
        _conversations.insert(0, conversation);
        _currentConversation = conversation;
        notifyListeners();
        return conversation;
      }
    } catch (e) {
      _error = '创建会话失败：$e';
      debugPrint(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// 切换当前会话
  Future<void> switchConversation(Conversation conversation) async {
    _currentConversation = conversation;
    notifyListeners();
  }

  /// 删除会话
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final success = await _conversationService.deleteConversation(conversationId);
      if (success) {
        _conversations.removeWhere((c) => c.id == conversationId);
        if (_currentConversation?.id == conversationId) {
          _currentConversation = null;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = '删除会话失败：$e';
      debugPrint(_error!);
    }
    return false;
  }

  /// 更新会话标题
  Future<bool> renameConversation(String conversationId, String title) async {
    try {
      final success = await _conversationService.updateConversationTitle(
        conversationId,
        title,
      );
      if (success) {
        final index = _conversations.indexWhere((c) => c.id == conversationId);
        if (index != -1) {
          _conversations[index] = _conversations[index].copyWith(title: title);
          if (_currentConversation?.id == conversationId) {
            _currentConversation = _conversations[index];
          }
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      _error = '重命名会话失败：$e';
      debugPrint(_error!);
    }
    return false;
  }

  /// 清空会话列表
  void clear() {
    _conversations.clear();
    _currentConversation = null;
    notifyListeners();
  }

  /// 刷新会话列表
  Future<void> refresh() async {
    await loadConversations();
  }
}
