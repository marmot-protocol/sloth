import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/settings_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../test_helpers.dart';

class _MockApi implements RustLibApi {
  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async => const FlutterMetadata(custom: {});

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: _MockApi()));

  Future<void> pumpChatListScreen(WidgetTester tester) async {
    setUpTestView(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
        child: ScreenUtilInit(
          designSize: testDesignSize,
          builder: (_, _) => Consumer(
            builder: (context, ref, _) {
              return MaterialApp.router(routerConfig: Routes.build(ref));
            },
          ),
        ),
      ),
    );
    Routes.goToChatList(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('WnAccountBar', () {
    testWidgets('displays avatar', (tester) async {
      await pumpChatListScreen(tester);
      expect(find.byKey(const Key('avatar_button')), findsOneWidget);
    });

    testWidgets('displays chat icon', (tester) async {
      await pumpChatListScreen(tester);
      expect(find.byKey(const Key('chat_add_button')), findsOneWidget);
    });

    testWidgets('tapping avatar navigates to settings', (tester) async {
      await pumpChatListScreen(tester);
      await tester.tap(find.byKey(const Key('avatar_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping chat add icon navigates to WIP screen', (tester) async {
      await pumpChatListScreen(tester);
      await tester.tap(find.byKey(const Key('chat_add_button')));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });
  });
}
