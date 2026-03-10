# XPlan 跨平台编译指南

**当前环境**: CentOS 8 (Linux 服务器)  
**Flutter**: 3.41.4 (stable)

---

## ✅ 当前可编译平台

| 平台 | 状态 | 说明 |
|------|------|------|
| **Web** | ✅ 已完成 | `release/v1.0.0/web/` |
| **Linux** | ⚠️ 需依赖 | 需安装 CMake + Ninja |
| **Android** | ⚠️ 需 SDK | 需安装 Android SDK |

---

## ❌ 当前环境无法编译的平台

| 平台 | 原因 | 解决方案 |
|------|------|---------|
| **macOS** | 需要 macOS 系统 + Xcode | 在 Mac 电脑上编译 |
| **iOS** | 需要 macOS 系统 + Xcode + Apple 签名 | 在 Mac 电脑上编译 |
| **Windows** | 需要 Windows + Visual Studio | 在 Windows 电脑上编译 |

---

## 🔧 安装方案

### 方案 1: Linux 版本（推荐）

```bash
# 安装依赖
sudo yum install -y cmake ninja-build clang gtk3-devel

# 编译
cd /root/.copaw/xplan/flutter_app
flutter build linux --release

# 输出位置
ls -la build/linux/x64/release/bundle/
```

### 方案 2: Android 版本

```bash
# 下载 Android 命令行工具
cd /opt
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip
mkdir -p android-sdk/cmdline-tools
mv cmdline-tools android-sdk/cmdline-tools/latest

# 设置环境变量
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# 接受许可并安装
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 编译
cd /root/.copaw/xplan/flutter_app
flutter build apk --release

# 输出位置
ls -la build/app/outputs/flutter-apk/
```

### 方案 3: macOS/iOS 版本（需要 Mac）

在 Mac 电脑上：

```bash
# 安装 Xcode
xcode-select --install

# 克隆项目
git clone <repo-url>
cd flutter_app

# 编译 macOS
flutter build macos --release

# 编译 iOS
flutter build ios --release

# 输出位置
# macOS: build/macos/Build/Products/Release/
# iOS: build/ios/iphoneos/
```

### 方案 4: Windows 版本（需要 Windows）

在 Windows 电脑上：

```powersl
# 安装 Visual Studio 2022
# 勾选 "使用 C++ 的桌面开发"

# 克隆项目
git clone <repo-url>
cd flutter_app

# 编译
flutter build windows --release

# 输出位置
# build/windows/runner/Release/
```

---

## 🌐 云编译方案

### GitHub Actions (推荐)

创建 `.github/workflows/build.yml`:

```yaml
name: Build All Platforms

on:
  push:
    tags:
      - 'v*'

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build web --release
      - uses: actions/upload-artifact@v4
        with:
          name: web-release
          path: build/web/

  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: sudo apt-get install -y cmake ninja-build clang gtk3-devel
      - run: flutter build linux --release
      - uses: actions/upload-artifact@v4
        with:
          name: linux-release
          path: build/linux/x64/release/bundle/

  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: build/app/outputs/flutter-apk/

  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build macos --release
      - uses: actions/upload-artifact@v4
        with:
          name: macos-release
          path: build/macos/Build/Products/Release/

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build windows --release
      - uses: actions/upload-artifact@v4
        with:
          name: windows-release
          path: build/windows/runner/Release/
```

### Codemagic (Flutter 专用 CI/CD)

访问：https://codemagic.io/

1. 连接 GitHub 仓库
2. 自动检测 Flutter 项目
3. 配置构建平台
4. 自动编译和分发

---

## 📦 分发包制作

### Linux

```bash
cd build/linux/x64/release/bundle/
tar -czf xplan-linux-x64-v1.0.0.tar.gz *
```

### Web

```bash
cd build/web/
zip -r xplan-web-v1.0.0.zip *
```

### Android

```bash
cd build/app/outputs/flutter-apk/
cp app-release.apk xplan-android-v1.0.0.apk
```

### macOS

```bash
cd build/macos/Build/Products/Release/
ditto -c -k --sequesterRsrc --keepParent XPlan.app xplan-macos-v1.0.0.zip
```

### Windows

```powershell
cd build/windows/runner/Release/
Compress-Archive -Path * -DestinationPath xplan-windows-v1.0.0.zip
```

---

## 📊 当前状态总结

| 平台 | 环境要求 | 当前状态 | 建议 |
|------|---------|---------|------|
| Web | ✅ 无 | ✅ 已完成 | 立即可用 |
| Linux | CMake+Ninja+GTK | ⏳ 待安装 | 推荐安装 |
| Android | Android SDK | ⏳ 待安装 | 可选 |
| macOS | macOS + Xcode | ❌ 不支持 | 需 Mac |
| iOS | macOS + Xcode | ❌ 不支持 | 需 Mac |
| Windows | Windows + VS | ❌ 不支持 | 需 Windows |

---

## 🎯 推荐方案

### 立即历史

1. **Web 版本** - 已完成 ✅
2. **Linux 版本** - 安装依赖后编译
3. **其他平台** - 使用 GitHub Actions 云编译

### 长期方案

1. 配置 GitHub Actions 自动编译所有平台
2. 使用 Codemagic 专业 Flutter CI/CD
3. 在对应平台电脑上本地编译

---

**最后更新**: 2026-03-09  
**XPlan Team**
