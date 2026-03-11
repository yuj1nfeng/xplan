import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

import 'package:http/http.dart' as http;

// 条件导入：Web 端使用 dart:html
import 'copaw_service_web.dart' if (dart.library.io) 'copaw_service_native.dart' as platform;

/// CopawService - OpenAI 兼容的 AI 聊天服务
/// 支持 Ollama、OpenAI 等兼容 API
class CopawService {
  // API 基础地址 (OpenAI 兼容)
  static String baseUrl = 'https://ollama.laidanbao.cn/v1';

  // 默认模型
  static String defaultModel = 'qwen3.5:9b';

  /// 更新 API 配置
  static void updateConfig({String? url, String? model}) {
    if (url != null) baseUrl = url;
    if (model != null) defaultModel = model;
  }

  /// 健康检查 - 获取模型列表
  Future<bool> healthCheck() async {
    try {
      final models = await getModels();
      return models.isNotEmpty;
    } catch (e) {
      debugPrint('健康检查失败：$e');
      return false;
    }
  }

  /// 获取可用模型列表
  Future<List<String>> getModels() async {
    try {
      return await platform.getModels('$baseUrl/models');
    } catch (e) {
      debugPrint('获取模型列表失败：$e');
      return [];
    }
  }

  /// 发送消息 (OpenAI Chat Completions API)
  Future<Message> sendMessage(
    String message, {
    String? conversationId,
    String? model,
    List<Message>? history,
  }) async {
    // 构建消息历史
    final List<Map<String, String>> messages = [];

    // 添加历史消息
    if (history != null && history.isNotEmpty) {
      for (final msg in history) {
        messages.add({
          'role': msg.role,
          'content': msg.content,
        });
      }
    }

    // 添加当前消息
    messages.add({
      'role': 'user',
      'content': message,
    });

    final body = jsonEncode({
      'model': model ?? defaultModel,
      'messages': messages,
      'stream': false,
    });

    try {
      final result = await platform.sendChatMessage('$baseUrl/chat/completions', body);
      return Message.fromJson({
        'id': result['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'role': 'assistant',
        'content': result['content'],
      });
    } catch (e) {
      debugPrint('发送消息失败：$e');
      rethrow;
    }
  }

  void dispose() {
    // 清理资源
  }
}