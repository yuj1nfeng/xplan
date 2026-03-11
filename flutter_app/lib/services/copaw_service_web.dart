// Web 平台实现 - 使用 dart:html
import 'dart:async';
import 'dart:convert';
import 'dart:html';

/// 获取模型列表 (Web)
Future<List<String>> getModels(String url) async {
  final completer = Completer<List<String>>();
  
  final request = HttpRequest();
  request.open('GET', url);
  request.setRequestHeader('Content-Type', 'application/json');
  
  request.onLoad.listen((_) {
    if (request.status == 200) {
      try {
        final data = jsonDecode(request.responseText ?? '{}');
        final List<dynamic> models = data['data'] ?? [];
        completer.complete(models.map((m) => m['id'] as String).toList());
      } catch (e) {
        completer.complete([]);
      }
    } else {
      completer.complete([]);
    }
  });
  
  request.onError.listen((_) {
    completer.complete([]);
  });
  
  request.send();
  return completer.future;
}

/// 发送聊天消息 (Web)
Future<Map<String, dynamic>> sendChatMessage(String url, String body) async {
  final completer = Completer<Map<String, dynamic>>();
  
  final request = HttpRequest();
  request.open('POST', url);
  request.setRequestHeader('Content-Type', 'application/json');
  
  request.onLoad.listen((_) {
    if (request.status == 200) {
      try {
        final data = jsonDecode(request.responseText ?? '{}');
        final choices = data['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          completer.complete({
            'id': data['id'],
            'content': content,
          });
        } else {
          completer.completeError(Exception('响应格式错误'));
        }
      } catch (e) {
        completer.completeError(Exception('解析响应失败：$e'));
      }
    } else {
      try {
        final error = jsonDecode(request.responseText ?? '{}');
        completer.completeError(Exception(error['error']?['message'] ?? '请求失败：${request.status}'));
      } catch (_) {
        completer.completeError(Exception('请求失败：${request.status}'));
      }
    }
  });
  
  request.onError.listen((_) {
    completer.completeError(Exception('网络请求失败'));
  });
  
  request.send(body);
  return completer.future;
}