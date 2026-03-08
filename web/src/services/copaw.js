import axios from 'axios';

// COPAW 本地服务配置
const API_BASE_URL = 'http://localhost:18789';

// 创建 axios 实例
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// COPAW API 服务
export const copawService = {
  // 发送消息
  sendMessage: async (message, conversationId = null) => {
    try {
      const response = await api.post('/api/chat', {
        message,
        conversation_id: conversationId,
      });
      return response.data;
    } catch (error) {
      console.error('发送消息失败:', error);
      throw error;
    }
  },

  // 获取会话列表
  getConversations: async () => {
    try {
      const response = await api.get('/api/conversations');
      return response.data;
    } catch (error) {
      console.error('获取会话列表失败:', error);
      throw error;
    }
  },

  // 创建新会话
  createConversation: async () => {
    try {
      const response = await api.post('/api/conversations');
      return response.data;
    } catch (error) {
      console.error('创建会话失败:', error);
      throw error;
    }
  },

  // 获取会话历史
  getConversationHistory: async (conversationId) => {
    try {
      const response = await api.get(`/api/conversations/${conversationId}/messages`);
      return response.data;
    } catch (error) {
      console.error('获取历史消息失败:', error);
      throw error;
    }
  },

  // 健康检查
  healthCheck: async () => {
    try {
      const response = await api.get('/api/health');
      return response.data;
    } catch (error) {
      console.error('健康检查失败:', error);
      throw error;
    }
  },
};

export default api;
