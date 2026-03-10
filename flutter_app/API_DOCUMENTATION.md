# AI 写作助手 - 后端 API 文档

**版本**: 1.0.0  
**框架**: Node.js + Express  
**数据库**: MongoDB / PostgreSQL

---

## 📡 API 端点

### 1. 用户相关

#### 1.1 创建/更新用户
```
POST /api/v1/user
```

**请求体**:
```json
{
  "openid": "wechat_openid_xxx",
  "nickname": "用户昵称",
  "avatar": "头像 URL"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "userId": "user_123456",
    "isPremium": false,
    "createdAt": "2026-03-11T00:00:00Z"
  }
}
```

#### 1.2 获取用户信息
```
GET /api/v1/user/:userId
```

**响应**:
```json
{
  "success": true,
  "data": {
    "userId": "user_123456",
    "nickname": "用户昵称",
    "avatar": "头像 URL",
    "isPremium": false,
    "subscription": {
      "planId": null,
      "expiresAt": null,
      "status": "inactive"
    },
    "usage": {
      "todayCount": 3,
      "dailyLimit": 5,
      "wordLimit": 300
    }
  }
}
```

---

### 2. 支付相关

#### 2.1 创建微信支付订单
```
POST /api/v1/pay/wechat/create
```

**请求体**:
```json
{
  "userId": "user_123456",
  "planId": "wechat_yearly",
  "orderId": "ORDER_1710123456789"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "appId": "wxXXXXXXXXXXXXXXXX",
    "partnerId": "1XXXXXXXXX",
    "prepayId": "wx201410272009395522657a690389285100",
    "package": "Sign=WXPay",
    "nonceStr": "5K8264ILTKCH16CQ2502SI8ZNMTM67VS",
    "timeStamp": "1414389088",
    "sign": "CBE7A8A6F5B8E5E5E5E5E5E5E5E5E5E5"
  }
}
```

#### 2.2 微信支付回调通知
```
POST /api/v1/pay/wechat/notify
```

**微信回调数据** (XML 格式):
```xml
<xml>
  <appid><![CDATA[wxXXXXXXXXXXXXXXXX]]></appid>
  <mch_id><![CDATA[1XXXXXXXXX]]></mch_id>
  <nonce_str><![CDATA[xxx]]></nonce_str>
  <openid><![CDATA[user_openid]]></openid>
  <out_trade_no><![CDATA[ORDER_1710123456789]]></out_trade_no>
  <result_code><![CDATA[SUCCESS]]></result_code>
  <total_fee>19900</total_fee>
  <transaction_id><![CDATA[1234567890]]></transaction_id>
</xml>
```

**处理逻辑**:
1. 验证签名
2. 更新订单状态
3. 激活用户订阅
4. 返回成功响应

**响应**:
```xml
<xml>
  <return_code><![CDATA[SUCCESS]]></return_code>
  <return_msg><![CDATA[OK]]></return_msg>
</xml>
```

#### 2.3 查询订单状态
```
GET /api/v1/order/:orderId
```

**响应**:
```json
{
  "success": true,
  "data": {
    "orderId": "ORDER_1710123456789",
    "userId": "user_123456",
    "planId": "wechat_yearly",
    "amount": 199.0,
    "status": "paid",
    "paidAt": "2026-03-11T12:34:56Z"
  }
}
```

---

### 3. 订阅相关

#### 3.1 获取订阅状态
```
GET /api/v1/user/:userId/subscription
```

**响应**:
```json
{
  "success": true,
  "data": {
    "isPremium": true,
    "planId": "wechat_yearly",
    "planName": "高级会员 - 年度",
    "expiresAt": "2027-03-11T12:34:56Z",
    "isActive": true,
    "daysRemaining": 365
  }
}
```

#### 3.2 取消订阅
```
POST /api/v1/user/:userId/subscription/cancel
```

**请求体**:
```json
{
  "reason": "其他原因"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "cancelledAt": "2026-03-11T12:34:56Z",
    "expiresAt": "2027-03-11T12:34:56Z",
    "message": "订阅将在到期后取消，当前仍可使用至 2027-03-11"
  }
}
```

---

### 4. 使用统计

#### 4.1 获取使用统计
```
GET /api/v1/user/:userId/usage
```

**响应**:
```json
{
  "success": true,
  "data": {
    "today": {
      "count": 3,
      "limit": 5,
      "words": 850
    },
    "total": {
      "count": 128,
      "words": 45600
    },
    "history": [
      {
        "date": "2026-03-10",
        "count": 5,
        "words": 1500
      },
      {
        "date": "2026-03-09",
        "count": 4,
        "words": 1200
      }
    ]
  }
}
```

#### 4.2 记录使用
```
POST /api/v1/user/:userId/usage/record
```

**请求体**:
```json
{
  "action": "generate",
  "wordCount": 350,
  "feature": "article_generation"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "todayCount": 4,
    "remaining": 1
  }
}
```

---

### 5. AI 写作相关

#### 5.1 生成文章
```
POST /api/v1/ai/generate
```

**请求体**:
```json
{
  "userId": "user_123456",
  "type": "article",
  "topic": "人工智能的发展",
  "style": "formal",
  "length": 1000,
  "requirements": ["包含案例分析", "专业术语"]
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "id": "gen_123456",
    "content": "人工智能（AI）是当今科技领域最炙手可热的话题...",
    "wordCount": 1024,
    "createdAt": "2026-03-11T12:34:56Z"
  }
}
```

#### 5.2 润色文章
```
POST /api/v1/ai/polish
```

**请求体**:
```json
{
  "userId": "user_123456",
  "content": "原始文本...",
  "level": "advanced",
  "tone": "professional"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "original": "原始文本...",
    "polished": "润色后的文本...",
    "changes": [
      {
        "type": "grammar",
        "original": "这个",
        "polished": "此项"
      }
    ]
  }
}
```

#### 5.3 多语言翻译
```
POST /api/v1/ai/translate
```

**请求体**:
```json
{
  "userId": "user_123456",
  "content": "中文内容...",
  "sourceLang": "zh",
  "targetLang": "en"
}
```

**响应**:
```json
{
  "success": true,
  "data": {
    "original": "中文内容...",
    "translated": "Chinese content...",
    "sourceLang": "zh",
    "targetLang": "en"
  }
}
```

---

## 🔐 安全认证

### API 密钥认证

所有请求需要在 Header 中包含 API 密钥：

```
Authorization: Bearer YOUR_API_KEY
```

### 微信支付签名验证

```javascript
// 验证微信回调签名
function verifyWechatSignature(payload, signature) {
  const crypto = require('crypto');
  const hash = crypto.createHmac('sha256', apiKey)
                     .update(payload)
                     .digest('hex')
                     .toUpperCase();
  return hash === signature;
}
```

---

## 📊 错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 429 | 请求次数超限 |
| 500 | 服务器内部错误 |

**错误响应格式**:
```json
{
  "success": false,
  "error": {
    "code": 400,
    "message": "参数错误：缺少必需字段 userId",
    "details": {}
  }
}
```

---

## 🗄️ 数据库设计

### 用户表 (users)

```sql
CREATE TABLE users (
  id VARCHAR(64) PRIMARY KEY,
  openid VARCHAR(128) UNIQUE,
  nickname VARCHAR(64),
  avatar VARCHAR(256),
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 订阅表 (subscriptions)

```sql
CREATE TABLE subscriptions (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) REFERENCES users(id),
  plan_id VARCHAR(32),
  plan_name VARCHAR(64),
  amount DECIMAL(10,2),
  start_at TIMESTAMP,
  expires_at TIMESTAMP,
  status VARCHAR(16), -- active, cancelled, expired
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 订单表 (orders)

```sql
CREATE TABLE orders (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) REFERENCES users(id),
  plan_id VARCHAR(32),
  amount DECIMAL(10,2),
  status VARCHAR(16), -- pending, paid, failed, refunded
  wechat_order_no VARCHAR(64),
  paid_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 使用记录表 (usage_records)

```sql
CREATE TABLE usage_records (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) REFERENCES users(id),
  action VARCHAR(32),
  word_count INTEGER,
  feature VARCHAR(32),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🚀 快速开始

### 1. 安装依赖

```bash
npm install express mongoose jsonwebtoken bcrypt cors helmet
```

### 2. 启动服务器

```bash
node server.js
```

### 3. 测试 API

```bash
curl -X GET http://localhost:3000/api/v1/health
```

---

**文档版本**: 1.0  
**最后更新**: 2026 年 3 月 11 日
