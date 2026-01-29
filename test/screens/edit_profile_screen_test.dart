import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/theme/semantic_colors.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockApi extends MockWnApi {
  FlutterMetadata? updatedMetadata;
  String? updatedPubkey;
  bool shouldThrowError = false;
  bool shouldThrowOnUpdate = false;
  Completer<void>? updateCompleter;

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    if (shouldThrowError) {
      throw Exception('Failed to load profile');
    }
    return const FlutterMetadata(
      name: 'Test User',
      displayName: 'Test Display Name',
      about: 'Test About',
      nip05: 'test@example.com',
      custom: {},
    );
  }

  @override
  Future<void> crateApiAccountsUpdateAccountMetadata({
    required String pubkey,
    required FlutterMetadata metadata,
  }) async {
    if (shouldThrowOnUpdate) {
      throw Exception('Failed to update profile');
    }
    if (updateCompleter != null) {
      await updateCompleter!.future;
    }
    updatedPubkey = pubkey;
    updatedMetadata = metadata;
  }

  @override
  Future<String> crateApiAccountsUploadAccountProfilePicture({
    required String pubkey,
    required String serverUrl,
    required String filePath,
    required String imageType,
  }) async {
    return 'https://example.com/picture.jpg';
  }
}

class _MockAuthNotifier extends AuthNotifier {
  _MockAuthNotifier([this._pubkey = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4']);

  final String _pubkey;

  @override
  Future<String?> build() async {
    state = AsyncData(_pubkey);
    return _pubkey;
  }
}

void main() {
  late _MockApi mockApi;

  setUpAll(() {
    mockApi = _MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.shouldThrowError = false;
    mockApi.shouldThrowOnUpdate = false;
    mockApi.updatedMetadata = null;
    mockApi.updatedPubkey = null;
    mockApi.updateCompleter = null;
  });

  Future<void> pumpEditProfileScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => _MockAuthNotifier()),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToEditProfile(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('EditProfileScreen', () {
    testWidgets('displays Edit profile title', (tester) async {
      await pumpEditProfileScreen(tester);
      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('displays profile name field', (tester) async {
      await pumpEditProfileScreen(tester);
      expect(find.text('Profile name'), findsOneWidget);
    });

    testWidgets('displays Nostr address field', (tester) async {
      await pumpEditProfileScreen(tester);
      expect(find.text('Nostr address'), findsOneWidget);
    });

    testWidgets('displays About you field', (tester) async {
      await pumpEditProfileScreen(tester);
      expect(find.text('About you'), findsOneWidget);
    });

    testWidgets('displays warning box', (tester) async {
      await pumpEditProfileScreen(tester);
      expect(find.text('Profile is public'), findsOneWidget);
    });

    testWidgets('tapping close icon returns to previous screen', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    testWidgets('loads and displays current profile data', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      expect(find.text('Test Display Name'), findsOneWidget);
    });

    testWidgets('shows Save button', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Save button is disabled when there are no changes', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      final saveButton = find.widgetWithText(WnButton, 'Save');
      expect(saveButton, findsOneWidget);
      final button = tester.widget<WnButton>(saveButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Save button is enabled when there are changes', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      final displayNameField = find.text('Profile name');
      expect(displayNameField, findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'New Name');
      await tester.pump();
      final saveButton = find.widgetWithText(WnButton, 'Save');
      final button = tester.widget<WnButton>(saveButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Discard changes button appears when there are changes', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      expect(find.text('Discard changes'), findsNothing);
      await tester.enterText(find.byType(TextField).first, 'New Name');
      await tester.pump();
      expect(find.text('Discard changes'), findsOneWidget);
    });

    testWidgets('Discard changes button resets form fields', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      final displayNameField = find.byType(TextField).first;
      await tester.enterText(displayNameField, 'New Name');
      await tester.pump();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();
      final fieldText = tester.widget<TextField>(displayNameField).controller?.text ?? '';
      expect(fieldText, 'Test Display Name');
    });

    testWidgets('displays error message when profile loading fails', (tester) async {
      mockApi.shouldThrowError = true;
      await mountTestApp(
        tester,
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier()),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      Routes.pushToEditProfile(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();
      expect(find.textContaining('Unable to load profile'), findsOneWidget);
    });

    testWidgets('Save button saves changes successfully', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Updated Name');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Profile updated successfully'), findsOneWidget);
      expect(mockApi.updatedMetadata, isNotNull);
    });

    testWidgets('Save button shows error when update fails', (tester) async {
      mockApi.shouldThrowOnUpdate = true;
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Updated Name');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Unable to save profile'), findsOneWidget);
    });

    testWidgets('calls onChanged when profile name field is changed', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(3));
      await tester.enterText(textFields.at(0), 'New Profile Name');
      await tester.pump();
      final saveButton = find.widgetWithText(WnButton, 'Save');
      final button = tester.widget<WnButton>(saveButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onChanged when Nostr address field is changed', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(3));
      await tester.enterText(textFields.at(1), 'new@example.com');
      await tester.pump();
      final saveButton = find.widgetWithText(WnButton, 'Save');
      final button = tester.widget<WnButton>(saveButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onChanged when About you field is changed', (tester) async {
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(3));
      await tester.enterText(textFields.at(2), 'New about text');
      await tester.pump();
      final saveButton = find.widgetWithText(WnButton, 'Save');
      final button = tester.widget<WnButton>(saveButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('hides buttons when loading', (tester) async {
      mockApi.shouldThrowError = false;
      await mountTestApp(
        tester,
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier()),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      Routes.pushToEditProfile(tester.element(find.byType(Scaffold)));
      await tester.pump();
      expect(find.text('Save'), findsNothing);
      expect(find.text('Discard changes'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('hides avatar edit button during save', (tester) async {
      mockApi.updateCompleter = Completer<void>();
      await pumpEditProfileScreen(tester);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('avatar_edit_button')), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Updated Name');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.byKey(const Key('avatar_edit_button')), findsNothing);
      mockApi.updateCompleter!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('passes color derived from pubkey to avatar', (tester) async {
      await pumpEditProfileScreen(tester);

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AccentColor.violet);
    });

    testWidgets('different pubkey passes different avatar color', (tester) async {
      await mountTestApp(
        tester,
        overrides: [
          authProvider.overrideWith(() => _MockAuthNotifier('0xyz1234e5f6a1b2c3d4e5f6a1b2c3d4')),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
      );
      Routes.pushToEditProfile(tester.element(find.byType(Scaffold)));
      await tester.pumpAndSettle();

      final avatar = tester.widget<WnAvatar>(find.byType(WnAvatar));
      expect(avatar.color, AccentColor.blue);
    });

    testWidgets('shows error snackbar when image picker fails', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/image_picker'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'error', message: 'Test error');
        },
      );
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/image_picker'),
          null,
        );
      });

      await pumpEditProfileScreen(tester);
      await tester.tap(find.byKey(const Key('avatar_edit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to pick image. Please try again.'), findsOneWidget);
    });
  });
}
