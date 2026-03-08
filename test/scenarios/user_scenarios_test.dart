import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xplan/main.dart';
import 'package:xplan/providers/chat_provider.dart';

/// 场景测试 - 模拟真实用户使用场景
void main() {
  group('Scenario Tests - User Stories', () {
    
    testWidgets('Scenario 1: First-time user experience', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      expect(find.text('👋 欢迎使用 XPlan'), findsOneWidget);
      expect(find.text('跨平台 COPAW 客户端'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '你好');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.text('你好'), findsOneWidget);
    });

    testWidgets('Scenario 2: Continuous conversation', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      final messages = ['介绍你自己', '你能做什么？', '支持哪些平台？'];
      for (final message in messages) {
        await tester.enterText(find.byType(TextField), message);
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('Scenario 3: Start new conversation', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '旧话题');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_comment));
      await tester.pumpAndSettle();
      expect(find.text('👋 欢迎使用 XPlan'), findsOneWidget);
    });

    testWidgets('Scenario 4: Rapid fire messages', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      for (int i = 1; i <= 5; i++) {
        await tester.enterText(find.byType(TextField), '快速消息 $i');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      for (int i = 1; i <= 5; i++) {
        expect(find.text('快速消息 $i'), findsOneWidget);
      }
    });

    testWidgets('Scenario 5: Long message handling', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      final longMessage = '这是一条很长的测试消息，用于验证应用对长文本的处理能力。包含多个段落和特殊字符';
      await tester.enterText(find.byType(TextField), longMessage);
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.textContaining('这是一条很长的测试消息'), findsOneWidget);
    });

    testWidgets('Scenario 6: Special characters', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      final specialMessages = [
        'Emoji 测试：😀😁😂',
        '特殊符号',
        'URL: https://example.com',
      ];
      for (final message in specialMessages) {
        await tester.enterText(find.byType(TextField), message);
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
      }
    });

    testWidgets('Scenario 7: Offline mode', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '离线测试');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.text('离线测试'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Scenario 8: Error input handling', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '有效消息');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.text('有效消息'), findsOneWidget);
    });

    testWidgets('Scenario 9: Performance test', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      for (int i = 1; i <= 20; i++) {
        await tester.enterText(find.byType(TextField), '性能消息 $i');
        await tester.tap(find.byIcon(Icons.send));
        if (i % 5 == 0) await tester.pumpAndSettle();
        else await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Scenario 10: UI exploration', (tester) async {
      await tester.pumpWidget(const XPlanApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_comment));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'UI 测试');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.text('UI 测试'), findsOneWidget);
    });
  });
}
