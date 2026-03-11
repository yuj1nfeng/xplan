import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'about_page.dart';
import 'api_config_page.dart';
import 'login_page.dart';
import 'usage_stats_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              // 账户信息
              _buildSection(
                context,
                title: '账户',
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      if (!auth.isInitialized) {
                        return const ListTile(
                          leading: Icon(Icons.person_outline),
                          title: Text('加载中...'),
                        );
                      }

                      if (auth.currentUser == null) {
                        // 未登录状态
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: const Text('点击登录'),
                          subtitle: const Text('登录以同步数据'),
                          trailing: const Icon(Icons.login, size: 20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        );
                      }

                      // 已登录状态
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                auth.currentUser!.avatarInitials,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              auth.currentUser!.username ?? auth.currentUser!.email ?? '用户',
                            ),
                            subtitle: Text(auth.currentUser!.email ?? ''),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'logout') {
                                  _showLogoutDialog(context, auth);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('退出登录', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (auth.isPremium)
                            ListTile(
                              leading: const Icon(Icons.star, color: Colors.amber),
                              title: const Text('高级会员'),
                              subtitle: auth.currentUser!.premiumExpiresAt != null
                                  ? Text('有效期至 ${_formatDate(auth.currentUser!.premiumExpiresAt!)}')
                                  : null,
                              trailing: const Icon(Icons.verified, color: Colors.green),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              // 外观设置
              _buildSection(
                context,
                title: '外观',
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('主题模式'),
                    subtitle: Text(_getThemeModeText(settingsProvider.themeMode)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(context, settingsProvider),
                  ),
                ],
              ),

              // 通用设置
              _buildSection(
                context,
                title: '通用',
                children: [
                  ListTile(
                    leading: const Icon(Icons.api),
                    title: const Text('API 地址'),
                    subtitle: Text(settingsProvider.apiBaseUrl),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApiConfigPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('使用统计'),
                    subtitle: const Text('查看今日使用额度'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UsageStatsPage(),
                        ),
                      );
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.bug_report),
                    title: const Text('测试模式'),
                    subtitle: const Text('离线状态下模拟响应'),
                    value: settingsProvider.testMode,
                    onChanged: (value) {
                      settingsProvider.setTestMode(value);
                    },
                  ),
                ],
              ),

              // 关于
              _buildSection(
                context,
                title: '关于',
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('关于 XPlan'),
                    subtitle: Text('版本 v${settingsProvider.appVersion}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getThemeModeText(String mode) {
    switch (mode) {
      case 'light':
        return '浅色模式';
      case 'dark':
        return '深色模式';
      default:
        return '跟随系统';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('跟随系统'),
              subtitle: const Text('根据系统设置自动切换'),
              value: 'system',
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('浅色模式'),
              subtitle: const Text('始终使用浅色主题'),
              value: 'light',
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('深色模式'),
              subtitle: const Text('始终使用深色主题'),
              value: 'dark',
              groupValue: provider.themeMode,
              onChanged: (value) {
                provider.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
