import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/src/rust/api/notifications.dart';

void main() {
  group('Notification formatting', () {
    test('formats DM new message correctly', () {
      final update = NotificationUpdate(
        trigger: NotificationTrigger.newMessage,
        mlsGroupId: 'group123',
        isDm: true,
        receiver: const NotificationUser(pubkey: 'receiver123'),
        sender: const NotificationUser(pubkey: 'sender123', displayName: 'Alice'),
        content: 'Hello there',
        timestamp: DateTime.now(),
      );

      final (title, body, isInvite) = formatNotification(update);

      expect(title, equals('Alice'));
      expect(body, equals('Hello there'));
      expect(isInvite, isFalse);
    });

    test('formats group new message correctly', () {
      final update = NotificationUpdate(
        trigger: NotificationTrigger.newMessage,
        mlsGroupId: 'group123',
        groupName: 'Friends Group',
        isDm: false,
        receiver: const NotificationUser(pubkey: 'receiver123'),
        sender: const NotificationUser(pubkey: 'sender123', displayName: 'Bob'),
        content: 'Hey everyone',
        timestamp: DateTime.now(),
      );

      final (title, body, isInvite) = formatNotification(update);

      expect(title, equals('Friends Group'));
      expect(body, equals('Bob: Hey everyone'));
      expect(isInvite, isFalse);
    });

    test('formats DM invite correctly', () {
      final update = NotificationUpdate(
        trigger: NotificationTrigger.groupInvite,
        mlsGroupId: 'group123',
        isDm: true,
        receiver: const NotificationUser(pubkey: 'receiver123'),
        sender: const NotificationUser(pubkey: 'sender123', displayName: 'Carol'),
        content: '',
        timestamp: DateTime.now(),
      );

      final (title, body, isInvite) = formatNotification(update);

      expect(title, equals('New Message Request'));
      expect(body, equals('Carol wants to chat'));
      expect(isInvite, isTrue);
    });

    test('formats group invite correctly', () {
      final update = NotificationUpdate(
        trigger: NotificationTrigger.groupInvite,
        mlsGroupId: 'group123',
        groupName: 'New Project',
        isDm: false,
        receiver: const NotificationUser(pubkey: 'receiver123'),
        sender: const NotificationUser(pubkey: 'sender123', displayName: 'Dave'),
        content: '',
        timestamp: DateTime.now(),
      );

      final (title, body, isInvite) = formatNotification(update);

      expect(title, equals('Group Invitation'));
      expect(body, equals('Dave invited you to New Project'));
      expect(isInvite, isTrue);
    });

    test('uses Unknown for sender without display name', () {
      final update = NotificationUpdate(
        trigger: NotificationTrigger.newMessage,
        mlsGroupId: 'group123',
        isDm: true,
        receiver: const NotificationUser(pubkey: 'receiver123'),
        sender: const NotificationUser(pubkey: 'sender123'),
        content: 'Anonymous message',
        timestamp: DateTime.now(),
      );

      final (title, _, _) = formatNotification(update);

      expect(title, equals('Unknown'));
    });

    test('uses Group for group without name', () {
      final update = NotificationUpdate(
        trigger: NotificationTrigger.newMessage,
        mlsGroupId: 'group123',
        isDm: false,
        receiver: const NotificationUser(pubkey: 'receiver123'),
        sender: const NotificationUser(pubkey: 'sender123', displayName: 'Eve'),
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      final (title, _, _) = formatNotification(update);

      expect(title, equals('Group'));
    });
  });
}

/// Test helper that mirrors the formatting logic from notification_provider.dart
(String title, String body, bool isInvite) formatNotification(NotificationUpdate update) {
  final senderName = update.sender.displayName ?? 'Unknown';

  switch (update.trigger) {
    case NotificationTrigger.newMessage:
      if (update.isDm) {
        return (senderName, update.content, false);
      } else {
        final groupName = update.groupName ?? 'Group';
        return (groupName, '$senderName: ${update.content}', false);
      }
    case NotificationTrigger.groupInvite:
      if (update.isDm) {
        return ('New Message Request', '$senderName wants to chat', true);
      } else {
        final groupName = update.groupName ?? 'a group';
        return ('Group Invitation', '$senderName invited you to $groupName', true);
      }
  }
}
