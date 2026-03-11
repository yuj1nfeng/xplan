import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    // 初始化控制器文本
    if (_controller.text.isEmpty) {
      _controller.text = provider.apiBaseUrl;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API 配置'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COPAW API 地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'https://copaw.laidanbao.cn',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入 API 地址';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return '地址必须以 http:// 或 https:// 开头';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '提示：修改 API 地址后，应用将使用新的地址进行通信。请确保地址正确可用。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await provider.setApiBaseUrl(_controller.text.trim());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('API 地址已保存'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('保存失败：$e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('保存'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
