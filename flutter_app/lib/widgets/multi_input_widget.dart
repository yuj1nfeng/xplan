import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

/// 多功能输入组件
class MultiInputWidget extends StatefulWidget {
  final Function(Message) onSendMessage;
  final bool enabled;

  const MultiInputWidget({
    super.key,
    required this.onSendMessage,
    this.enabled = true,
  });

  @override
  State<MultiInputWidget> createState() => _MultiInputWidgetState();
}

class _MultiInputWidgetState extends State<MultiInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRecording = false;
  bool _showAttachmentOptions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 附件选项
            if (_showAttachmentOptions) _buildAttachmentOptions(),
            // 输入行
            Row(
              children: [
                // 附件按钮
                IconButton(
                  icon: Icon(
                    _showAttachmentOptions ? Icons.close : Icons.add_circle_outline,
                    color: _showAttachmentOptions 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey[600],
                  ),
                  onPressed: widget.enabled ? _toggleAttachmentOptions : null,
                ),
                // 输入框
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: '输入消息、链接或拖拽文件...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic, size: 20),
                        onPressed: widget.enabled ? _startVoiceRecord : null,
                        color: _isRecording ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendTextMessage(),
                    enabled: widget.enabled,
                  ),
                ),
                const SizedBox(width: 8),
                // 发送按钮
                CircleAvatar(
                  backgroundColor: widget.enabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: widget.enabled ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                    onPressed: widget.enabled ? _sendTextMessage : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 附件选项
  Widget _buildAttachmentOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentButton(
            icon: Icons.image,
            label: '图片',
            color: Colors.green,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          _buildAttachmentButton(
            icon: Icons.camera_alt,
            label: '拍照',
            color: Colors.blue,
            onTap: () => _pickImage(ImageSource.camera),
          ),
          _buildAttachmentButton(
            icon: Icons.videocam,
            label: '视频',
            color: Colors.purple,
            onTap: _pickVideo,
          ),
          _buildAttachmentButton(
            icon: Icons.insert_drive_file,
            label: '文件',
            color: Colors.orange,
            onTap: _pickFile,
          ),
          _buildAttachmentButton(
            icon: Icons.link,
            label: '链接',
            color: Colors.teal,
            onTap: _showLinkDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        _toggleAttachmentOptions();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  void _toggleAttachmentOptions() {
    setState(() {
      _showAttachmentOptions = !_showAttachmentOptions;
    });
  }

  /// 发送文本消息
  void _sendTextMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 检测是否是链接
    if (_isUrl(text)) {
      _sendLinkMessage(text);
    } else {
      final message = Message.text(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        role: 'user',
        timestamp: DateTime.now(),
      );
      widget.onSendMessage(message);
    }

    _controller.clear();
    _focusNode.requestFocus();
  }

  /// 检测是否是URL
  bool _isUrl(String text) {
    final urlPattern = RegExp(
      r'https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }

  /// 发送链接消息
  Future<void> _sendLinkMessage(String url) async {
    // 先发送消息
    final message = Message.link(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      role: 'user',
      timestamp: DateTime.now(),
    );
    widget.onSendMessage(message);

    // 异步获取链接预览
    _fetchLinkPreview(url, message.id);
  }

  /// 获取链接预览
  Future<void> _fetchLinkPreview(String url, String messageId) async {
    try {
      // 简单的链接预览（实际项目中可以使用专门的库）
      final uri = Uri.parse(url);
      final domain = uri.host.replaceFirst('www.', '');
      
      // 这里可以调用后端API获取更详细的预览
      // 目前使用简单的域名作为标题
      final card = LinkCard(
        url: url,
        title: domain,
        description: url,
        siteName: domain,
      );

      // 更新消息（通过回调）
      // 实际项目中可以通过 Provider 更新
    } catch (e) {
      debugPrint('获取链接预览失败: $e');
    }
  }

  /// 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final message = Message.image(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: image.path,
          role: 'user',
          timestamp: DateTime.now(),
        );
        widget.onSendMessage(message);
      }
    } catch (e) {
      _showError('选择图片失败: $e');
    }
  }

  /// 选择视频
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        final message = Message.video(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          videoPath: video.path,
          role: 'user',
          timestamp: DateTime.now(),
        );
        widget.onSendMessage(message);
      }
    } catch (e) {
      _showError('选择视频失败: $e');
    }
  }

  /// 选择文件
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final message = Message.file(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.name,
          path: file.path ?? '',
          size: file.size,
          role: 'user',
          timestamp: DateTime.now(),
        );
        widget.onSendMessage(message);
      }
    } catch (e) {
      _showError('选择文件失败: $e');
    }
  }

  /// 显示链接输入对话框
  Future<void> _showLinkDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送链接'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            prefixIcon: Icon(Icons.link),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('发送'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (_isUrl(result)) {
        _sendLinkMessage(result);
      } else {
        _showError('请输入有效的链接地址');
      }
    }
  }

  /// 开始语音录制
  Future<void> _startVoiceRecord() async {
    // Web端不支持语音录制，显示提示
    if (kIsWeb) {
      _showError('Web端暂不支持语音录制，请使用文本输入');
      return;
    }

    setState(() {
      _isRecording = true;
    });

    // TODO: 实现语音录制
    // 需要添加 record 包或其他录音库
    
    // 模拟录音
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isRecording = false;
    });

    final message = Message.voice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      audioPath: '',
      duration: 2,
      role: 'user',
      timestamp: DateTime.now(),
    );
    widget.onSendMessage(message);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}