import { useState, useEffect, useRef } from 'react';
import { copawService } from '../services/copaw';
import './Chat.css';

function Chat() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [conversationId, setConversationId] = useState(null);
  const [status, setStatus] = useState('connecting'); // connecting, connected, error
  const messagesEndRef = useRef(null);

  // 滚动到底部
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  // 检查服务状态
  useEffect(() => {
    checkServiceStatus();
  }, []);

  const checkServiceStatus = async () => {
    try {
      await copawService.healthCheck();
      setStatus('connected');
      // 创建新会话
      const conv = await copawService.createConversation();
      setConversationId(conv.id);
    } catch (error) {
      setStatus('error');
      console.error('服务连接失败:', error);
    }
  };

  // 发送消息
  const sendMessage = async (e) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage = input.trim();
    setInput('');
    setIsLoading(true);

    // 添加用户消息到列表
    setMessages(prev => [...prev, { 
      id: Date.now(), 
      role: 'user', 
      content: userMessage,
      timestamp: new Date().toISOString()
    }]);

    try {
      const response = await copawService.sendMessage(userMessage, conversationId);
      
      // 添加 AI 回复到列表
      setMessages(prev => [...prev, { 
        id: Date.now() + 1, 
        role: 'assistant', 
        content: response.message || response.content || response.reply || '收到消息',
        timestamp: new Date().toISOString()
      }]);
    } catch (error) {
      // 如果 API 失败，显示模拟回复用于测试
      setMessages(prev => [...prev, { 
        id: Date.now() + 1, 
        role: 'assistant', 
        content: `[测试模式] 收到你的消息：${userMessage}\n\n注意：COPAW 服务 (端口 18789) 可能未启动或 API 路径不匹配。`,
        timestamp: new Date().toISOString()
      }]);
    } finally {
      setIsLoading(false);
    }
  };

  // 新建会话
  const newConversation = async () => {
    try {
      const conv = await copawService.createConversation();
      setConversationId(conv.id);
      setMessages([]);
    } catch (error) {
      setConversationId(null);
      setMessages([]);
    }
  };

  return (
    <div className="chat-container">
      {/* 头部 */}
      <div className="chat-header">
        <h1>🚀 XPlan - COPAW 客户端</h1>
        <div className="status-indicator">
          <span className={`status-dot ${status}`}></span>
          <span className="status-text">
            {status === 'connecting' && '连接中...'}
            {status === 'connected' && '已连接'}
            {status === 'error' && '连接失败'}
          </span>
        </div>
        <button onClick={newConversation} className="new-chat-btn">
          + 新对话
        </button>
      </div>

      {/* 消息列表 */}
      <div className="messages-container">
        {messages.length === 0 ? (
          <div className="welcome-message">
            <h2>👋 欢迎使用 XPlan</h2>
            <p>这是 COPAW 的跨平台客户端 H5 版本</p>
            <p>在下方输入消息开始对话</p>
          </div>
        ) : (
          messages.map((msg) => (
            <div key={msg.id} className={`message ${msg.role}`}>
              <div className="message-avatar">
                {msg.role === 'user' ? '👤' : '🤖'}
              </div>
              <div className="message-content">
                <div className="message-text">{msg.content}</div>
                <div className="message-time">
                  {new Date(msg.timestamp).toLocaleTimeString()}
                </div>
              </div>
            </div>
          ))
        )}
        
        {isLoading && (
          <div className="message assistant">
            <div className="message-avatar">🤖</div>
            <div className="message-content">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      {/* 输入区域 */}
      <form className="input-container" onSubmit={sendMessage}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="输入消息..."
          disabled={isLoading || status === 'error'}
          className="message-input"
        />
        <button 
          type="submit" 
          disabled={isLoading || !input.trim() || status === 'error'}
          className="send-button"
        >
          {isLoading ? '发送中...' : '发送'}
        </button>
      </form>
    </div>
  );
}

export default Chat;
