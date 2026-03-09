import 'package:flutter_test/flutter_test.dart';
import 'package:xplan/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('Message constructor creates instance with correct values', () {
      final message = Message(
        id: 'test-123',
        content: 'Hello, World!',
        role: 'user',
        timestamp: DateTime(2026, 3, 9, 10, 30, 0),
      );

      expect(message.id, 'test-123');
      expect(message.content, 'Hello, World!');
      expect(message.role, 'user');
      expect(message.timestamp, DateTime(2026, 3, 9, 10, 30, 0));
    });

    test('Message fromJson parses JSON correctly', () {
      final json = {
        'id': 'json-456',
        'content': 'Test message',
        'role': 'assistant',
        'timestamp': '2026-03-09T10:30:00.000Z',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'json-456');
      expect(message.content, 'Test message');
      expect(message.role, 'assistant');
      expect(message.timestamp.year, 2026);
      expect(message.timestamp.month, 3);
      expect(message.timestamp.day, 9);
    });

    test('Message fromJson handles missing id', () {
      final json = {
        'content': 'No ID message',
        'role': 'user',
      };

      final message = Message.fromJson(json);

      expect(message.id, isNotEmpty);
      expect(message.content, 'No ID message');
      expect(message.role, 'user');
    });

    test('Message fromJson handles missing content', () {
      final json = {
        'id': 'test-789',
        'role': 'assistant',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'test-789');
      expect(message.content, '');
      expect(message.role, 'assistant');
    });

    test('Message fromJson handles missing timestamp', () {
      final json = {
        'id': 'test-000',
        'content': 'No timestamp',
        'role': 'user',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'test-000');
      expect(message.content, 'No timestamp');
      expect(message.timestamp, isA<DateTime>());
    });

    test('Message toJson converts to correct JSON', () {
      final originalMessage = Message(
        id: 'toJson-test',
        content: 'Testing toJson',
        role: 'user',
        timestamp: DateTime(2026, 3, 9, 12, 0, 0),
      );

      final json = originalMessage.toJson();

      expect(json['id'], 'toJson-test');
      expect(json['content'], 'Testing toJson');
      expect(json['role'], 'user');
      expect(json['timestamp'], '2026-03-09T12:00:00.000');
    });

    test('Message round-trip serialization', () {
      final original = Message(
        id: 'roundtrip-123',
        content: 'Round trip test',
        role: 'assistant',
        timestamp: DateTime(2026, 3, 9, 15, 45, 30),
      );

      final json = original.toJson();
      final restored = Message.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.content, original.content);
      expect(restored.role, original.role);
      expect(restored.timestamp.millisecondsSinceEpoch,
          original.timestamp.millisecondsSinceEpoch);
    });

    test('Message handles alternative JSON field names', () {
      // Some APIs use 'message' instead of 'content'
      final json = {
        'id': 'alt-123',
        'message': 'Alternative field name',
        'role': 'assistant',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'alt-123');
      expect(message.content, 'Alternative field name');
    });
  });
}
