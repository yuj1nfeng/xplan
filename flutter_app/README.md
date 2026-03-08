# XPlan - 跨平台 COPAW 客户端

基于 Flutter 开发的跨平台 AI 助手客户端，一套代码编译所有平台。

## 📱 支持平台

| 平台 | 状态 | 编译命令 |
|------|------|---------|
| **macOS** | ✅ 支持 | `flutter build macos` |
| **Windows** | ✅ 支持 | `flutter build windows` |
| **Linux** | ✅ 支持 | `flutter build linux` |
| **Android** | ✅ 支持 | `flutter build apk` |
| **iOS** | ✅ 支持 | `flutter build ios` |

## 🛠️ 开发环境要求

### 必需工具

- **Flutter SDK** (3.16+)
- **Dart SDK** (随 Flutter 安装)

### 各平台额外要求

| 平台 | 开发环境 | 编译环境 |
|------|---------|---------|
| macOS | macOS + Xcode | macOS + Xcode |
| iOS | macOS + Xcode | macOS + Xcode + Apple 开发者账号 |
| Windows | Windows 10+ + Visual Studio 2022 | Windows 10+ |
| Linux | Ubuntu/Debian + GTK 开发库 | Linux |
| Android | Android Studio | JDK 11+ |

## 🚀 快速开始

### 1. 安装 Flutter

```bash
# macOS
brew install --cask flutter

# Windows
# 下载 Flutter SDK: https://docs.flutter.dev/get-started/install/windows

# Linux
sudo snap install flutter --classic
```

### 2. 验证安装

```bash
flutter doctor
```

### 3. 安装依赖

```bash
cd flutter_app
flutter pub get
```

### 4. 运行应用

```bash
# 运行在当前设备
flutter run

# 指定平台
flutter run -d macos      # macOS
flutter run -d windows    # Windows
flutter run -d linux      # Linux
flutter run -d chrome     # Web
flutter run -d <device>   # Android/iOS 设备
```

## 📦 构建发布版本

### macOS

```bash
flutter build macos
# 输出：build/macos/Build/Products/Release/xplan.app
```

### Windows

```bash
flutter build windows
# 输出：build/windows/runner/Release/
```

### Linux

```bash
flutter build linux
# 输出：build/linux/x64/release/bundle/
```

### Android

```bash
# APK
flutter build apk

# AAB (Google Play)
flutter build appbundle

# 输出：build/app/outputs/flutter-apk/
```

### iOS

```bash
flutter build ios
# 输出：build/ios/iphoneos/
# 需要在 Xcode 中签名和打包
```

### Web (H5)

```bash
flutter build web
# 输出：build/web/
```

## 📁 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── models/                # 数据模型
│   │   └── message.dart       # 消息模型
│   ├── services/              # 服务层
│   │   └── copaw_service.dart # COPAW API 服务
│   ├── providers/             # 状态管理
│   │   └── chat_provider.dart # 聊天状态管理
│   ├── screens/               # 页面
│   │   └── home_screen.dart   # 首页
│   └── widgets/               # 组件
│       └── chat_view.dart     # 聊天视图
├── assets/                    # 资源文件
├── test/                      # 测试文件
└── pubspec.yaml              # 项目配置
```

## 🔌 COPAW API 配置

编辑 `lib/services/copaw_service.dart`:

```dart
static const String baseUrl = 'http://localhost:18789';
```

### API 端点

- `GET /api/health` - 健康检查
- `POST /api/chat` - 发送消息
- `GET /api/conversations` - 获取会话列表
- `POST /api/conversations` - 创建会话
- `GET /api/conversations/{id}/messages` - 获取会话历史

## 🎨 功能特性

- ✅ 实时聊天界面
- ✅ 消息历史记录
- ✅ 多会话管理
- ✅ 连接状态指示
- ✅ 打字动画效果
- ✅ 响应式设计（手机/平板/桌面）
- ✅ 深色/浅色主题支持
- ✅ 离线测试模式

## 📝 开发说明

### 状态管理

使用 Provider 进行状态管理，主要状态在 `ChatProvider` 中：

- `messages` - 消息列表
- `conversationId` - 当前会话 ID
- `isConnected` - 连接状态
- `isLoading` - 加载状态

### 添加新功能

1. 在 `models/` 添加数据模型
2. 在 `services/` 添加 API 服务
3. 在 `providers/` 添加状态管理
4. 在 `screens/` 或 `widgets/` 添加 UI

## ⚠️ 注意事项

1. **iOS/macOS 编译** 只能在 macOS 上进行
2. **iOS 发布** 需要 Apple 开发者账号和代码签名
3. **Windows 编译** 需要 Visual Studio 2022 和 C++ 桌面开发组件
4. **Linux 编译** 需要安装 GTK 开发库

## 🐛 常见问题

### Flutter doctor 报错

```bash
flutter doctor --android-licenses
flutter config --android-sdk <path>
```

### Web 版本 CORS 问题

Web 版本需要 COPAW 服务支持 CORS，或配置代理。

### 桌面版本窗口大小

在 `lib/main.dart` 中设置窗口大小（需要 `flutter_windowmanager` 包）。

## 📄 许可证

MIT License

---

**开发完成时间**: 2026 年 3 月
**Flutter 版本**: 3.x
**Dart 版本**: 3.x
