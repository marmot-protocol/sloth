import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/add_profile_screen.dart';
import 'package:sloth/screens/login_screen.dart';
import 'package:sloth/screens/signup_screen.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

final _mockApi = _MockApi();

class _MockApi extends MockWnApi {}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => testPubkeyA;
}

void main() {
  setUpAll(() => RustLib.initMock(api: _mockApi));

  setUp(() => _mockApi.reset());

  Future<void> pumpAddProfileScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToAddProfile(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('AddProfileScreen', () {
    testWidgets('displays Add a New Profile title', (tester) async {
      await pumpAddProfileScreen(tester);
      expect(find.text('Add a New Profile'), findsOneWidget);
    });

    testWidgets('displays Login button', (tester) async {
      await pumpAddProfileScreen(tester);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('displays Sign Up button', (tester) async {
      await pumpAddProfileScreen(tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('tapping Login navigates to LoginScreen', (tester) async {
      await pumpAddProfileScreen(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('tapping Login sets isAddingAccountProvider to true', (tester) async {
      await pumpAddProfileScreen(tester);
      final context = tester.element(find.byType(Scaffold));
      final container = ProviderScope.containerOf(context);
      expect(container.read(isAddingAccountProvider), false);
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(container.read(isAddingAccountProvider), true);
    });

    testWidgets('tapping Sign Up navigates to SignupScreen', (tester) async {
      await pumpAddProfileScreen(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('tapping Sign Up sets isAddingAccountProvider to true', (tester) async {
      await pumpAddProfileScreen(tester);
      final context = tester.element(find.byType(Scaffold));
      final container = ProviderScope.containerOf(context);
      expect(container.read(isAddingAccountProvider), false);
      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      expect(container.read(isAddingAccountProvider), true);
    });

    testWidgets('displays back button', (tester) async {
      await pumpAddProfileScreen(tester);
      expect(find.byKey(const Key('slate_close_button')), findsOneWidget);
    });

    testWidgets('tapping back button returns to previous screen', (tester) async {
      await pumpAddProfileScreen(tester);
      await tester.tap(find.byKey(const Key('slate_close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(AddProfileScreen), findsNothing);
    });
  });
}
