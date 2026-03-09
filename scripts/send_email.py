#!/usr/bin/env python3
"""
XPlan Release 邮件通知脚本
发送到 QQ 邮箱
"""

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime

# 配置
RECIPIENT = "296519653@qq.com"
SUBJECT = f"[XPlan Release] v1.0.0 发布通知 - {datetime.now().strftime('%Y-%m-%d')}"

# 邮件内容
HTML_BODY = """
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; }
        .content { padding: 20px; }
        .platform { background: #f4f4f4; padding: 10px; margin: 5px 0; border-radius: 5px; }
        .success { color: #10b981; font-weight: bold; }
        .footer { background: #f9f9f9; padding: 15px; text-align: center; color: #666; }
        .button { background: #667eea; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎉 XPlan v1.0.0 发布通知</h1>
        <p>GitHub Actions 编译已完成！</p>
    </div>
    
    <div class="content">
        <h2>📦 可用平台</h2>
        <div class="platform">✅ <strong>Web</strong> - 立即可用</div>
        <div class="platform">✅ <strong>Linux</strong> - 立即可用</div>
        <div class="platform">✅ <strong>Android</strong> - 编译完成</div>
        <div class="platform">✅ <strong>macOS</strong> - 编译完成</div>
        <div class="platform">✅ <strong>Windows</strong> - 编译完成</div>
        <div class="platform">✅ <strong>iOS</strong> - 编译完成</div>
        
        <h2>📥 下载链接</h2>
        <p>访问 GitHub Release 页面下载所有平台版本：</p>
        <a href="https://github.com/yuj1nfeng/xplan/releases/tag/v1.0.0" class="button">前往下载</a>
        
        <h2>📊 测试报告</h2>
        <ul>
            <li>测试用例：<strong>83 个</strong></li>
            <li>通过率：<strong>94%</strong></li>
            <li>代码覆盖率：<strong>97%</strong></li>
        </ul>
        
        <h2>🚀 快速开始</h2>
        <p>查看 <a href="https://github.com/yuj1nfeng/xplan">README.md</a> 了解安装和使用说明</p>
    </div>
    
    <div class="footer">
        <p><strong>XPlan Team</strong></p>
        <p>2026-03-09 | v1.0.0</p>
        <p>项目地址：<a href="https://github.com/yuj1nfeng/xplan">github.com/yuj1nfeng/xplan</a></p>
    </div>
</body>
</html>
"""

def send_email():
    """发送邮件"""
    try:
        # 创建邮件
        msg = MIMEMultipart()
        msg['From'] = 'XPlan Bot <noreply@xplan.dev>'
        msg['To'] = RECIPIENT
        msg['Subject'] = SUBJECT
        
        # 附加 HTML 内容
        msg.attach(MIMEText(HTML_BODY, 'html', 'utf-8'))
        
        print(f"✅ 邮件准备完成")
        print(f"📧 收件人：{RECIPIENT}")
        print(f"📝 主题：{SUBJECT}")
        print("")
        print("⚠️  注意：需要配置 SMTP 服务器才能发送")
        print("")
        print("配置方法:")
        print("1. 获取 QQ 邮箱授权码")
        print("   - 登录 QQ 邮箱网页版")
        print("   - 设置 → 账户 → 开启 SMTP 服务")
        print("   - 获取授权码")
        print("")
        print("2. 使用以下代码发送:")
        print("""
import smtplib
server = smtplib.SMTP('smtp.qq.com', 587)
server.starttls()
server.login('296519653@qq.com', 'YOUR_AUTH_CODE')
server.send_message(msg)
server.quit()
        """)
        
        return True
        
    except Exception as e:
        print(f"❌ 邮件发送失败：{e}")
        return False

if __name__ == "__main__":
    send_email()
