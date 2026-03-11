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
  String _currentModel = 'qwen3.5:9b';

  List<Message> get messages => _messages;
  String? get conversationId => _conversationId;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;
  bool get isHistoryLoaded => _isHistoryLoaded;
  String get currentModel => _currentModel;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      _statusMessage = '检查连接...';
      notifyListeners();

      final isHealthy = await _copawService.healthCheck();
      _isConnected = isHealthy;
      
      if (isHealthy) {
        _statusMessage = '已连接 ($_currentModel)';
        // 获取可用模型
        final models = await _copawService.getModels();
        if (models.isNotEmpty) {
          _currentModel = models.first;
          _statusMessage = '已连接 ($_currentModel)';
        }
      } else {
        _statusMessage = '测试模式 (服务未连接)';
      }

      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _statusMessage = '测试模式 (服务未连接)';
      notifyListeners();
    }
  }

  /// 切换模型
  void setModel(String model) {
    _currentModel = model;
    _statusMessage = '已连接 ($_currentModel)';
    notifyListeners();
  }

  /// 获取可用模型列表
  Future<List<String>> getAvailableModels() async {
    return await _copawService.getModels();
  }

  /// 刷新连接（下拉刷新调用）
  Future<void> refreshConnection() async {
    await _checkConnection();
  }

  /// 添加消息到列表
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  /// 加载指定会话的历史消息
  Future<void> loadHistory(String conversationId) async {
    _conversationId = conversationId;
    _messages.clear();
    _isHistoryLoaded = false;
    notifyListeners();

    try {
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
      if (_isConnected) {
        // 调用 OpenAI 兼容 API，传递历史消息
        final response = await _copawService.sendMessage(
          content,
          model: _currentModel,
          history: _messages.where((m) => m.role != 'system').toList(),
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
          content: '[测试模式] 收到你的消息：$content\n\n注意：AI 服务未连接。\n\n请检查 API 地址配置。',
          role: 'assistant',
          timestamp: DateTime.now(),
        );
        _messages.add(assistantMessage);

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
    _conversationId = DateTime.now().millisecondsSinceEpoch.toString();
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
