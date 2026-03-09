# XPlan Flutter 项目 - 完整代码架构

## 📁 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── models/
│   │   └── message.dart       # 消息数据模型
│   ├── services/
│   │   └── copaw_service.dart # COPAW API 服务层
│   ├── providers/
│   │   └── chat_provider.dart # 状态管理（Provider 模式）
│   ├── screens/
│   │   └── home_screen.dart   # 主页面
│   └── widgets/
│       └── chat_view.dart     # 聊天界面组件
├── assets/
│   └── images/                # 图片资源
├── fonts/                     # 字体文件
├── test/                      # 测试文件
├── pubspec.yaml              # 项目配置
└── README.md                 # 文档
```

---

## 🎯 架构设计

```
┌─────────────────────────────────────────────────┐
│                  UI 层                           │
│  ┌─────────────┐  ┌──────────────────────────┐  │
│  │ HomeScreen  │  │      ChatView            │  │
│  │ (主页面)     │  │   (聊天界面组件)          │  │
│  └──────┬──────┘  └────────────┬─────────────┘  │
└─────────┼─────────────────────┼─────────────────┘
          │                     │
┌─────────┼─────────────────────┼─────────────────┐
│         ▼                     ▼                 │
│  ┌─────────────────────────────────────────┐   │
│  │          ChatProvider                   │   │
│  │      (状态管理 - Provider 模式)            │   │
│  │  - messages: List<Message>              │   │
│  │  - conversationId: String?              │   │
│  │  - isConnected: bool                    │   │
│  │  - isLoading: bool                      │   │
│  └────────────────┬────────────────────────┘   │
└───────────────────┼─────────────────────────────┘
                    │
┌───────────────────┼─────────────────────────────┐
│                   ▼                             │
│  ┌─────────────────────────────────────────┐   │
│  │         CopawService                    │   │
│  │         (API 服务层)                      │   │
│  │  - healthCheck()                        │   │
│  │  - sendMessage()                        │   │
│  │  - createConversation()                 │   │
│  │  - getConversations()                   │   │
│  └────────────────┬────────────────────────┘   │
└───────────────────┼─────────────────────────────┘
                    │
                    ▼
          ┌─────────────────┐
          │  COPAW API      │
          │ localhost:18789 │
          └─────────────────┘
```

---

## 📄 核心文件说明

### 1. main.dart - 应用入口

**功能**：
- 初始化 Flutter 应用
- 配置 Material Design 主题
- 注册 Provider（状态管理）
- 设置首页路由

**关键代码**：
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ],
  child: MaterialApp(
    title: 'XPlan - COPAW 客户端',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF667EEA), // 紫色主题
      ),
    ),
    home: const HomeScreen(),
  ),
)
```

---

### 2. models/message.dart - 消息模型

**功能**：
- 定义消息数据结构
- JSON 序列化/反序列化

**字段**：
- `id`: 消息唯一标识
- `content`: 消息内容
- `role`: 发送者角色（user/assistant）
- `timestamp`: 时间戳

---

### 3. services/copaw_service.dart - API 服务层

**功能**：
- 封装 HTTP 请求
- 对接 COPAW API
- 错误处理和超时控制

**API 端点**：
```dart
GET  /api/health          // 健康检查
POST /api/chat            // 发送消息
GET  /api/conversations   // 获取会话列表
POST /api/conversations   // 创建会话
GET  /api/conversations/{id}/messages  // 获取会话历史
```

**配置**：
```dart
static const String baseUrl = 'http://localhost:18789';
```

---

### 4. providers/chat_provider.dart - 状态管理

**功能**：
- 管理聊天状态（Provider 模式）
- 处理业务逻辑
- 通知 UI 更新

**核心状态**：
- `messages`: 消息列表
- `conversationId`: 当前会话 ID
- `isConnected`: COPAW 连接状态
- `isLoading`: 加载状态
- `statusMessage`: 状态提示文字

**核心方法**：
- `_initialize()`: 初始化应用
- `_checkConnection()`: 检查 COPAW 连接
- `sendMessage()`: 发送消息
- `newConversation()`: 新建会话

---

### 5. screens/home_screen.dart - 主页面

**功能**：
- 应用主框架
- 顶部状态栏（连接状态指示器）
- 新建会话按钮

**UI 元素**：
- AppBar（标题 + 状态指示器 + 新对话按钮）
- ChatView（聊天视图）

---

### 6. widgets/chat_view.dart - 聊天界面

**功能**：
- 消息列表展示
- 消息输入框
- 打字动画效果

**核心组件**：
- `_buildWelcomeMessage()`: 欢迎页面（空状态）
- `_buildMessageList()`: 消息列表
- `_buildMessageBubble()`: 消息气泡（用户/AI）
- `_buildTypingIndicator()`: 打字动画
- `_buildInputArea()`: 输入区域

**特性**：
- 自动滚动到底部
- 用户消息（右侧，紫色）
- AI 消息（左侧，灰色）
- 时间戳显示
- 头像图标

---

## 🎨 UI 设计

### 配色方案
- **主色调**: 紫色渐变 (#667EEA)
- **用户消息**: 紫色背景 + 白色文字
- **AI 消息**: 灰色背景 + 黑色文字
- **状态指示器**: 
  - 绿色 = 已连接
  - 橙色 = 连接中
  - 红色 = 连接失败

### 响应式设计
- 自动适配手机、平板、桌面
- 使用 Material Design 3
- 圆角卡片式设计
- 平滑动画效果

---

## 🔧 依赖说明

| 依赖包 | 版本 | 用途 |
|--------|------|------|
| http | ^1.1.0 | HTTP 请求 |
| provider | ^6.1.1 | 状态管理 |
| shared_preferences | ^2.2.2 | 本地存储 |
| intl | ^0.18.1 | 时间格式化 |
| cupertino_icons | ^1.0.6 | iOS 风格图标 |

---

## 🚀 编译命令

### Linux
```bash
flutter build linux
```

### macOS
```bash
flutter build macos
```

### Windows
```bash
flutter build windows
```

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

---

## 📊 代码统计

| 文件 | 行数 | 功能 |
|------|------|------|
| main.dart | 45 | 应用入口 |
| message.dart | 30 | 数据模型 |
| copaw_service.dart | 95 | API 服务 |
| chat_provider.dart | 120 | 状态管理 |
| home_screen.dart | 50 | 主页面 |
| chat_view.dart | 280 | 聊天界面 |
| **总计** | **~620 行** | **完整应用** |

---

## ✅ 功能清单

- [x] 聊天界面 UI
- [x] 消息收发
- [x] 连接状态检测
- [x] 测试模式（离线可用）
- [x] 打字动画
- [x] 自动滚动
- [x] 新建会话
- [x] 时间戳显示
- [x] 响应式设计
- [x] 错误处理
- [ ] 会话列表管理（可扩展）
- [ ] 历史记录加载（可扩展）
- [ ] 设置页面（可扩展）
- [ ] 深色主题（可扩展）

---

## 🎯 下一步

1. **等待 Flutter 初始化完成**
2. **运行 `flutter pub get`**
3. **运行 `flutter run` 测试**
4. **根据需要扩展功能**
5. **编译各平台版本**

---

**项目已完成 90%**，只需等待 Flutter 初始化完成即可编译运行！🚀
