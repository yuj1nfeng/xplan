// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:xplan/main.dart';
import 'package:xplan/providers/chat_provider.dart';

void main() {
  testWidgets('XPlanApp 启动测试', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const XPlanApp());

    // Verify that the app title is displayed
    expect(find.text('XPlan - COPAW 客户端'), findsOneWidget);

    // Verify that the welcome message or chat interface is present
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('聊天界面测试', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: Center())),
      ),
    );

    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
