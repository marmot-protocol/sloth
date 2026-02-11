import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_onboarding_carousel.dart';

import '../test_helpers.dart';

const _testInterval = Duration(milliseconds: 500);

class _TestCarouselWidget extends HookWidget {
  const _TestCarouselWidget({
    required this.autoAdvanceInterval,
    required this.onResult,
  });

  final Duration autoAdvanceInterval;
  final void Function(
    PageController pageController,
    int currentIndex,
    void Function(int) onPageChanged,
    void Function(int) goToPage,
  )
  onResult;

  @override
  Widget build(BuildContext context) {
    final (
      :pageController,
      :currentIndex,
      :onPageChanged,
      :goToPage,
    ) = useOnboardingCarousel(
      autoAdvanceInterval: autoAdvanceInterval,
    );

    onResult(pageController, currentIndex, onPageChanged, goToPage);

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onPageChanged,
        itemBuilder: (_, index) => Center(child: Text('Page ${index % 3}')),
      ),
    );
  }
}

Future<
  ({
    PageController Function() pageController,
    int Function() currentIndex,
    void Function(int) Function() onPageChanged,
    void Function(int) Function() goToPage,
  })
>
_mountCarouselWithAutoAdvance(
  WidgetTester tester, {
  Duration autoAdvanceInterval = _testInterval,
}) async {
  setUpTestView(tester);

  late PageController pageController;
  late int currentIndex;
  late void Function(int) onPageChanged;
  late void Function(int) goToPage;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: _TestCarouselWidget(
          autoAdvanceInterval: autoAdvanceInterval,
          onResult: (pc, ci, opc, gtp) {
            pageController = pc;
            currentIndex = ci;
            onPageChanged = opc;
            goToPage = gtp;
          },
        ),
      ),
    ),
  );

  return (
    pageController: () => pageController,
    currentIndex: () => currentIndex,
    onPageChanged: () => onPageChanged,
    goToPage: () => goToPage,
  );
}

void main() {
  group('useOnboardingCarousel', () {
    group('initialization', () {
      testWidgets('returns pageController', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        final result = getResult();
        expect(result.pageController, isA<PageController>());
      });

      testWidgets('initial currentIndex is 0', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        final result = getResult();
        expect(result.currentIndex, 0);
      });

      testWidgets('returns onPageChanged callback', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        final result = getResult();
        expect(result.onPageChanged, isA<Function>());
      });

      testWidgets('returns goToPage callback', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        final result = getResult();
        expect(result.goToPage, isA<Function>());
      });
    });

    group('page controller', () {
      testWidgets('pageController starts at page divisible by slide count', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        final result = getResult();
        expect(result.pageController.initialPage % 3, 0);
      });
    });

    group('onPageChanged', () {
      testWidgets('onPageChanged updates currentIndex with modulo', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        var result = getResult();

        result.onPageChanged(499);
        await tester.pump();

        result = getResult();
        expect(result.currentIndex, 1);
      });

      testWidgets('onPageChanged wraps around for slide count', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        var result = getResult();

        result.onPageChanged(501);
        await tester.pump();

        result = getResult();
        expect(result.currentIndex, 0);
      });

      testWidgets('onPageChanged handles page 500 as index 2', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        var result = getResult();

        result.onPageChanged(500);
        await tester.pump();

        result = getResult();
        expect(result.currentIndex, 2);
      });
    });

    group('slide count', () {
      test('onboardingCarouselSlideCount returns 3', () {
        expect(onboardingCarouselSlideCount, 3);
      });
    });

    group('auto-advance', () {
      Future<void> waitForAutoAdvance(WidgetTester tester) async {
        await tester.pump(_testInterval + const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
      }

      testWidgets('advances page after interval', (tester) async {
        final result = await _mountCarouselWithAutoAdvance(tester);
        await tester.pump();
        await tester.pump();
        final initialPage = result.pageController().page!.round();

        await waitForAutoAdvance(tester);

        expect(result.pageController().page!.round(), initialPage + 1);
      });

      testWidgets('updates currentIndex after advance', (tester) async {
        final result = await _mountCarouselWithAutoAdvance(tester);
        await tester.pump();
        await tester.pump();

        await waitForAutoAdvance(tester);

        expect(result.currentIndex(), 1);
      });

      testWidgets('continues advancing on subsequent intervals', (tester) async {
        final result = await _mountCarouselWithAutoAdvance(tester);
        await tester.pump();
        await tester.pump();

        await waitForAutoAdvance(tester);
        await waitForAutoAdvance(tester);

        expect(result.currentIndex(), 2);
      });
    });

    group('goToPage', () {
      testWidgets('does nothing when controller has no clients', (tester) async {
        final getResult = await mountHook(tester, useOnboardingCarousel);
        final result = getResult();

        result.goToPage(1);
        await tester.pump();

        expect(result.pageController.hasClients, isFalse);
      });

      testWidgets('navigates forward', (tester) async {
        final result = await _mountCarouselWithAutoAdvance(tester);
        await tester.pumpAndSettle();
        final initialPage = result.pageController().page!.round();

        result.goToPage()(2);
        await tester.pumpAndSettle();

        expect(result.pageController().page!.round(), initialPage + 2);
      });

      testWidgets('navigates backward', (tester) async {
        final result = await _mountCarouselWithAutoAdvance(tester);
        await tester.pumpAndSettle();

        result.goToPage()(2);
        await tester.pumpAndSettle();

        result.goToPage()(0);
        await tester.pumpAndSettle();

        expect(result.currentIndex(), 0);
      });

      testWidgets('stays on same page when same index', (tester) async {
        final result = await _mountCarouselWithAutoAdvance(tester);
        await tester.pumpAndSettle();
        final initialPage = result.pageController().page!.round();

        result.goToPage()(0);
        await tester.pumpAndSettle();

        expect(result.pageController().page!.round(), initialPage);
      });
    });
  });
}
