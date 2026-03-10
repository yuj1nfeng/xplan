// Node.js + Express 后端服务器示例
// 用于 AI 写作助手的微信支付和订阅管理

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(helmet());
app.use(express.json());
app.use(express.raw({ type: 'application/xml' })); // 微信支付回调需要

// 数据库连接
mongoose.connect('mongodb://localhost:27017/ai-writing', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// 配置
const config = {
  wechatPay: {
    appId: process.env.WECHAT_APP_ID || 'wxXXXXXXXXXXXXXXXX',
    mchId: process.env.WECHAT_MCH_ID || '1XXXXXXXXX',
    apiKey: process.env.WECHAT_API_KEY || 'XXXXXXXXXXXXXXXXXXXXXXXX',
    notifyUrl: process.env.WECHAT_NOTIFY_URL || 'https://your-domain.com/api/v1/pay/wechat/notify',
  },
  subscriptionPlans: {
    wechat_monthly: { price: 19.0, name: '高级会员 - 月度' },
    wechat_yearly: { price: 199.0, name: '高级会员 - 年度' },
    wechat_lifetime: { price: 599.0, name: '终身会员' },
    wechat_enterprise: { price: 299.0, name: '企业定制版' },
  },
};

// ==================== 数据库模型 ====================

const UserSchema = new mongoose.Schema({
  openid: { type: String, unique: true },
  nickname: String,
  avatar: String,
  isPremium: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

const SubscriptionSchema = new mongoose.Schema({
  userId: { type: String, ref: 'User' },
  planId: String,
  planName: String,
  amount: Number,
  startAt: Date,
  expiresAt: Date,
  status: { type: String, enum: ['active', 'cancelled', 'expired'] },
  createdAt: { type: Date, default: Date.now },
});

const OrderSchema = new mongoose.Schema({
  userId: String,
  planId: String,
  amount: Number,
  status: { type: String, enum: ['pending', 'paid', 'failed', 'refunded'] },
  wechatOrderNo: String,
  paidAt: Date,
  createdAt: { type: Date, default: Date.now },
});

const UsageRecordSchema = new mongoose.Schema({
  userId: String,
  action: String,
  wordCount: Number,
  feature: String,
  createdAt: { type: Date, default: Date.now },
});

const User = mongoose.model('User', UserSchema);
const Subscription = mongoose.model('Subscription', SubscriptionSchema);
const Order = mongoose.model('Order', OrderSchema);
const UsageRecord = mongoose.model('UsageRecord', UsageRecordSchema);

// ==================== 中间件 ====================

// API 密钥认证中间件
const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: { code: 401, message: '未授权' } });
  }
  
  const apiKey = authHeader.substring(7);
  // TODO: 验证 API 密钥有效性
  next();
};

// ==================== API 路由 ====================

// 健康检查
app.get('/api/v1/health', (req, res) => {
  res.json({ success: true, data: { status: 'ok', timestamp: new Date() } });
});

// 1. 用户相关

// 创建/更新用户
app.post('/api/v1/user', async (req, res) => {
  try {
    const { openid, nickname, avatar } = req.body;
    
    let user = await User.findOne({ openid });
    if (user) {
      user.nickname = nickname || user.nickname;
      user.avatar = avatar || user.avatar;
      user.updatedAt = new Date();
      await user.save();
    } else {
      user = await User.create({ openid, nickname, avatar });
    }
    
    res.json({
      success: true,
      data: {
        userId: user._id,
        isPremium: user.isPremium,
        createdAt: user.createdAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 获取用户信息
app.get('/api/v1/user/:userId', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ success: false, error: { code: 404, message: '用户不存在' } });
    }
    
    // 获取订阅信息
    const subscription = await Subscription.findOne({
      userId: req.params.userId,
      status: 'active',
      expiresAt: { $gt: new Date() },
    }).sort({ expiresAt: -1 });
    
    // 获取今日使用统计
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const todayUsage = await UsageRecord.countDocuments({
      userId: req.params.userId,
      createdAt: { $gte: today, $lt: tomorrow },
    });
    
    const isPremium = subscription && subscription.isActive;
    
    res.json({
      success: true,
      data: {
        userId: user._id,
        nickname: user.nickname,
        avatar: user.avatar,
        isPremium: isPremium,
        subscription: subscription ? {
          planId: subscription.planId,
          expiresAt: subscription.expiresAt,
          status: subscription.status,
        } : { planId: null, expiresAt: null, status: 'inactive' },
        usage: {
          todayCount: todayUsage,
          dailyLimit: isPremium ? null : 5,
          wordLimit: isPremium ? 5000 : 300,
        },
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 2. 支付相关

// 创建微信支付订单
app.post('/api/v1/pay/wechat/create', async (req, res) => {
  try {
    const { userId, planId, orderId } = req.body;
    
    // 验证套餐
    const plan = config.subscriptionPlans[planId];
    if (!plan) {
      return res.status(400).json({ success: false, error: { code: 400, message: '无效的套餐 ID' } });
    }
    
    // 创建订单
    const order = await Order.create({
      userId,
      planId,
      amount: plan.price,
      status: 'pending',
    });
    
    // TODO: 调用微信支付 API 创建预支付订单
    // 这里返回模拟的支付参数
    const payParams = {
      appId: config.wechatPay.appId,
      partnerId: config.wechatPay.mchId,
      prepayId: 'wx201410272009395522657a690389285100',
      package: 'Sign=WXPay',
      nonceStr: '5K8264ILTKCH16CQ2502SI8ZNMTM67VS',
      timeStamp: Math.floor(Date.now() / 1000).toString(),
      sign: crypto.createHmac('sha256', config.wechatPay.apiKey)
                   .update('simulated_data')
                   .digest('hex')
                   .toUpperCase(),
    };
    
    res.json({
      success: true,
      data: payParams,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 微信支付回调通知
app.post('/api/v1/pay/wechat/notify', async (req, res) => {
  try {
    // TODO: 验证微信签名
    // const isValid = verifyWechatSignature(req.body, req.headers['wechat-signature']);
    
    // 解析 XML 回调数据（示例使用模拟数据）
    const notification = {
      out_trade_no: 'ORDER_1710123456789',
      transaction_id: '1234567890',
      total_fee: 19900, // 单位：分
      result_code: 'SUCCESS',
    };
    
    if (notification.result_code === 'SUCCESS') {
      // 更新订单状态
      const order = await Order.findOneAndUpdate(
        { _id: notification.out_trade_no },
        {
          status: 'paid',
          wechatOrderNo: notification.transaction_id,
          paidAt: new Date(),
        }
      );
      
      if (order) {
        // 激活用户订阅
        const plan = config.subscriptionPlans[order.planId];
        const expiresAt = new Date();
        
        if (order.planId === 'wechat_monthly') {
          expiresAt.setMonth(expiresAt.getMonth() + 1);
        } else if (order.planId === 'wechat_yearly') {
          expiresAt.setFullYear(expiresAt.getFullYear() + 1);
        } else if (order.planId === 'wechat_lifetime') {
          expiresAt.setFullYear(expiresAt.getFullYear() + 50); // 终身 = 50 年
        }
        
        await Subscription.create({
          userId: order.userId,
          planId: order.planId,
          planName: plan.name,
          amount: order.amount,
          startAt: new Date(),
          expiresAt,
          status: 'active',
        });
        
        // 更新用户状态
        await User.findByIdAndUpdate(order.userId, { isPremium: true });
      }
    }
    
    // 返回成功响应给微信
    res.send(`
      <xml>
        <return_code><![CDATA[SUCCESS]]></return_code>
        <return_msg><![CDATA[OK]]></return_msg>
      </xml>
    `);
  } catch (error) {
    res.status(500).send(`
      <xml>
        <return_code><![CDATA[FAIL]]></return_code>
        <return_msg><![CDATA[${error.message}]]></return_msg>
      </xml>
    `);
  }
});

// 查询订单状态
app.get('/api/v1/order/:orderId', async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);
    if (!order) {
      return res.status(404).json({ success: false, error: { code: 404, message: '订单不存在' } });
    }
    
    res.json({
      success: true,
      data: {
        orderId: order._id,
        userId: order.userId,
        planId: order.planId,
        amount: order.amount,
        status: order.status,
        paidAt: order.paidAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 3. 订阅相关

// 获取订阅状态
app.get('/api/v1/user/:userId/subscription', async (req, res) => {
  try {
    const subscription = await Subscription.findOne({
      userId: req.params.userId,
      status: 'active',
      expiresAt: { $gt: new Date() },
    }).sort({ expiresAt: -1 });
    
    if (!subscription) {
      return res.json({
        success: true,
        data: {
          isPremium: false,
          planId: null,
          planName: null,
          expiresAt: null,
          isActive: false,
          daysRemaining: 0,
        },
      });
    }
    
    const daysRemaining = Math.floor(
      (subscription.expiresAt - new Date()) / (1000 * 60 * 60 * 24)
    );
    
    res.json({
      success: true,
      data: {
        isPremium: true,
        planId: subscription.planId,
        planName: subscription.planName,
        expiresAt: subscription.expiresAt,
        isActive: true,
        daysRemaining,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 取消订阅
app.post('/api/v1/user/:userId/subscription/cancel', async (req, res) => {
  try {
    const { reason } = req.body;
    
    await Subscription.updateMany(
      { userId: req.params.userId, status: 'active' },
      { status: 'cancelled' }
    );
    
    res.json({
      success: true,
      data: {
        cancelledAt: new Date(),
        message: '订阅已取消，但仍可使用至到期日',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 4. 使用统计

// 获取使用统计
app.get('/api/v1/user/:userId/usage', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    // 今日统计
    const todayRecords = await UsageRecord.find({
      userId: req.params.userId,
      createdAt: { $gte: today, $lt: tomorrow },
    });
    
    const todayCount = todayRecords.length;
    const todayWords = todayRecords.reduce((sum, r) => sum + (r.wordCount || 0), 0);
    
    // 总统计
    const totalRecords = await UsageRecord.find({ userId: req.params.userId });
    const totalCount = totalRecords.length;
    const totalWords = totalRecords.reduce((sum, r) => sum + (r.wordCount || 0), 0);
    
    // 历史记录（最近 7 天）
    const history = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);
      
      const dayRecords = await UsageRecord.find({
        userId: req.params.userId,
        createdAt: { $gte: date, $lt: nextDate },
      });
      
      history.push({
        date: date.toISOString().split('T')[0],
        count: dayRecords.length,
        words: dayRecords.reduce((sum, r) => sum + (r.wordCount || 0), 0),
      });
    }
    
    res.json({
      success: true,
      data: {
        today: { count: todayCount, limit: 5, words: todayWords },
        total: { count: totalCount, words: totalWords },
        history,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// 记录使用
app.post('/api/v1/user/:userId/usage/record', async (req, res) => {
  try {
    const { action, wordCount, feature } = req.body;
    
    await UsageRecord.create({
      userId: req.params.userId,
      action,
      wordCount,
      feature,
    });
    
    // 计算剩余次数
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    
    const todayCount = await UsageRecord.countDocuments({
      userId: req.params.userId,
      createdAt: { $gte: today, $lt: tomorrow },
    });
    
    res.json({
      success: true,
      data: {
        todayCount,
        remaining: Math.max(0, 5 - todayCount),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: { code: 500, message: error.message } });
  }
});

// ==================== 启动服务器 ====================

app.listen(PORT, () => {
  console.log(`🚀 AI 写作助手服务器已启动：http://localhost:${PORT}`);
  console.log(`📡 API 端点：http://localhost:${PORT}/api/v1/health`);
});

// 导出供其他模块使用
module.exports = app;
