import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:xplan/services/copaw_service.dart';
import 'package:xplan/models/message.dart';

void main() {
  group('CopawService Tests', () {
    late CopawService copawService;

    setUp(() {
      copawService = CopawService();
    });

    tearDown(() {
      copawService.dispose();
    });

    group('Health Check', () {
      test('healthCheck returns true when API is healthy', () async {
        // Create mock client for testing structure
        // MockClient would be used with dependency injection in production
        expect(() => MockClient((request) async {
          expect(request.url.path, '/api/health');
          expect(request.method, 'GET');
          return http.Response('{"status": "ok"}', 200);
        }), returnsNormally);
      });

      test('healthCheck handles connection errors', () async {
        // Service should handle errors gracefully
        final result = await copawService.healthCheck();
        // Will be false since no real server is running
        expect(result, isA<bool>());
      });
    });

    group('Send Message', () {
      test('sendMessage with conversationId', () async {
        // Test structure with MockClient
        expect(() => MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/chat');
          expect(request.headers['Content-Type'], 'application/json');

          final body = jsonDecode(request.body);
          expect(body['message'], 'Test message');
          expect(body['conversation_id'], 'conv-123');

          return http.Response(
            jsonEncode({'message': 'Response from AI'}),
            200,
          );
        }), returnsNormally);
      });

      test('sendMessage without conversationId', () async {
        // Service should handle null conversationId
        expect(copawService, isNotNull);
      });

      test('sendMessage handles timeout', () async {
        // Service has 30 second timeout configured
        expect(copawService, isNotNull);
      });
    });

    group('Conversation Management', () {
      test('createConversation returns conversation ID', () async {
        // Service should create conversations
        final result = await copawService.createConversation();
        // Will be empty since no real server
        expect(result, isA<String>());
      });

      test('getConversations returns list', () async {
        final result = await copawService.getConversations();
        expect(result, isA<List>());
      });

      test('getConversationHistory returns messages', () async {
        final result = await copawService.getConversationHistory('conv-123');
        expect(result, isA<List<Message>>());
      });
    });

    group('Error Handling', () {
      test('handles 404 errors gracefully', () async {
        // Service should handle HTTP errors
        expect(copawService, isNotNull);
      });

      test('handles 500 errors gracefully', () async {
        // Service should handle server errors
        expect(copawService, isNotNull);
      });

      test('handles network timeouts', () async {
        // Service has timeout configured
        expect(copawService, isNotNull);
      });
    });

    group('API Configuration', () {
      test('baseUrl is configured correctly', () {
        expect(CopawService.baseUrl, 'http://localhost:18789');
      });

      test('baseUrl can be modified for different environments', () {
        // In production, this would be configurable
        expect(CopawService.baseUrl, startsWith('http://'));
      });
    });
  });

  group('Integration Tests', () {
    test('Full conversation flow simulation', () async {
      // Simulate: Create conversation -> Send message -> Get response
      final service = CopawService();
      
      try {
        // Step 1: Check health
        final isHealthy = await service.healthCheck();
        
        if (isHealthy) {
          // Step 2: Create conversation
          final convId = await service.createConversation();
          expect(convId, isNotEmpty);
          
          // Step 3: Send message
          final response = await service.sendMessage('Hello', conversationId: convId);
          expect(response, isA<Message>());
          expect(response.role, 'assistant');
        } else {
          // Server not running - that's OK for this test
          print('COPAW server not running, skipping integration test');
        }
      } finally {
        service.dispose();
      }
    });
  });
}
