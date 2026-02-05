import 'dart:async';

import 'package:whitenoise/src/rust/api.dart' as rust_api;
import 'package:whitenoise/src/rust/api/accounts.dart';
import 'package:whitenoise/src/rust/api/chat_list.dart';
import 'package:whitenoise/src/rust/api/error.dart';
import 'package:whitenoise/src/rust/api/groups.dart';
import 'package:whitenoise/src/rust/api/messages.dart';
import 'package:whitenoise/src/rust/api/metadata.dart';
import 'package:whitenoise/src/rust/api/users.dart';
import 'package:whitenoise/src/rust/frb_generated.dart';

import '../test_helpers.dart' show testHexToNpub, testNpubToHex;

class MockThemeMode implements rust_api.ThemeMode {
  final String mode;
  const MockThemeMode(this.mode);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockLanguage implements rust_api.Language {
  final String code;
  const MockLanguage(this.code);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockAppSettings implements rust_api.AppSettings {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MockWnApi implements RustLibApi {
  String currentThemeMode = 'system';
  String currentLanguage = 'system';
  bool shouldFailUpdateLanguage = false;
  bool shouldFailNpubConversion = false;
  bool shouldFailHexFromNpub = false;
  List<Account> accounts = [];
  Completer<List<Account>>? getAccountsCompleter;

  List<User> follows = [];
  bool userHasKeyPackage = true;

  @override
  Future<bool> crateApiUsersUserHasKeyPackage({
    required String pubkey,
    required bool blockingDataSync,
  }) async {
    return userHasKeyPackage;
  }

  @override
  Future<List<User>> crateApiAccountsAccountFollows({required String pubkey}) async {
    return follows;
  }

  @override
  Future<void> crateApiAccountsFollowUser({
    required String accountPubkey,
    required String userToFollowPubkey,
  }) async {}

  @override
  Future<void> crateApiAccountsUnfollowUser({
    required String accountPubkey,
    required String userToUnfollowPubkey,
  }) async {}

  @override
  Future<bool> crateApiAccountsIsFollowingUser({
    required String accountPubkey,
    required String userPubkey,
  }) async {
    return follows.any((user) => user.pubkey == userPubkey);
  }

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    if (shouldFailNpubConversion) {
      throw Exception('Invalid hex pubkey');
    }
    final npub = testHexToNpub[hexPubkey];
    if (npub == null) throw Exception('Unknown hex pubkey: $hexPubkey');
    return npub;
  }

  @override
  String crateApiUtilsHexPubkeyFromNpub({required String npub}) {
    if (shouldFailHexFromNpub) {
      throw Exception('Invalid npub');
    }
    final hex = testNpubToHex[npub];
    if (hex == null) throw Exception('Unknown npub: $npub');
    return hex;
  }

  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return [];
  }

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) async {
    return false;
  }

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) async {
    return null;
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) {
    return Stream.value(const MessageStreamItem.initialSnapshot(messages: []));
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async {
    return FlutterMetadata(
      name: 'User $pubkey',
      displayName: 'Display $pubkey',
      custom: {},
    );
  }

  @override
  Stream<ChatListStreamItem> crateApiChatListSubscribeToChatList({
    required String accountPubkey,
  }) {
    return Stream.value(const ChatListStreamItem.initialSnapshot(items: []));
  }

  @override
  Future<List<String>> crateApiGroupsGroupMembers({
    required String pubkey,
    required String groupId,
  }) async => [];

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {}

  @override
  Future<List<Account>> crateApiAccountsGetAccounts() async {
    if (getAccountsCompleter != null) {
      return getAccountsCompleter!.future;
    }
    return accounts;
  }

  @override
  Future<Account> crateApiAccountsGetAccount({required String pubkey}) async {
    final accountList = getAccountsCompleter != null
        ? await getAccountsCompleter!.future
        : accounts;
    return accountList.firstWhere(
      (a) => a.pubkey == pubkey,
      orElse: () => throw const ApiError.whitenoise(message: 'Account not found'),
    );
  }

  @override
  Future<String> crateApiUtilsGetDefaultBlossomServerUrl() async => 'https://blossom.example.com';

  @override
  Future<void> crateApiAccountsUpdateAccountMetadata({
    required String pubkey,
    required FlutterMetadata metadata,
  }) async {}

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeLight() => const MockThemeMode('light');

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeDark() => const MockThemeMode('dark');

  @override
  rust_api.ThemeMode crateApiUtilsThemeModeSystem() => const MockThemeMode('system');

  @override
  String crateApiUtilsThemeModeToString({required rust_api.ThemeMode themeMode}) {
    if (themeMode is MockThemeMode) {
      return themeMode.mode;
    }
    return 'system';
  }

  @override
  Future<rust_api.AppSettings> crateApiGetAppSettings() async {
    return MockAppSettings();
  }

  @override
  Future<rust_api.ThemeMode> crateApiAppSettingsThemeMode({
    required rust_api.AppSettings appSettings,
  }) async {
    return MockThemeMode(currentThemeMode);
  }

  @override
  Future<void> crateApiUpdateThemeMode({
    required rust_api.ThemeMode themeMode,
  }) async {
    if (themeMode is MockThemeMode) {
      currentThemeMode = themeMode.mode;
    }
  }

  @override
  rust_api.Language crateApiUtilsLanguageEnglish() => const MockLanguage('en');

  @override
  rust_api.Language crateApiUtilsLanguageSpanish() => const MockLanguage('es');

  @override
  rust_api.Language crateApiUtilsLanguageFrench() => const MockLanguage('fr');

  @override
  rust_api.Language crateApiUtilsLanguageGerman() => const MockLanguage('de');

  @override
  rust_api.Language crateApiUtilsLanguageItalian() => const MockLanguage('it');

  @override
  rust_api.Language crateApiUtilsLanguagePortuguese() => const MockLanguage('pt');

  @override
  rust_api.Language crateApiUtilsLanguageRussian() => const MockLanguage('ru');

  @override
  rust_api.Language crateApiUtilsLanguageTurkish() => const MockLanguage('tr');

  @override
  rust_api.Language crateApiUtilsLanguageSystem() => const MockLanguage('system');

  @override
  String crateApiUtilsLanguageToString({required rust_api.Language language}) {
    if (language is MockLanguage) {
      return language.code;
    }
    return 'en';
  }

  @override
  Future<rust_api.Language> crateApiAppSettingsLanguage({
    required rust_api.AppSettings appSettings,
  }) async {
    return MockLanguage(currentLanguage);
  }

  @override
  Future<void> crateApiUpdateLanguage({
    required rust_api.Language language,
  }) async {
    if (shouldFailUpdateLanguage) {
      throw Exception('Failed to update language');
    }
    if (language is MockLanguage) {
      currentLanguage = language.code;
    }
  }

  void reset() {
    currentThemeMode = 'system';
    currentLanguage = 'system';
    shouldFailUpdateLanguage = false;
    shouldFailNpubConversion = false;
    shouldFailHexFromNpub = false;
    accounts = [];
    follows = [];
    getAccountsCompleter = null;
    userHasKeyPackage = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
