import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/copaw_service.dart';
import '../services/message_history_service.dart';

class ChatProvider extends ChangeNotifier {
  final CopawService _copawService = CopawService();
  final MessageHistoryService _historyService = MessageHistoryService();

  final List<Message> _messages = [];
  String? _conversationId;
  bool _isConnected = false;
  bool _isLoading = false;
  String _statusMessage = '连接中...';
  bool _isHistoryLoaded = false;

  List<Message> get messages => _messages;
  String? get conversationId => _conversationId;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  bool get isHistoryLoaded => _isHistoryLoaded;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkConnection();
    if (_isConnected) {
      await _createConversation();
    }
  }

  Future<void> _checkConnection() async {
    try {
      _statusMessage = '检查连接...';
      notifyListeners();

      final isHealthy = await _copawService.healthCheck();
      _isConnected = isHealthy;
      _statusMessage = isHealthy ? '已连接' : '连接失败';

      if (!isHealthy) {
        _statusMessage = '测试模式 (COPAW 服务未连接)';
      }

      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _statusMessage = '测试模式 (COPAW 服务未连接)';
      notifyListeners();
    }
  }

  Future<void> _createConversation() async {
    try {
      _conversationId = await _copawService.createConversation();
      notifyListeners();
    } catch (e) {
      print('创建会话失败：$e');
    }
  }

  /// 加载指定会话的历史消息
  Future<void> loadHistory(String conversationId) async {
    _conversationId = conversationId;
    _messages.clear();
    _isHistoryLoaded = false;
    notifyListeners();

    try {
      // 从本地加载历史消息
      final history = await _historyService.loadMessages(conversationId);
      _messages.addAll(history);
      _isHistoryLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('加载历史失败：$e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isLoading) return;

    // 添加用户消息
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      role: 'user',
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    // 保存到历史
    if (_conversationId != null) {
      await _historyService.appendMessage(_conversationId!, userMessage);
    }

    try {
      if (_isConnected && _conversationId != null) {
        // 调用真实 API
        final response = await _copawService.sendMessage(
          content,
          conversationId: _conversationId,
        );
        _messages.add(response);
        
        // 保存助手消息到历史
        if (_conversationId != null) {
          await _historyService.appendMessage(_conversationId!, response);
        }
      } else {
        // 测试模式 - 模拟回复
        await Future.delayed(const Duration(seconds: 1));
        final assistantMessage = Message(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          content: '[测试模式] 收到你的消息：$content\n\n注意：COPAW 服务 (端口 18789) 未启动或不可用。\n\n当前支持的平台：\n- macOS\n- Windows\n- Linux\n- Android\n- iOS',
          role: 'assistant',
          timestamp: DateTime.now(),
        );
        _messages.add(assistantMessage);
        
        // 保存助手消息到历史
        if (_conversationId != null) {
          await _historyService.appendMessage(_conversationId!, assistantMessage);
        }
      }
    } catch (e) {
      // 错误处理
      final errorMessage = Message(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: '发送失败：$e',
        role: 'assistant',
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> newConversation() async {
    _messages.clear();
    _isHistoryLoaded = false;
    if (_isConnected) {
      await _createConversation();
    } else {
      _conversationId = null;
    }
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _copawService.dispose();
    super.dispose();
  }
}
