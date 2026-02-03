import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/providers/is_adding_account_provider.dart';
import 'package:sloth/services/android_signer_service.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/error.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';
import '../test_helpers.dart';

class _MockRustLibApi implements RustLibApi {
  var metadataCompleter = Completer<FlutterMetadata>();
  String? metadataCalledWithPubkey;
  String? logoutCalledWithPubkey;
  final Set<String> existingAccounts = {};
  Object? getAccountError;
  Object? getAccountsError;
  List<Account> allAccounts = [];
  Map<String, AccountType> accountTypes = {};
  bool loginWithSignerCalled = false;
  String? loginWithSignerPubkey;
  Object? loginWithSignerError;
  bool registerExternalSignerCalled = false;

  @override
  Future<Account> crateApiAccountsGetAccount({required String pubkey}) async {
    if (getAccountError != null) {
      throw getAccountError!;
    }
    if (!existingAccounts.contains(pubkey)) {
      throw const ApiError.whitenoise(message: 'Account not found');
    }
    return Account(
      pubkey: pubkey,
      accountType: accountTypes[pubkey] ?? AccountType.local,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Account> crateApiSignerLoginWithExternalSignerAndCallbacks({
    required String pubkey,
    required FutureOr<String> Function(String) signEvent,
    required FutureOr<String> Function(String, String) nip04Encrypt,
    required FutureOr<String> Function(String, String) nip04Decrypt,
    required FutureOr<String> Function(String, String) nip44Encrypt,
    required FutureOr<String> Function(String, String) nip44Decrypt,
  }) async {
    loginWithSignerCalled = true;
    loginWithSignerPubkey = pubkey;
    if (loginWithSignerError != null) {
      throw loginWithSignerError!;
    }
    existingAccounts.add(pubkey);
    accountTypes[pubkey] = AccountType.external_;
    return Account(
      pubkey: pubkey,
      accountType: AccountType.external_,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> crateApiSignerRegisterExternalSigner({
    required String pubkey,
    required FutureOr<String> Function(String) signEvent,
    required FutureOr<String> Function(String, String) nip04Encrypt,
    required FutureOr<String> Function(String, String) nip04Decrypt,
    required FutureOr<String> Function(String, String) nip44Encrypt,
    required FutureOr<String> Function(String, String) nip44Decrypt,
  }) async {
    registerExternalSignerCalled = true;
  }

  @override
  Future<Account> crateApiAccountsCreateIdentity() async {
    existingAccounts.add(testPubkeyC);
    return Account(
      pubkey: testPubkeyC,
      accountType: AccountType.local,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Account> crateApiAccountsLogin({required String nsecOrHexPrivkey}) async {
    existingAccounts.add(testPubkeyB);
    return Account(
      pubkey: testPubkeyB,
      accountType: AccountType.local,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {
    logoutCalledWithPubkey = pubkey;
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    metadataCalledWithPubkey = pubkey;
    return metadataCompleter.future;
  }

  @override
  Future<List<Account>> crateApiAccountsGetAccounts() async {
    if (getAccountsError != null) {
      throw getAccountsError!;
    }
    return allAccounts;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late ProviderContainer container;
  late _MockRustLibApi mockApi;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    mockApi = _MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.metadataCompleter = Completer<FlutterMetadata>();
    mockApi.metadataCalledWithPubkey = null;
    mockApi.logoutCalledWithPubkey = null;
    mockApi.existingAccounts.clear();
    mockApi.getAccountError = null;
    mockApi.getAccountsError = null;
    mockApi.allAccounts = [];
    mockApi.accountTypes = {};
    mockApi.loginWithSignerCalled = false;
    mockApi.loginWithSignerPubkey = null;
    mockApi.loginWithSignerError = null;
    mockApi.registerExternalSignerCalled = false;
    mockStorage = MockSecureStorage();
    container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    group('build', () {
      group('when secure storage has no pubkey', () {
        test('returns null', () async {
          await container.read(authProvider.future);
          expect(container.read(authProvider).value, isNull);
        });
      });

      group('when pubkey is only in secure storage', () {
        setUp(() async {
          mockApi.existingAccounts.clear();
          await mockStorage.write(key: 'active_account_pubkey', value: 'stale_pubkey');
        });
        test('returns null', () async {
          final pubkey = await container.read(authProvider.future);
          expect(pubkey, isNull);
          expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
        });

        test('clears secure storage', () async {
          await container.read(authProvider.future);
          expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
        });
      });

      group('when getAccount fails with unexpected error', () {
        setUp(() async {
          mockApi.getAccountError = const ApiError.whitenoise(message: 'Network error');
          await mockStorage.write(key: 'active_account_pubkey', value: 'stored_pubkey');
        });

        test('returns stored pubkey', () async {
          final pubkey = await container.read(authProvider.future);
          expect(pubkey, 'stored_pubkey');
        });

        test('does not clear secure storage', () async {
          await container.read(authProvider.future);
          expect(await mockStorage.read(key: 'active_account_pubkey'), 'stored_pubkey');
        });
      });

      group('when pubkey is in secure storage and rust crate db', () {
        setUp(() async {
          mockApi.existingAccounts.add('stored_pubkey');
          await mockStorage.write(key: 'active_account_pubkey', value: 'stored_pubkey');
        });
        test('returns expected pubkey', () async {
          final pubkey = await container.read(authProvider.future);
          expect(pubkey, 'stored_pubkey');
        });

        test('does not clear secure storage', () async {
          await container.read(authProvider.future);
          expect(await mockStorage.read(key: 'active_account_pubkey'), 'stored_pubkey');
        });
      });
    });

    group('login', () {
      test('sets state to pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        expect(container.read(authProvider).value, testPubkeyB);
      });

      test('fetches account metadata without awaiting', () async {
        await container.read(authProvider.notifier).login('nsec123');
        expect(mockApi.metadataCalledWithPubkey, testPubkeyB);
        expect(mockApi.metadataCompleter.isCompleted, isFalse);
      });

      test('resets isAddingAccountProvider to false', () async {
        container.read(isAddingAccountProvider.notifier).set(true);
        expect(container.read(isAddingAccountProvider), true);
        await container.read(authProvider.notifier).login('nsec123');
        expect(container.read(isAddingAccountProvider), false);
      });
    });

    group('signup', () {
      test('returns created pubkey', () async {
        final pubkey = await container.read(authProvider.notifier).signup();
        expect(pubkey, testPubkeyC);
      });

      test('resets isAddingAccountProvider to false', () async {
        container.read(isAddingAccountProvider.notifier).set(true);
        expect(container.read(isAddingAccountProvider), true);
        await container.read(authProvider.notifier).signup();
        expect(container.read(isAddingAccountProvider), false);
      });
    });

    group('logout', () {
      test('clears state when no other accounts', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(container.read(authProvider).value, isNull);
      });

      test('clears storage when no other accounts', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
      });

      test('calls Rust API logout', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(mockApi.logoutCalledWithPubkey, testPubkeyB);
      });

      test('does nothing when not authenticated', () async {
        await container.read(authProvider.future);
        await container.read(authProvider.notifier).logout();
        expect(mockApi.logoutCalledWithPubkey, isNull);
        expect(container.read(authProvider).value, isNull);
      });

      test('switches to another account when available', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('other_pubkey');
        mockApi.allAccounts = [
          Account(
            accountType: AccountType.local,
            pubkey: 'other_pubkey',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, 'other_pubkey');
        expect(container.read(authProvider).value, 'other_pubkey');
        expect(await mockStorage.read(key: 'active_account_pubkey'), 'other_pubkey');
      });

      test('filters out logged-out account when switching', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add(testPubkeyD);
        mockApi.allAccounts = [
          Account(
            accountType: AccountType.local,
            pubkey: testPubkeyB,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Account(
            accountType: AccountType.local,
            pubkey: testPubkeyD,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, testPubkeyD);
        expect(container.read(authProvider).value, testPubkeyD);
      });

      test('returns null when no other accounts', () async {
        await container.read(authProvider.notifier).login('nsec123');
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, isNull);
      });

      test('returns null when getAccounts fails', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.getAccountsError = Exception('Network error');
        final nextPubkey = await container.read(authProvider.notifier).logout();
        expect(nextPubkey, isNull);
        expect(container.read(authProvider).value, isNull);
      });
    });

    group('switchProfile', () {
      test('updates state to new pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('new_pubkey');
        await container.read(authProvider.notifier).switchProfile('new_pubkey');
        expect(container.read(authProvider).value, 'new_pubkey');
      });

      test('updates storage with new pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        mockApi.existingAccounts.add('new_pubkey');
        await container.read(authProvider.notifier).switchProfile('new_pubkey');
        expect(await mockStorage.read(key: 'active_account_pubkey'), 'new_pubkey');
      });

      test('clears state when account not found', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).switchProfile('nonexistent');
        expect(container.read(authProvider).value, isNull);
        expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
      });
    });

    group('loginWithAndroidSigner', () {
      test('sets state to pubkey on success', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        expect(container.read(authProvider).value, testPubkeyA);
      });

      test('calls Rust API loginWithExternalSignerAndCallbacks', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        expect(mockApi.loginWithSignerCalled, isTrue);
        expect(mockApi.loginWithSignerPubkey, testPubkeyA);
      });

      test('fetches metadata without awaiting', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        expect(mockApi.metadataCalledWithPubkey, testPubkeyA);
        expect(mockApi.metadataCompleter.isCompleted, isFalse);
      });

      test('resets isAddingAccountProvider to false', () async {
        container.read(isAddingAccountProvider.notifier).set(true);
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        expect(container.read(isAddingAccountProvider), false);
      });

      test('calls onDisconnect when ApiError is thrown', () async {
        mockApi.loginWithSignerError = const ApiError.whitenoise(message: 'Test error');
        var disconnectCalled = false;

        await expectLater(
          () => container
              .read(authProvider.notifier)
              .loginWithAndroidSigner(
                pubkey: testPubkeyA,
                onDisconnect: () async {
                  disconnectCalled = true;
                },
              ),
          throwsA(isA<ApiError>()),
        );
        expect(disconnectCalled, isTrue);
      });

      test('calls onDisconnect when AndroidSignerException is thrown', () async {
        mockApi.loginWithSignerError = const AndroidSignerException(
          'USER_REJECTED',
          'User rejected',
        );
        var disconnectCalled = false;

        await expectLater(
          () => container
              .read(authProvider.notifier)
              .loginWithAndroidSigner(
                pubkey: testPubkeyA,
                onDisconnect: () async {
                  disconnectCalled = true;
                },
              ),
          throwsA(isA<AndroidSignerException>()),
        );
        expect(disconnectCalled, isTrue);
      });

      test('calls onDisconnect when unexpected error is thrown', () async {
        mockApi.loginWithSignerError = Exception('Unexpected error');
        var disconnectCalled = false;

        await expectLater(
          () => container
              .read(authProvider.notifier)
              .loginWithAndroidSigner(
                pubkey: testPubkeyA,
                onDisconnect: () async {
                  disconnectCalled = true;
                },
              ),
          throwsA(isA<Exception>()),
        );
        expect(disconnectCalled, isTrue);
      });

      test('handles disconnect failure gracefully', () async {
        mockApi.loginWithSignerError = const ApiError.whitenoise(message: 'Test error');

        await expectLater(
          () => container
              .read(authProvider.notifier)
              .loginWithAndroidSigner(
                pubkey: testPubkeyA,
                onDisconnect: () async {
                  throw Exception('Disconnect failed');
                },
              ),
          throwsA(isA<ApiError>()),
        );
      });
    });

    group('isUsingAndroidSigner', () {
      test('returns false when not authenticated', () async {
        await container.read(authProvider.future);
        final result = await container.read(authProvider.notifier).isUsingAndroidSigner();
        expect(result, isFalse);
      });

      test('returns false for local account', () async {
        await container.read(authProvider.notifier).login('nsec123');
        final result = await container.read(authProvider.notifier).isUsingAndroidSigner();
        expect(result, isFalse);
      });

      test('returns true for external account', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        final result = await container.read(authProvider.notifier).isUsingAndroidSigner();
        expect(result, isTrue);
      });

      test('returns false when getAccount fails', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        mockApi.getAccountError = const ApiError.whitenoise(message: 'Network error');
        final result = await container.read(authProvider.notifier).isUsingAndroidSigner();
        expect(result, isFalse);
      });
    });

    group('logout with Android signer', () {
      test('calls onAndroidSignerDisconnect for external account', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        var disconnectCalled = false;
        await container
            .read(authProvider.notifier)
            .logout(
              onAndroidSignerDisconnect: () async {
                disconnectCalled = true;
              },
            );
        expect(disconnectCalled, isTrue);
      });

      test('does not call onAndroidSignerDisconnect for local account', () async {
        await container.read(authProvider.notifier).login('nsec123');
        var disconnectCalled = false;
        await container
            .read(authProvider.notifier)
            .logout(
              onAndroidSignerDisconnect: () async {
                disconnectCalled = true;
              },
            );
        expect(disconnectCalled, isFalse);
      });

      test('handles disconnect failure gracefully during logout', () async {
        await container
            .read(authProvider.notifier)
            .loginWithAndroidSigner(
              pubkey: testPubkeyA,
              onDisconnect: () async {},
            );
        await container
            .read(authProvider.notifier)
            .logout(
              onAndroidSignerDisconnect: () async {
                throw Exception('Disconnect failed');
              },
            );
        expect(container.read(authProvider).value, isNull);
      });
    });

    group('build with external account', () {
      test('re-registers external signer callbacks', () async {
        mockApi.existingAccounts.add(testPubkeyA);
        mockApi.accountTypes[testPubkeyA] = AccountType.external_;
        await mockStorage.write(key: 'active_account_pubkey', value: testPubkeyA);

        await container.read(authProvider.future);

        expect(mockApi.registerExternalSignerCalled, isTrue);
      });

      test('does not re-register for local account', () async {
        mockApi.existingAccounts.add(testPubkeyA);
        mockApi.accountTypes[testPubkeyA] = AccountType.local;
        await mockStorage.write(key: 'active_account_pubkey', value: testPubkeyA);

        await container.read(authProvider.future);

        expect(mockApi.registerExternalSignerCalled, isFalse);
      });
    });
  });
}
