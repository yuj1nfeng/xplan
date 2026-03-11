import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import 'message_bubble.dart';
import 'multi_input_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // 消息变化时滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (chatProvider.messages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Column(
          children: [
            // 状态栏
            _buildStatusBar(chatProvider),
            // 消息列表
            Expanded(
              child: chatProvider.messages.isEmpty
                  ? _buildWelcomeMessage()
                  : _buildMessageList(chatProvider),
            ),
            // 多功能输入区域
            MultiInputWidget(
              onSendMessage: (message) => _handleMessage(chatProvider, message),
              enabled: !chatProvider.isLoading,
            ),
          ],
        );
      },
    );
  }

  /// 状态栏
  Widget _buildStatusBar(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chatProvider.isConnected
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            chatProvider.isConnected ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: chatProvider.isConnected ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chatProvider.statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: chatProvider.isConnected ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          ),
          // 模型选择
          if (chatProvider.isConnected)
            TextButton.icon(
              icon: const Icon(Icons.smart_toy, size: 16),
              label: Text(
                chatProvider.currentModel,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () => _showModelSelector(chatProvider),
            ),
        ],
      ),
    );
  }

  /// 显示模型选择器
  void _showModelSelector(ChatProvider chatProvider) async {
    final models = await chatProvider.getAvailableModels();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择模型',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...models.map((model) => ListTile(
              leading: Icon(
                model == chatProvider.currentModel
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: model == chatProvider.currentModel
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              title: Text(model),
              onTap: () {
                chatProvider.setModel(model);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '👋 欢迎使用 XPlan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI 智能助手',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            // 功能卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildFeatureCard(Icons.text_fields, '文本对话'),
                  _buildFeatureCard(Icons.mic, '语音消息'),
                  _buildFeatureCard(Icons.image, '发送图片'),
                  _buildFeatureCard(Icons.videocam, '发送视频'),
                  _buildFeatureCard(Icons.insert_drive_file, '发送文件'),
                  _buildFeatureCard(Icons.link, '链接卡片'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        await chatProvider.refreshConnection();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatProvider.messages.length) {
            return _buildTypingIndicator();
          }
          return MessageBubble(message: chatProvider.messages[index]);
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Text('🤖', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0),
                const SizedBox(width: 4),
                _buildAnimatedDot(150),
                const SizedBox(width: 4),
                _buildAnimatedDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (value < 0.5 ? value : 1 - value)),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  /// 处理消息发送
  void _handleMessage(ChatProvider chatProvider, Message message) {
    // 添加用户消息到列表
    chatProvider.addMessage(message);

    // 如果是文本消息，发送到AI
    if (message.type == MessageType.text) {
      chatProvider.sendMessage(message.content);
    } else {
      // 其他类型的消息，AI回复确认
      _sendMediaReply(chatProvider, message);
    }
  }

  /// 发送媒体消息的AI回复
  void _sendMediaReply(ChatProvider chatProvider, Message message) {
    String replyContent;
    switch (message.type) {
      case MessageType.image:
        replyContent = '📷 收到图片！我可以帮你分析图片内容或回答相关问题。';
        break;
      case MessageType.video:
        replyContent = '🎬 收到视频！请问有什么我可以帮助你的？';
        break;
      case MessageType.voice:
        replyContent = '🎤 收到语音消息！请问有什么我可以帮助你的？';
        break;
      case MessageType.file:
        replyContent = '📎 收到文件「${message.fileInfo?.name ?? '未知'}」！我可以帮你处理文件内容。';
        break;
      case MessageType.link:
        replyContent = '🔗 收到链接！我可以帮你总结链接内容或回答相关问题。';
        break;
      default:
        replyContent = '收到消息！请问有什么我可以帮助你的？';
    }

    // 延迟发送回复
    Future.delayed(const Duration(milliseconds: 500), () {
      final reply = Message.text(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: replyContent,
        role: 'assistant',
        timestamp: DateTime.now(),
      );
      chatProvider.addMessage(reply);
    });
  }
}