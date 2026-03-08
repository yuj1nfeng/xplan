# XPlan Flutter 项目 - 启动指南

## 🎯 当前状态

- ✅ Flutter SDK 已下载：`/root/flutter`
- ✅ 项目代码已创建：`/root/.copaw/xplan/flutter_app/`
- ⏳ Flutter 首次初始化中（后台自动进行）

---

## 🚀 手动启动步骤

### 1. 设置环境变量

```bash
export PATH="$PATH:/root/flutter/bin"
```

### 2. 检查 Flutter（首次需要等待初始化完成）

```bash
flutter --version
```

**注意**: 首次运行 Flutter 需要 5-15 分钟初始化 Dart SDK 和工具。

### 3. 进入项目目录

```bash
cd /root/.copaw/xplan/flutter_app
```

### 4. 安装依赖

```bash
flutter pub get
```

### 5. 运行应用

```bash
# Linux 桌面版
flutter run -d linux

# Web 版（浏览器）
flutter run -d chrome

# 查看可用设备
flutter devices
```

---

## 📦 构建各平台版本

### macOS (需要 macOS 系统)

```bash
flutter build macos
# 输出：build/macos/Build/Products/Release/xplan.app
```

### Windows (需要 Windows 系统)

```bash
flutter build windows
# 输出：build/windows/runner/Release/xplan.exe
```

### Linux

```bash
flutter build linux
# 输出：build/linux/x64/release/bundle/
```

### Android

```bash
flutter build apk
# 输出：build/app/outputs/flutter-apk/app-release.apk
```

### iOS (需要 macOS + Xcode)

```bash
flutter build ios
# 输出：build/ios/iphoneos/Runner.app
# 需要在 Xcode 中签名打包成 IPA
```

### Web (H5)

```bash
flutter build web
# 输出：build/web/
```

---

## 🔧 COPAW API 配置

编辑文件：`lib/services/copaw_service.dart`

```dart
// 第 8 行修改 API 地址
static const String baseUrl = 'http://localhost:18789';
```

---

## 📱 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── models/
│   │   └── message.dart       # 消息模型
│   ├── services/
│   │   └── copaw_service.dart # COPAW API 对接
│   ├── providers/
│   │   └── chat_provider.dart # 状态管理
│   ├── screens/
│   │   └── home_screen.dart   # 主页面
│   └── widgets/
│       └── chat_view.dart     # 聊天界面组件
├── assets/                    # 资源文件
├── pubspec.yaml              # 依赖配置
└── README.md                 # 详细文档
```

---

## ⚠️ 常见问题

### Flutter 初始化卡住

```bash
# 清理缓存重试
flutter clean
flutter precache
```

### 网络问题（中国用户）

```bash
# 使用镜像
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
flutter pub get
```

### Linux 平台依赖

```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

---

## 📊 编译时间参考

| 操作 | 首次 | 后续 |
|------|------|------|
| flutter pub get | 2-5 分钟 | 30 秒 |
| flutter build linux | 5-10 分钟 | 1-2 分钟 |
| flutter build macos | 10-15 分钟 | 2-3 分钟 |
| flutter build windows | 10-15 分钟 | 2-3 分钟 |
| flutter build apk | 5-10 分钟 | 1-2 分钟 |
| flutter build ios | 10-15 分钟 | 2-3 分钟 |

---

## ✅ 完成标志

当你看到以下输出，说明可以开始开发了：

```
Flutter 3.x.x • channel stable • https://github.com/flutter/flutter.git
Framework • revision xxxxxxxxxx (weeks ago)
Engine • revision xxxxxxxxxx
Tools • Dart 3.x.x • DevTools 2.xx.x
```

---

**项目位置**: `/root/.copaw/xplan/flutter_app/`
**Flutter 位置**: `/root/flutter`
**文档位置**: `/root/.copaw/xplan/flutter_app/README.md`
