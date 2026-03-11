# XPlan v1.1.0 发布说明

**发布日期**: 2026 年 3 月 11 日
**版本**: v1.1.0
**状态**: 🚀 编译中

---

## 🎉 新功能

### 1. 设置页面 ✨
- **主题切换** - 支持浅色/深色/跟随系统三种模式
- **API 配置** - 可自定义 COPAW API 地址
- **关于页面** - 展示应用信息、版本、功能特性和技术栈

### 2. 会话管理 📋
- **会话列表** - 显示所有历史会话
- **切换会话** - 点击即可切换到指定会话
- **删除会话** - 左滑删除或菜单删除，带确认对话框
- **重命名会话** - 自定义会话名称
- **本地缓存** - 会话列表自动缓存到本地

### 3. 消息历史记录 💾
- **自动保存** - 发送的消息自动保存到本地
- **历史加载** - 切换会话时自动加载历史消息
- **持久化存储** - 使用 SharedPreferences 存储

### 4. 用户系统 👤
- **邮箱登录** - 使用邮箱和密码登录
- **用户注册** - 创建新账号
- **用户信息** - 显示用户名、邮箱、头像
- **登出功能** - 安全退出登录
- **状态持久化** - 登录状态本地保存

### 5. 使用统计 📊
- **今日使用** - 显示今日已使用次数
- **字数限制** - 显示单次字数限制
- **会员状态** - 展示会员信息和有效期
- **使用说明** - 免费/付费功能说明

---

## 🐛 Bug 修复

| 问题 | 修复内容 |
|------|---------|
| `usage_limit_service.dart` | 修复字符串插值语法错误 |
| `paywall_screen.dart` | 添加缺失的 `createState` 方法和动画控制器 |
| `subscription_provider.dart` | 修复导入路径问题 |

---

## 📁 新增文件

### 数据模型 (models/)
- `conversation.dart` - 会话数据模型
- `settings.dart` - 应用设置模型
- `user.dart` - 用户数据模型

### 服务层 (services/)
- `auth_service.dart` - 用户认证服务
- `conversation_service.dart` - 会话管理服务
- `message_history_service.dart` - 消息历史服务
- `settings_service.dart` - 设置持久化服务

### 状态管理 (providers/)
- `auth_provider.dart` - 认证状态管理
- `conversation_provider.dart` - 会话状态管理
- `settings_provider.dart` - 设置状态管理

### 页面 (screens/)
- `login_page.dart` - 登录页面
- `register_page.dart` - 注册页面
- `settings_page.dart` - 设置主页面
- `conversation_list_page.dart` - 会话列表页面
- `usage_stats_page.dart` - 使用统计页面
- `about_page.dart` - 关于页面
- `api_config_page.dart` - API 配置页面

---

## 🔧 技术变更

### 依赖
无需新增依赖，使用现有：
- `provider` - 状态管理
- `shared_preferences` - 本地存储

### API 变更
无破坏性变更，所有现有 API 保持兼容。

---

## 📱 支持平台

| 平台 | 状态 | 编译命令 |
|------|------|---------|
| **Web** | ✅ 支持 | `flutter build web` |
| **Linux** | ✅ 支持 | `flutter build linux` |
| **Android** | ✅ 支持 | `flutter build apk` |
| **macOS** | ✅ 支持 | `flutter build macos` |
| **Windows** | ✅ 支持 | `flutter build windows` |
| **iOS** | ✅ 支持 | `flutter build ios` |

---

## 🚀 编译状态

### GitHub Actions 编译进度

| 平台 | 状态 | 耗时 |
|------|------|------|
| Web | ⏳ 等待中 | - |
| Linux | ⏳ 等待中 | - |
| Android | ⏳ 等待中 | - |
| macOS | ⏳ 等待中 | - |
| Windows | ⏳ 等待中 | - |
| iOS | ⏳ 等待中 | - |

**预计完成时间**: 10-15 分钟

---

## 📥 下载链接

编译完成后，下载链接将在此处显示：

- **Web**: [下载](#) (编译中)
- **Linux**: [下载](#) (编译中)
- **Android**: [下载](#) (编译中)
- **macOS**: [下载](#) (编译中)
- **Windows**: [下载](#) (编译中)
- **iOS**: [下载](#) (编译中)

---

## 📝 升级指南

### 从 v1.0.x 升级
- 所有用户数据保持兼容
- 无需额外操作，直接安装新版本

### 首次安装
1. 下载对应平台版本
2. 安装并运行
3. 登录或注册账号
4. 开始使用

---

## 🙏 致谢

感谢所有贡献者和用户的支持！

---

**XPlan Team** - 2026 年 3 月 11 日
