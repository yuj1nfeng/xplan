import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_view.dart';
import 'settings_page.dart';
import 'conversation_list_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 XPlan - COPAW 客户端'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: chatProvider.isConnected
                          ? Colors.green
                          : chatProvider.statusMessage.contains('连接')
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chatProvider.statusMessage,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: '会话列表',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationListPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_comment),
            tooltip: '新对话',
            onPressed: () {
              context.read<ChatProvider>().newConversation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: const ChatView(),
    );
  }
}
