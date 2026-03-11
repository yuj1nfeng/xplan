import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../providers/conversation_provider.dart';
import '../providers/chat_provider.dart';

class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会话列表'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新对话',
            onPressed: () async {
              final provider = context.read<ConversationProvider>();
              final conversation = await provider.createNewConversation();
              if (conversation != null && context.mounted) {
                // 切换到新会话
                context.read<ChatProvider>().newConversation();
                Navigator.pop(context, conversation);
              }
            },
          ),
        ],
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, conversationProvider, child) {
          if (conversationProvider.isLoading &&
              conversationProvider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (conversationProvider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无会话',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final conversation =
                          await conversationProvider.createNewConversation();
                      if (conversation != null && context.mounted) {
                        context.read<ChatProvider>().newConversation();
                        Navigator.pop(context, conversation);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('创建新对话'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => conversationProvider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversationProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation =
                    conversationProvider.conversations[index];
                final isCurrent = conversationProvider.currentConversation?.id ==
                    conversation.id;

                return _ConversationTile(
                  conversation: conversation,
                  isCurrent: isCurrent,
                  onTap: () async {
                    // 切换会话并加载历史
                    await conversationProvider.switchConversation(conversation);
                    await context.read<ChatProvider>().loadHistory(conversation.id);
                    if (context.mounted) {
                      Navigator.pop(context, conversation);
                    }
                  },
                  onDelete: () async {
                    final confirm = await _showDeleteConfirm(context);
                    if (confirm && context.mounted) {
                      await conversationProvider
                          .deleteConversation(conversation.id);
                    }
                  },
                  onRename: () => _showRenameDialog(context, conversation),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('删除会话'),
            content: const Text('确定要删除这个会话吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showRenameDialog(BuildContext context, Conversation conversation) {
    final controller = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名会话'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入新名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                await context
                    .read<ConversationProvider>()
                    .renameConversation(conversation.id, title);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ConversationTile({
    required this.conversation,
    required this.isCurrent,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('删除会话'),
                content: const Text('确定要删除这个会话吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('删除'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: isCurrent
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.chat_bubble,
              color: isCurrent
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          title: Text(
            conversation.truncatedTitle,
            style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            conversation.formattedTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'rename':
                  onRename();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('重命名'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('删除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
