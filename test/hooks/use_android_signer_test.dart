import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_android_signer.dart';
import 'package:sloth/services/android_signer_service.dart';

import '../mocks/mock_android_signer_channel.dart';
import '../test_helpers.dart';

typedef AndroidSignerHookResult = ({
  bool isAvailable,
  bool isConnecting,
  String? error,
  Future<String> Function() connect,
  Future<void> Function() disconnect,
});

class _TestHookWidget extends HookWidget {
  const _TestHookWidget({
    required this.platformIsAndroid,
    required this.activePubkey,
    required this.onBuild,
  });

  final bool platformIsAndroid;
  final String? activePubkey;
  final void Function(AndroidSignerHookResult) onBuild;

  @override
  Widget build(BuildContext context) {
    final result = useAndroidSigner(
      platformIsAndroid: platformIsAndroid,
      activePubkey: activePubkey,
    );
    onBuild(result);
    return const SizedBox();
  }
}

void main() {
  group('useAndroidSigner', () {
    late dynamic mockChannel;

    setUp(() {
      mockChannel = mockAndroidSignerChannel();
    });

    tearDown(() {
      mockChannel.reset();
    });

    Future<AndroidSignerHookResult Function()> mountHook(
      WidgetTester tester, {
      bool platformIsAndroid = false,
      String? activePubkey,
    }) async {
      late AndroidSignerHookResult result;
      setUpTestView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: _TestHookWidget(
            platformIsAndroid: platformIsAndroid,
            activePubkey: activePubkey,
            onBuild: (r) => result = r,
          ),
        ),
      );
      return () => result;
    }

    testWidgets('initially has isAvailable false when not Android', (tester) async {
      final getResult = await mountHook(tester);
      await tester.pumpAndSettle();
      expect(getResult().isAvailable, isFalse);
    });

    testWidgets('sets isAvailable true when signer is available', (tester) async {
      mockChannel.setResult('isExternalSignerInstalled', true);
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();
      expect(getResult().isAvailable, isTrue);
    });

    testWidgets('sets isAvailable false when isAvailable returns false (PlatformException)', (
      tester,
    ) async {
      mockChannel.setException(
        'isExternalSignerInstalled',
        PlatformException(code: 'ERROR', message: 'Platform error'),
      );
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();
      expect(getResult().isAvailable, isFalse);
    });

    testWidgets('sets isAvailable false when service throws non PlatformException', (tester) async {
      mockChannel.setError('isExternalSignerInstalled', StateError('channel failed'));
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();
      expect(getResult().isAvailable, isFalse);
    });

    testWidgets('connect calls getPublicKey on service', (tester) async {
      mockChannel.setResult('isExternalSignerInstalled', true);
      mockChannel.setResult('getPublicKey', {'result': testPubkeyA});
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();

      final pubkey = await getResult().connect();

      expect(pubkey, testPubkeyA);
      expect(mockChannel.log.any((c) => c.method == 'getPublicKey'), isTrue);
    });

    testWidgets('connect rethrows exception from service', (tester) async {
      mockChannel.setResult('isExternalSignerInstalled', true);
      mockChannel.setException(
        'getPublicKey',
        PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
      );
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();

      expect(
        () => getResult().connect(),
        throwsA(isA<AndroidSignerException>()),
      );
    });

    testWidgets('sets error when connect throws non-AndroidSignerException', (tester) async {
      mockChannel.setResult('isExternalSignerInstalled', true);
      mockChannel.setException(
        'getPublicKey',
        PlatformException(code: 'UNKNOWN', message: 'Generic error'),
      );
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();

      try {
        await getResult().connect();
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(getResult().error, 'Unable to connect to signer. Please try again.');
    });

    testWidgets('disconnect resets error state', (tester) async {
      mockChannel.setResult('isExternalSignerInstalled', true);
      mockChannel.setException(
        'getPublicKey',
        PlatformException(code: 'UNKNOWN', message: 'Generic error'),
      );
      final getResult = await mountHook(tester, platformIsAndroid: true);
      await tester.pumpAndSettle();

      try {
        await getResult().connect();
      } catch (_) {}
      await tester.pumpAndSettle();

      expect(getResult().error, isNotNull);

      await getResult().disconnect();
      await tester.pumpAndSettle();

      expect(getResult().error, isNull);
    });
  });
}
