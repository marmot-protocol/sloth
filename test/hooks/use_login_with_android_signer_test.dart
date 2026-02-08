import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_login_with_android_signer.dart';

import '../mocks/mock_android_signer_channel.dart';
import '../test_helpers.dart';

void main() {
  group('LoginWithAndroidSignerState', () {
    group('copyWith', () {
      test('preserves isLoading when not specified', () {
        const state = LoginWithAndroidSignerState(isLoading: true);
        final copied = state.copyWith(error: 'test');
        expect(copied.isLoading, isTrue);
      });

      test('preserves error when not specified', () {
        const state = LoginWithAndroidSignerState(error: 'test');
        final copied = state.copyWith(isLoading: true);
        expect(copied.error, 'test');
      });
    });
  });

  group('useLoginWithAndroidSigner', () {
    late MockAndroidSignerChannel mockChannel;
    late LoginWithAndroidSignerCallback loginCallback;

    setUp(() {
      mockChannel = mockAndroidSignerChannel();
      loginCallback = (_) async {};
    });

    tearDown(() {
      mockChannel.reset();
    });

    group('isAndroidSignerAvailable', () {
      group('on iOS', () {
        testWidgets(
          'returns false',
          (tester) async {
            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();

            expect(getResult().isAndroidSignerAvailable, isFalse);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        );
      });

      group('on Android', () {
        group('when signer is available', () {
          testWidgets(
            'returns true',
            (tester) async {
              mockChannel.setResult('isExternalSignerInstalled', true);

              final getResult = await mountHook(
                tester,
                () => useLoginWithAndroidSigner(loginCallback),
              );
              await tester.pumpAndSettle();

              expect(getResult().isAndroidSignerAvailable, isTrue);
            },
            variant: TargetPlatformVariant.only(TargetPlatform.android),
          );
        });

        group('when channel throws PlatformException', () {
          testWidgets(
            'returns false',
            (tester) async {
              mockChannel.setException(
                'isExternalSignerInstalled',
                PlatformException(code: 'ERROR', message: 'Platform error'),
              );

              final getResult = await mountHook(
                tester,
                () => useLoginWithAndroidSigner(loginCallback),
              );
              await tester.pumpAndSettle();

              expect(getResult().isAndroidSignerAvailable, isFalse);
            },
            variant: TargetPlatformVariant.only(TargetPlatform.android),
          );
        });

        group('when channel throws non-PlatformException', () {
          testWidgets(
            'returns false',
            (tester) async {
              mockChannel.setError(
                'isExternalSignerInstalled',
                StateError('channel failed'),
              );

              final getResult = await mountHook(
                tester,
                () => useLoginWithAndroidSigner(loginCallback),
              );
              await tester.pumpAndSettle();

              expect(getResult().isAndroidSignerAvailable, isFalse);
            },
            variant: TargetPlatformVariant.only(TargetPlatform.android),
          );
        });

        group('when checkAvailability throws', () {
          testWidgets(
            'returns false',
            (tester) async {
              mockChannel.setError(
                'isExternalSignerInstalled',
                Exception('Signer unavailable'),
              );

              final getResult = await mountHook(
                tester,
                () => useLoginWithAndroidSigner(loginCallback),
              );
              await tester.pumpAndSettle();
              await tester.pump(const Duration(milliseconds: 50));

              expect(getResult().isAndroidSignerAvailable, isFalse);
            },
            variant: TargetPlatformVariant.only(TargetPlatform.android),
          );
        });
      });
    });

    group('submitLoginWithAndroidSigner', () {
      group('on success', () {
        testWidgets(
          'returns true',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();

            final success = await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(success, isTrue);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );

        testWidgets(
          'passes pubkey to login callback',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            String? capturedPubkey;
            loginCallback = (pubkey) async {
              capturedPubkey = pubkey;
            };

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();
            await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(capturedPubkey, testPubkeyA);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );

        testWidgets(
          'invokes getPublicKey on channel',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();
            await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(mockChannel.log.any((c) => c.method == 'getPublicKey'), isTrue);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );
      });

      group('loading state', () {
        testWidgets(
          'is false initially',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();

            expect(getResult().loginWithAndroidSignerState.isLoading, isFalse);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );

        testWidgets(
          'is true while submit in progress',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final loginCompleter = Completer<void>();
            loginCallback = (_) => loginCompleter.future;

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();

            final submitFuture = getResult().submitLoginWithAndroidSigner();
            await tester.pump();

            expect(getResult().loginWithAndroidSignerState.isLoading, isTrue);

            loginCompleter.complete();
            await submitFuture;
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );

        testWidgets(
          'is false after submit completes',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();
            await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(getResult().loginWithAndroidSignerState.isLoading, isFalse);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );
      });

      group('when getPublicKey throws AndroidSignerException', () {
        testWidgets(
          'returns false',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setException(
              'getPublicKey',
              PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
            );

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();

            final success = await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(success, isFalse);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );

        testWidgets(
          'sets state error to exception code',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setException(
              'getPublicKey',
              PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
            );

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();
            await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(getResult().loginWithAndroidSignerState.error, 'USER_REJECTED');
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );
      });

      group('when getPublicKey throws generic exception', () {
        testWidgets(
          'sets state error',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setError('getPublicKey', Exception('Generic error'));

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(loginCallback),
            );
            await tester.pumpAndSettle();
            await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(getResult().loginWithAndroidSignerState.error, isNotNull);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );
      });

      group('when login callback throws generic exception', () {
        late LoginWithAndroidSignerCallback throwingLoginCallback;

        setUp(() {
          throwingLoginCallback = (_) async {
            throw Exception('Login failed');
          };
        });

        testWidgets(
          'returns false',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(throwingLoginCallback),
            );
            await tester.pumpAndSettle();

            final success = await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(success, isFalse);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );

        testWidgets(
          'sets error to CONNECTION_ERROR',
          (tester) async {
            mockChannel.setResult('isExternalSignerInstalled', true);
            mockChannel.setResult('getPublicKey', {'result': testPubkeyA});

            final getResult = await mountHook(
              tester,
              () => useLoginWithAndroidSigner(throwingLoginCallback),
            );
            await tester.pumpAndSettle();
            await getResult().submitLoginWithAndroidSigner();
            await tester.pumpAndSettle();

            expect(
              getResult().loginWithAndroidSignerState.error,
              'CONNECTION_ERROR',
            );
          },
          variant: TargetPlatformVariant.only(TargetPlatform.android),
        );
      });
    });

    group('clearLoginWithAndroidSignerError', () {
      testWidgets(
        'clears error',
        (tester) async {
          mockChannel.setResult('isExternalSignerInstalled', true);
          mockChannel.setException(
            'getPublicKey',
            PlatformException(code: 'USER_REJECTED', message: 'User rejected'),
          );

          final getResult = await mountHook(
            tester,
            () => useLoginWithAndroidSigner(loginCallback),
          );
          await tester.pumpAndSettle();
          await getResult().submitLoginWithAndroidSigner();
          await tester.pumpAndSettle();

          expect(getResult().loginWithAndroidSignerState.error, isNotNull);

          getResult().clearLoginWithAndroidSignerError();
          await tester.pumpAndSettle();

          expect(getResult().loginWithAndroidSignerState.error, isNull);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.android),
      );
    });
  });
}
