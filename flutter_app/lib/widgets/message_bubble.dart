import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

/// 消息气泡组件 - 支持多种消息类型
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(context, isAssistant: true),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(context, isUser),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(context, isAssistant: false),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isAssistant}) {
    return CircleAvatar(
      backgroundColor: isAssistant
          ? Theme.of(context).colorScheme.primary
          : Colors.grey[300],
      child: Text(
        isAssistant ? '🤖' : '👤',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  /// 根据消息类型构建不同的内容
  Widget _buildMessageContent(BuildContext context, bool isUser) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextBubble(context, isUser);
      case MessageType.image:
        return _buildImageBubble(context, isUser);
      case MessageType.video:
        return _buildVideoBubble(context, isUser);
      case MessageType.voice:
        return _buildVoiceBubble(context, isUser);
      case MessageType.file:
        return _buildFileBubble(context, isUser);
      case MessageType.link:
        return _buildLinkBubble(context, isUser);
    }
  }

  /// 文本消息气泡
  Widget _buildTextBubble(BuildContext context, bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  /// 图片消息气泡
  Widget _buildImageBubble(BuildContext context, bool isUser) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(message.mediaPath),
          ),
          if (message.content != '📷 图片') ...[
            const SizedBox(height: 8),
            Text(message.content, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        width: 200,
        height: 150,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    }

    // Web端使用网络图片或占位图
    if (kIsWeb) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        );
      }
      return _buildPlaceholderImage();
    }

    // 原生平台使用本地文件
    return Image.file(
      File(path),
      width: 200,
      height: 150,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 200,
      height: 150,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('📷 图片', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 视频消息气泡
  Widget _buildVideoBubble(BuildContext context, bool isUser) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          height: 150,
          color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                message.content,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 语音消息气泡
  Widget _buildVoiceBubble(BuildContext context, bool isUser) {
    final duration = message.voiceInfo?.duration ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.9)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: isUser ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 8),
          // 音波动画占位
          Row(
            children: List.generate(
              20,
              (i) => Container(
                width: 2,
                height: 8 + (i % 4) * 4.0,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 文件消息气泡
  Widget _buildFileBubble(BuildContext context, bool isUser) {
    final fileInfo = message.fileInfo;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFileColor(fileInfo?.mimeType),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileInfo?.mimeType),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileInfo?.name ?? '未知文件',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fileInfo?.formattedSize ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.download, size: 20, color: Colors.grey[600]),
        ],
      ),
    );
  }

  /// 链接消息气泡（带卡片）
  Widget _buildLinkBubble(BuildContext context, bool isUser) {
    final card = message.linkCard;
    final url = message.content;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 预览图
              if (card?.image != null && card!.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    card.image!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.link, size: 30, color: Colors.grey)),
                    ),
                  ),
                )
              else
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.link,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              // 文字信息
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card?.title != null) ...[
                      Text(
                        card!.title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (card?.description != null) ...[
                      Text(
                        card!.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    // 域名
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          card?.siteName ?? _getDomain(url),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  Color _getFileColor(String? mimeType) {
    if (mimeType == null) return Colors.grey;
    if (mimeType.contains('pdf')) return Colors.red;
    if (mimeType.contains('word') || mimeType.contains('document')) return Colors.blue;
    if (mimeType.contains('excel') || mimeType.contains('sheet')) return Colors.green;
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) return Colors.orange;
    if (mimeType.contains('zip') || mimeType.contains('rar')) return Colors.purple;
    return Colors.grey;
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('document')) return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('sheet')) return Icons.table_chart;
    if (mimeType.contains('powerpoint') || mimeType.contains('presentation')) return Icons.slideshow;
    if (mimeType.contains('zip') || mimeType.contains('rar')) return Icons.folder_zip;
    if (mimeType.contains('audio')) return Icons.audio_file;
    if (mimeType.contains('video')) return Icons.video_file;
    return Icons.insert_drive_file;
  }
}