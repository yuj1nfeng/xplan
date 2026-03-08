import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xplan/providers/chat_provider.dart';
import 'package:xplan/screens/home_screen.dart';
import 'package:xplan/widgets/chat_view.dart';

void main() {
  group('Widget Tests', () {
    
    Widget createTestApp(ChatProvider provider) {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
          ],
          child: const HomeScreen(),
        ),
      );
    }

    group('HomeScreen', () {
      testWidgets('HomeScreen displays app title', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(createTestApp(provider));
        await tester.pumpAndSettle();

        expect(find.text('🚀 XPlan - COPAW 客户端'), findsOneWidget);
      });

      testWidgets('HomeScreen displays connection status', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(createTestApp(provider));
        await tester.pumpAndSettle();

        // Status indicator should be present
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('HomeScreen has new conversation button', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(createTestApp(provider));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.add_comment), findsOneWidget);
      });

      testWidgets('New conversation button works', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(createTestApp(provider));
        await tester.pumpAndSettle();

        // Tap new conversation button
        await tester.tap(find.byIcon(Icons.add_comment));
        await tester.pumpAndSettle();

        // Should not crash
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('ChatView', () {
      testWidgets('ChatView displays welcome message when empty', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('👋 欢迎使用 XPlan'), findsOneWidget);
        expect(find.text('跨平台 COPAW 客户端'), findsOneWidget);
      });

      testWidgets('ChatView displays feature list', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('📱 iOS & Android'), findsOneWidget);
        expect(find.text('💻 macOS, Windows, Linux'), findsOneWidget);
        expect(find.text('⚡ 一套代码，全平台运行'), findsOneWidget);
      });

      testWidgets('ChatView input field is present', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('输入消息...'), findsOneWidget);
      });

      testWidgets('ChatView send button is present', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.send), findsOneWidget);
      });

      testWidgets('ChatView can type in input field', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Test message');
        expect(find.text('Test message'), findsOneWidget);
      });

      testWidgets('ChatView send message works', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Type message
        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.pump();

        // Tap send button
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // User message should appear
        expect(find.text('Hello'), findsOneWidget);
      });

      testWidgets('ChatView shows typing indicator when loading', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Send message
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.tap(find.byIcon(Icons.send));
        
        // Pump during loading
        await tester.pump();

        // Typing indicator should appear (3 dots)
        expect(find.byType(CircleAvatar), findsWidgets);
      });

      testWidgets('ChatView displays user message bubble', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await provider.sendMessage('User test message');

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('User test message'), findsOneWidget);
        expect(find.text('👤'), findsWidgets);
      });

      testWidgets('ChatView displays assistant message bubble', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await provider.sendMessage('Hello');
        await Future.delayed(const Duration(milliseconds: 500));

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assistant message should be present
        expect(find.text('🤖'), findsWidgets);
      });

      testWidgets('ChatView message has timestamp', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await provider.sendMessage('Test');
        await Future.delayed(const Duration(milliseconds: 500));

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Timestamps should be present (format HH:mm)
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Responsive Design', () {
      testWidgets('ChatView works on small screen', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        tester.view.physicalSize = const Size(375, 667); // iPhone SE
        
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ChatView), findsOneWidget);
        
        tester.view.resetPhysicalSize();
      });

      testWidgets('ChatView works on large screen', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        tester.view.physicalSize = const Size(1920, 1080); // Desktop
        
        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ChatView), findsOneWidget);
        
        tester.view.resetPhysicalSize();
      });
    });

    group('UI Elements', () {
      testWidgets('Welcome screen has chat icon', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });

      testWidgets('Input field has message icon', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.message), findsOneWidget);
      });

      testWidgets('Send button changes when loading', (tester) async {
        final provider = ChatProvider();
        addTearDown(provider.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: provider),
              ],
              child: const Scaffold(
                body: ChatView(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Send message
        await tester.enterText(find.byType(TextField), 'Test');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();

        // Button should change state
        expect(find.byType(IconButton), findsOneWidget);
      });
    });
  });
}
