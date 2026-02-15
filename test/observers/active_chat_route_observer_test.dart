import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/observers/active_chat_route_observer.dart';
import 'package:whitenoise/providers/active_chat_provider.dart';

void main() {
  group('ActiveChatRouteObserver', () {
    late ProviderContainer container;
    late ActiveChatRouteObserver observer;

    setUp(() {
      container = ProviderContainer();
      observer = ActiveChatRouteObserver(container.read(activeChatProvider.notifier));
    });

    tearDown(() => container.dispose());

    Route<dynamic> fakeRoute(String? name) {
      return PageRouteBuilder<void>(
        settings: RouteSettings(name: name),
        pageBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    group('didPush', () {
      test('sets active chat for chat route', () {
        observer.didPush(fakeRoute('/chats/group123'), null);
        expect(container.read(activeChatProvider), 'group123');
      });

      test('sets active chat for invite route', () {
        observer.didPush(fakeRoute('/invites/group456'), null);
        expect(container.read(activeChatProvider), 'group456');
      });

      test('clears active chat for non-chat route', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didPush(fakeRoute('/settings'), null);
        expect(container.read(activeChatProvider), isNull);
      });

      test('clears when route name is null', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didPush(fakeRoute(null), null);
        expect(container.read(activeChatProvider), isNull);
      });
    });

    group('didPop', () {
      test('updates from previousRoute', () {
        observer.didPop(fakeRoute('/chats/group123'), fakeRoute('/chats'));
        expect(container.read(activeChatProvider), isNull);
      });

      test('sets active chat when popping to chat route', () {
        observer.didPop(fakeRoute('/settings'), fakeRoute('/chats/group123'));
        expect(container.read(activeChatProvider), 'group123');
      });

      test('clears when previousRoute is null', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didPop(fakeRoute('/chats/group123'), null);
        expect(container.read(activeChatProvider), isNull);
      });
    });

    group('didReplace', () {
      test('updates from newRoute', () {
        observer.didReplace(
          newRoute: fakeRoute('/chats/newGroup'),
          oldRoute: fakeRoute('/chats/oldGroup'),
        );
        expect(container.read(activeChatProvider), 'newGroup');
      });

      test('clears for non-chat newRoute', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didReplace(
          newRoute: fakeRoute('/settings'),
          oldRoute: fakeRoute('/chats/group123'),
        );
        expect(container.read(activeChatProvider), isNull);
      });

      test('clears when newRoute is null', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didReplace(oldRoute: fakeRoute('/chats/group123'));
        expect(container.read(activeChatProvider), isNull);
      });
    });

    group('didRemove', () {
      test('updates from previousRoute', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didRemove(fakeRoute('/chats/group123'), fakeRoute('/chats'));
        expect(container.read(activeChatProvider), isNull);
      });

      test('sets active chat when removing reveals invite route', () {
        observer.didRemove(fakeRoute('/settings'), fakeRoute('/invites/group789'));
        expect(container.read(activeChatProvider), 'group789');
      });

      test('clears when previousRoute is null', () {
        container.read(activeChatProvider.notifier).set('group123');
        observer.didRemove(fakeRoute('/chats/group123'), null);
        expect(container.read(activeChatProvider), isNull);
      });
    });
  });
}
