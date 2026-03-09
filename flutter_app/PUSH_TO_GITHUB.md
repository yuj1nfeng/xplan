# 🚀 XPlan 推送到 GitHub 指南

**仓库地址**: https://github.com/yuj1nfeng/xplan

---

## ⚠️ 当前状态

- ✅ 代码已准备就绪
- ✅ Git 远程仓库已配置：`origin https://github.com/yuj1nfeng/xplan.git`
- ❌ 需要认证才能推送

---

## 🔐 推送方法（3 选 1）

### 方法 1: 使用 Personal Access Token（推荐）

#### 第 1 步：创建 Personal Access Token

1. 访问：https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 填写：
   - **Note**: XPlan Deploy
   - **Expiration**: 90 days 或 No expiration
   - **Select scopes**: 勾选 `repo` (全部权限)
4. 点击 "Generate token"
5. **复制 Token**（只显示一次！）格式类似：`ghp_xxxxxxxxxxxx`

#### 第 2 步：推送代码

```bash
cd /root/.copaw/xplan/flutter_app

# 方法 A: 使用 Token 推送（推荐）
git remote set-url origin https://yuj1nfeng:YOUR_TOKEN@github.com/yuj1nfeng/xplan.git
git push -u origin master
git push origin v1.0.0

# 方法 B: 临时使用 Token
git push https://yuj1nfeng:YOUR_TOKEN@github.com/yuj1nfeng/xplan.git master
git push https://yuj1nfeng:YOUR_TOKEN@github.com/yuj1nfeng/xplan.git v1.0.0
```

**注意**: 将 `YOUR_TOKEN` 替换为你的实际 Token

---

### 方法 2: 配置 SSH Key

#### 第 1 步：生成 SSH Key

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
# 一路回车
```

#### 第 2 步：添加 SSH Key 到 GitHub

1. 查看公钥：
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. 复制输出内容
3. 访问：https://github.com/settings/keys
4. 点击 "New SSH key"
5. 粘贴公钥，保存

#### 第 3 步：切换为 SSH 协议

```bash
cd /root/.copaw/xplan/flutter_app
git remote set-url origin git@github.com:yuj1nfeng/xplan.git
git push -u origin master
git push origin v1.0.0
```

---

### 方法 3: 手动在 GitHub 上传

1. 访问：https://github.com/yuj1nfeng/xplan
2. 点击 "uploading an existing file"
3. 拖拽整个项目文件夹
4. 点击 "Commit changes"
5. 手动创建 Release:
   - 访问：https://github.com/yuj1nfeng/xplan/releases/new
   - Tag version: `v1.0.0`
   - 上传构建产物

---

## 📦 推送后的操作

### 触发 GitHub Actions 编译

推送成功后，GitHub Actions 会自动开始编译：

1. 访问：https://github.com/yuj1nfeng/xplan/actions
2. 查看 "Build All Platforms" 工作流
3. 等待 15-30 分钟完成所有平台编译
4. 编译完成后在 Release 页面下载

### 查看编译产物

- **Web**: Actions → Artifacts → xplan-web-v1.0.0
- **Linux**: Actions → Artifacts → xplan-linux-v1.0.0
- **Android**: Actions → Artifacts → xplan-android-v1.0.0
- **macOS**: Actions → Artifacts → xplan-macos-v1.0.0
- **Windows**: Actions → Artifacts → xplan-windows-v1.0.0
- **iOS**: Actions → Artifacts → xplan-ios-v1.0.0

---

## 📧 配置邮件通知

### 安装 himalaya

```bash
curl --proto '=https' --tlsv1.2 -sSf https://himalaya-rs.github.io/cli/install.sh | sh
```

### 配置邮箱

编辑 `~/.config/himalaya/config.toml`:

```toml
[your-email-com]
display-name = "XPlan Bot"
email = "your-email@example.com"

[your-email-com.smtp]
host = "smtp.example.com"
port = 587
login = "your-email@example.com"
password = "your-password"

[your-email-com.imap]
host = "imap.example.com"
port = 993
login = "your-email@example.com"
password = "your-password"
```

### 发送通知

```bash
cd /root/.copaw/xplan/flutter_app
./scripts/send_release_email.sh your-email@example.com v1.0.0
```

---

## 🎯 快速命令汇总

```bash
# 进入项目目录
cd /root/.copaw/xplan/flutter_app

# 使用 Token 推送（替换 YOUR_TOKEN）
git remote set-url origin https://yuj1nfeng:YOUR_TOKEN@github.com/yuj1nfeng/xplan.git
git push -u origin master
git push origin v1.0.0

# 查看 Actions 状态
# 访问：https://github.com/yuj1nfeng/xplan/actions

# 查看 Release
# 访问：https://github.com/yuj1nfeng/xplan/releases
```

---

## 📊 项目信息

- **仓库**: https://github.com/yuj1nfeng/xplan
- **版本**: v1.0.0
- **日期**: 2026-03-09
- **测试**: 83 个用例，94% 通过率
- **平台**: Web, Linux, Android, macOS, Windows, iOS

---

## ✅ 推送检查清单

- [ ] 创建 Personal Access Token
- [ ] 推送代码到 master
- [ ] 推送 Tag v1.0.0
- [ ] 查看 GitHub Actions 状态
- [ ] 等待编译完成（15-30 分钟）
- [ ] 下载所有平台版本
- [ ] 配置邮件通知
- [ ] 发送 Release 通知

---

**XPlan Team** - 2026-03-09
