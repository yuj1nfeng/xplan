// 原生平台实现 - 使用 http 包
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 获取模型列表 (Native)
Future<List<String>> getModels(String url) async {
  final client = http.Client();
  try {
    final response = await client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> models = data['data'] ?? [];
      return models.map((m) => m['id'] as String).toList();
    }
    return [];
  } catch (e) {
    return [];
  } finally {
    client.close();
  }
}

/// 发送聊天消息 (Native)
Future<Map<String, dynamic>> sendChatMessage(String url, String body) async {
  final client = http.Client();
  try {
    final response = await client
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 120));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        final content = choices[0]['message']['content'] as String;
        return {
          'id': data['id'],
          'content': content,
        };
      }
      throw Exception('响应格式错误');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? '请求失败：${response.statusCode}');
    }
  } finally {
    client.close();
  }
}