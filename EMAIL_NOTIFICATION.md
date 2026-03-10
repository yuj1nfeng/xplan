# 📧 XPlan 邮件通知配置

**用户邮箱**: 296519653@qq.com  
**配置日期**: 2026-03-09  
**状态**: ⏳ 待配置邮件服务

---

## 📋 通知场景

### 1. Release 发布通知

**触发条件**: GitHub Actions 编译完成  
**发送内容**:
- Release 版本号
- 所有平台下载链接
- 编译状态报告
- 测试报告摘要

### 2. 版本更新通知

**触发条件**: 新 tag 推送  
**发送内容**:
- 更新日志
- 变更说明
- 下载链接

---

## 🔧 配置方案

### 方案 1: 使用 QQ 邮箱 SMTP（推荐）

**QQ 邮箱 SMTP 配置**:

```toml
# ~/.config/himalaya/config.toml
[qq]
display-name = "XPlan Bot"
email = "296519653@qq.com"

[qq.smtp]
host = "smtp.qq.com"
port = 587
login = "296519653@qq.com"
password = "SMTP_AUTH_CODE"  # QQ 邮箱授权码

[qq.imap]
host = "imap.qq.com"
port = 993
login = "296519653@qq.com"
password = "SMTP_AUTH_CODE"
```

**获取 QQ 邮箱授权码**:
1. 登录 QQ 邮箱网页版
2. 设置 → 账户
3. 开启 POP3/SMTP/IMAP 服务
4. 生成授权码

---

### 方案 2: 使用 Python smtplib（简单）

创建发送邮件的 Python 脚本：

```python
#!/usr/bin/env python3
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_release_email(version, download_links):
    msg = MIMEMultipart()
    msg['From'] = 'XPlan Bot <noreply@xplan.dev>'
    msg['To'] = '296519653@qq.com'
    msg['Subject'] = f'[XPlan Release] {version} 发布通知'
    
    body = f"""
    <html>
    <body>
        <h2>🎉 XPlan {version} 发布通知</h2>
        <p>GitHub Actions 编译已完成！</p>
        <h3>下载链接:</h3>
        <ul>
            {download_links}
        </ul>
        <p><strong>XPlan Team</strong></p>
    </body>
    </html>
    """
    
    msg.attach(MIMEText(body, 'html'))
    
    # 使用 QQ 邮箱 SMTP
    server = smtplib.SMTP('smtp.qq.com', 587)
    server.starttls()
    server.login('296519653@qq.com', 'SMTP_AUTH_CODE')
    server.send_message(msg)
    server.quit()
    
    print("✅ 邮件发送成功！")
```

---

### 方案 3: GitHub Actions 自动发送邮件

在 `.github/workflows/build-all-platforms.yml` 中添加邮件通知步骤：

```yaml
- name: Send Email Notification
  if: success()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.qq.com
    server_port: 587
    username: ${{ secrets.EMAIL_USER }}
    password: ${{ secrets.EMAIL_PASS }}
    subject: '[XPlan Release] ${{ github.ref_name }} 发布通知'
    to: 296519653@qq.com
    from: 'XPlan Bot'
    body: |
      🎉 XPlan ${{ github.ref_name }} 发布通知
      
      GitHub Actions 编译已完成！
      
      下载链接:
      https://github.com/yuj1nfeng/xplan/releases/tag/${{ github.ref_name }}
      
      XPlan Team
```

---

## 📊 当前状态

| 项目 | 状态 | 说明 |
|------|------|------|
| **邮箱地址** | ✅ 已记录 | 296519653@qq.com |
| **邮件工具** | ⏳ 待安装 | himalaya 或 Python |
| **SMTP 配置** | ⏳ 待配置 | 需要 QQ 邮箱授权码 |
| **GitHub Actions** | ⏳ 编译中 | 完成后触发邮件 |

---

## 🚀 下一步

### 立即执行

1. **获取 QQ 邮箱授权码**
   - 登录 QQ 邮箱
   - 设置 → 账户
   - 开启 SMTP 服务
   - 获取授权码

2. **配置邮件发送**
   - 提供授权码
   - 我帮你配置 himalaya
   - 或配置 GitHub Actions

3. **等待编译完成**
   - 查看：https://github.com/yuj1nfeng/xplan/actions
   - 预计：15-30 分钟

4. **自动发送邮件**
   - 编译完成后
   - 发送到：296519653@qq.com
   - 包含所有下载链接

---

## 📧 邮件模板

### Release 通知邮件

```
主题：[XPlan Release] v1.0.0 发布通知 - 2026-03-09

🎉 XPlan v1.0.0 发布通知

亲爱的开发者，

XPlan Flutter 跨平台客户端 v1.0.0 已编译完成！

📦 可用平台:
✅ Web - 立即可用
✅ Linux - 立即可用
✅ Android - 编译完成
✅ macOS - 编译完成
✅ Windows - 编译完成
✅ iOS - 编译完成

📥 下载链接:
https://github.com/yuj1nfeng/xplan/releases/tag/v1.0.0

📊 测试报告:
- 测试用例：83 个
- 通过率：94%
- 代码覆盖率：97%

🚀 使用指南:
查看 README.md 了解安装和使用说明

XPlan Team
2026-03-09
```

---

## ⚙️ 配置命令

### 安装 himalaya

```bash
curl --proto '=https' --tlsv1.2 -sSf https://himalaya-rs.github.io/cli/install.sh | sh
```

### 配置邮箱

```bash
himalaya config
# 按提示输入 QQ 邮箱和授权码
```

### 测试发送

```bash
echo "测试邮件" | himalaya send --to 296519653@qq.com --subject "XPlan 测试邮件"
```

---

**请提供 QQ 邮箱授权码**，我帮你完成邮件配置！📧

---

**XPlan Team** - 2026-03-09
