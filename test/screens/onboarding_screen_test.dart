import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/settings_screen.dart';
import 'package:sloth/screens/user_search_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

void main() {
  setUpAll(() => RustLib.initMock(api: MockWnApi()));

  Future<void> pumpOnboardingScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );
    Routes.goToOnboarding(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen', () {
    testWidgets('displays profile ready message', (tester) async {
      await pumpOnboardingScreen(tester);
      expect(find.text('Your profile is ready!'), findsOneWidget);
    });

    testWidgets('displays description text', (tester) async {
      await pumpOnboardingScreen(tester);
      expect(
        find.text('Start a conversation by adding friends or sharing your profile.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping close icon navigates to chat list', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping outside slate navigates to chat list', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.byKey(const Key('onboarding_background')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('tapping Share your profile navigates to WIP screen', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.text('Share your profile'));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });

    testWidgets('tapping Start a chat navigates to WIP screen', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.text('Start a chat'));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });

    testWidgets('tapping avatar navigates to settings', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.byKey(const Key('avatar_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping chat icon navigates to user search', (tester) async {
      await pumpOnboardingScreen(tester);
      await tester.tap(find.byKey(const Key('chat_add_button')));
      await tester.pumpAndSettle();
      expect(find.byType(UserSearchScreen), findsOneWidget);
    });
  });
}
