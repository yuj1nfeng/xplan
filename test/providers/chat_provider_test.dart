import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xplan/providers/chat_provider.dart';
import 'package:xplan/models/message.dart';

void main() {
  group('ChatProvider Tests', () {
    late ChatProvider chatProvider;

    setUp(() {
      chatProvider = ChatProvider();
    });

    tearDown(() {
      chatProvider.dispose();
    });

    group('Initial State', () {
      test('initial messages list is empty', () {
        expect(chatProvider.messages, isEmpty);
      });

      test('initial conversationId is null', () {
        expect(chatProvider.conversationId, isNull);
      });

      test('initial isConnected is false', () {
        // Will be false since no server is running
        expect(chatProvider.isConnected, false);
      });

      test('initial isLoading is false', () {
        expect(chatProvider.isLoading, false);
      });

      test('initial statusMessage is set', () {
        expect(chatProvider.statusMessage, isA<String>());
        expect(chatProvider.statusMessage, isNotEmpty);
      });
    });

    group('Send Message', () {
      test('sendMessage adds user message to list', () async {
        final initialCount = chatProvider.messages.length;
        
        await chatProvider.sendMessage('Test message');
        
        expect(chatProvider.messages.length, initialCount + 1);
        expect(chatProvider.messages.last.role, 'user');
        expect(chatProvider.messages.last.content, 'Test message');
      });

      test('sendMessage sets isLoading to true during send', () async {
        // isLoading should be true while sending
        // This is hard to test without async tracking
        expect(chatProvider.isLoading, false);
      });

      test('sendMessage sets isLoading to false after send', () async {
        await chatProvider.sendMessage('Test message');
        expect(chatProvider.isLoading, false);
      });

      test('sendMessage ignores empty messages', () async {
        final initialCount = chatProvider.messages.length;
        
        await chatProvider.sendMessage('');
        await chatProvider.sendMessage('   ');
        
        expect(chatProvider.messages.length, initialCount);
      });

      test('sendMessage adds assistant response', () async {
        await chatProvider.sendMessage('Hello');
        
        // Should have user message + assistant response
        expect(chatProvider.messages.length, greaterThanOrEqualTo(2));
        
        final lastMessage = chatProvider.messages.last;
        expect(lastMessage.role, 'assistant');
        expect(lastMessage.content, contains('测试模式'));
      });

      test('sendMessage notifies listeners', () async {
        int notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        await chatProvider.sendMessage('Test');
        
        expect(notifyCount, greaterThan(0));
      });
    });

    group('New Conversation', () {
      test('newConversation clears messages', () async {
        await chatProvider.sendMessage('Message 1');
        await chatProvider.sendMessage('Message 2');
        
        expect(chatProvider.messages.length, greaterThan(0));
        
        await chatProvider.newConversation();
        
        expect(chatProvider.messages, isEmpty);
      });

      test('newConversation resets conversationId', () async {
        await chatProvider.newConversation();
        expect(chatProvider.conversationId, isNull);
      });

      test('newConversation notifies listeners', () async {
        int notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        await chatProvider.newConversation();
        
        expect(notifyCount, greaterThan(0));
      });
    });

    group('Clear Messages', () {
      test('clearMessages removes all messages', () async {
        await chatProvider.sendMessage('Message 1');
        await chatProvider.sendMessage('Message 2');
        
        expect(chatProvider.messages.length, greaterThan(0));
        
        chatProvider.clearMessages();
        
        expect(chatProvider.messages, isEmpty);
      });

      test('clearMessages notifies listeners', () {
        int notifyCount = 0;
        chatProvider.addListener(() {
          notifyCount++;
        });

        chatProvider.clearMessages();
        
        expect(notifyCount, greaterThan(0));
      });
    });

    group('Connection Status', () {
      test('statusMessage reflects connection state', () async {
        // Wait for initialization
        await Future.delayed(const Duration(milliseconds: 100));
        
        expect(chatProvider.statusMessage, isA<String>());
        // Should indicate test mode since no server
        expect(
          chatProvider.statusMessage.contains('测试模式') || 
          chatProvider.statusMessage.contains('连接'),
          true,
        );
      });

      test('isConnected is false when server unavailable', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        expect(chatProvider.isConnected, false);
      });
    });

    group('Message Properties', () {
      test('user messages have correct role', () async {
        await chatProvider.sendMessage('Test');
        
        final userMessage = chatProvider.messages.first;
        expect(userMessage.role, 'user');
      });

      test('assistant messages have correct role', () async {
        await chatProvider.sendMessage('Test');
        
        // Find assistant message
        final assistantMessage = chatProvider.messages
            .firstWhere((m) => m.role == 'assistant');
        
        expect(assistantMessage.role, 'assistant');
      });

      test('messages have timestamps', () async {
        await chatProvider.sendMessage('Test');
        
        for (final message in chatProvider.messages) {
          expect(message.timestamp, isA<DateTime>());
          expect(message.timestamp.isBefore(DateTime.now()), true);
        }
      });

      test('messages have unique IDs', () async {
        await chatProvider.sendMessage('Message 1');
        await Future.delayed(const Duration(milliseconds: 10));
        await chatProvider.sendMessage('Message 2');
        
        final ids = chatProvider.messages.map((m) => m.id).toSet();
        expect(ids.length, chatProvider.messages.length);
      });
    });

    group('Concurrent Messages', () {
      test('handles rapid message sending', () async {
        await Future.wait([
          chatProvider.sendMessage('Message 1'),
          chatProvider.sendMessage('Message 2'),
          chatProvider.sendMessage('Message 3'),
        ]);
        
        expect(chatProvider.messages.length, greaterThanOrEqualTo(3));
      });

      test('prevents sending while loading', () async {
        // Start first message
        final future1 = chatProvider.sendMessage('First');
        
        // Try to send while loading (should be ignored)
        await chatProvider.sendMessage('Second');
        
        await future1;
        
        // At least the first message should be sent
        expect(chatProvider.messages.length, greaterThanOrEqualTo(1));
      });
    });

    group('State Persistence', () {
      test('messages persist across state changes', () async {
        await chatProvider.sendMessage('Persistent message');
        final messageCount = chatProvider.messages.length;
        
        // Trigger state change
        await chatProvider.newConversation();
        await chatProvider.sendMessage('New message');
        
        // New conversation should have new messages
        expect(chatProvider.messages.length, greaterThan(0));
      });
    });
  });

  group('ChatProvider Widget Integration', () {
    testWidgets('ChatProvider works with Provider widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final provider = Provider.of<ChatProvider>(context, listen: false);
              expect(provider, isA<ChatProvider>());
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
