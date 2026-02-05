import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_chat_scroll.dart';

const _withinBottomThreshold = 40.0;

class _TestWidget extends HookWidget {
  const _TestWidget({
    required this.scrollController,
    required this.focusNode,
    required this.latestMessageId,
    this.isLatestMessageOwn = false,
    this.itemCount = 50,
  });

  final ScrollController scrollController;
  final FocusNode focusNode;
  final String? latestMessageId;
  final bool isLatestMessageOwn;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    useChatScroll(
      scrollController: scrollController,
      focusNode: focusNode,
      latestMessageId: latestMessageId,
      isLatestMessageOwn: isLatestMessageOwn,
    );

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                reverse: true,
                itemCount: itemCount,
                itemBuilder: (_, i) => SizedBox(height: 100, child: Text('Item $i')),
              ),
            ),
            TextField(focusNode: focusNode),
          ],
        ),
      ),
    );
  }
}

void main() {
  late ScrollController scrollController;
  late FocusNode focusNode;

  setUp(() {
    scrollController = ScrollController();
    focusNode = FocusNode();
  });

  tearDown(() {
    scrollController.dispose();
    focusNode.unfocus();
    focusNode.dispose();
  });

  Future<void> pumpWidget(
    WidgetTester tester, {
    String? latestMessageId,
    bool isLatestMessageOwn = false,
    int itemCount = 50,
  }) async {
    await tester.pumpWidget(
      _TestWidget(
        scrollController: scrollController,
        focusNode: focusNode,
        latestMessageId: latestMessageId,
        isLatestMessageOwn: isLatestMessageOwn,
        itemCount: itemCount,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> updateWidget(
    WidgetTester tester, {
    String? latestMessageId,
    bool isLatestMessageOwn = false,
    int itemCount = 50,
  }) => pumpWidget(
    tester,
    latestMessageId: latestMessageId,
    isLatestMessageOwn: isLatestMessageOwn,
    itemCount: itemCount,
  );

  group('useChatScroll', () {
    group('initial load scroll', () {
      testWidgets('scrolls to bottom on initial load', (tester) async {
        await pumpWidget(tester);

        scrollController.jumpTo(100);
        await tester.pumpAndSettle();

        await updateWidget(tester, latestMessageId: 'm1');

        expect(scrollController.position.pixels, 0);
      });
    });

    group('new message scroll', () {
      testWidgets('scrolls to bottom when at bottom and new message arrives', (tester) async {
        await pumpWidget(tester, latestMessageId: 'm1');
        await updateWidget(tester, latestMessageId: 'm1');

        expect(scrollController.position.pixels, 0);

        await updateWidget(tester, latestMessageId: 'm2');

        expect(scrollController.position.pixels, 0);
      });

      testWidgets('does not scroll when not at bottom and new message arrives', (tester) async {
        await pumpWidget(tester, latestMessageId: 'm1');
        await updateWidget(tester, latestMessageId: 'm1');

        scrollController.jumpTo(100);
        await tester.pumpAndSettle();

        final positionBefore = scrollController.position.pixels;

        await updateWidget(tester, latestMessageId: 'm2');

        expect(scrollController.position.pixels, positionBefore);
      });
    });

    group('own message scroll', () {
      testWidgets('scrolls to bottom when own message arrives while scrolled up', (tester) async {
        await pumpWidget(tester, latestMessageId: 'm1');
        await updateWidget(tester, latestMessageId: 'm1');

        scrollController.jumpTo(100);
        await tester.pumpAndSettle();

        await updateWidget(tester, latestMessageId: 'm2', isLatestMessageOwn: true);

        expect(scrollController.position.pixels, 0);
      });

      testWidgets('scrolls to bottom when own message arrives while at bottom', (tester) async {
        await pumpWidget(tester, latestMessageId: 'm1');
        await updateWidget(tester, latestMessageId: 'm1');

        expect(scrollController.position.pixels, 0);

        await updateWidget(tester, latestMessageId: 'm2', isLatestMessageOwn: true);

        expect(scrollController.position.pixels, 0);
      });
    });

    group('focus scroll', () {
      testWidgets('scrolls to bottom when input gains focus', (tester) async {
        await pumpWidget(tester);
        await updateWidget(tester);

        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        await tester.pumpAndSettle();

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        expect(scrollController.position.pixels, 0);
      });

      testWidgets('resets shouldStayAtBottom when input loses focus', (tester) async {
        await pumpWidget(tester);
        await updateWidget(tester);

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        expect(scrollController.position.pixels, 0);

        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        await tester.pumpAndSettle();

        focusNode.unfocus();
        await tester.pumpAndSettle();

        expect(scrollController.position.pixels, scrollController.position.maxScrollExtent);
      });
    });

    group('keyboard scroll', () {
      testWidgets('jumps to bottom when metrics change and input is focused', (tester) async {
        await pumpWidget(tester);
        await updateWidget(tester);

        focusNode.requestFocus();
        await tester.pumpAndSettle();

        scrollController.jumpTo(100);

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();

        expect(scrollController.position.pixels, 0);

        addTearDown(() => tester.view.resetViewInsets());
      });

      testWidgets('jumps to bottom when metrics change and at bottom', (tester) async {
        await pumpWidget(tester);
        await updateWidget(tester);

        expect(scrollController.position.pixels, 0);

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();

        expect(scrollController.position.pixels, 0);

        addTearDown(() => tester.view.resetViewInsets());
      });

      testWidgets('does not jump when metrics change and not at bottom and not focused', (
        tester,
      ) async {
        await pumpWidget(tester);
        await updateWidget(tester);

        scrollController.jumpTo(100);
        await tester.pumpAndSettle();

        final positionBefore = scrollController.position.pixels;

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();

        expect(scrollController.position.pixels, positionBefore);

        addTearDown(() => tester.view.resetViewInsets());
      });
    });

    group('isAtBottom tracking', () {
      testWidgets('correctly tracks when scrolled away from bottom', (tester) async {
        await pumpWidget(tester, latestMessageId: 'm1');

        expect(scrollController.position.pixels, 0);

        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        await tester.pumpAndSettle();

        await updateWidget(tester, latestMessageId: 'm2');

        expect(scrollController.position.pixels, scrollController.position.maxScrollExtent);
      });

      testWidgets('considers within threshold as at bottom', (tester) async {
        await pumpWidget(tester);
        await updateWidget(tester, latestMessageId: 'm1');

        scrollController.jumpTo(_withinBottomThreshold);
        await tester.pumpAndSettle();

        await updateWidget(tester, latestMessageId: 'm2');

        expect(scrollController.position.pixels, 0);
      });
    });
  });
}
