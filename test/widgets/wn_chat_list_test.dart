import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_chat_list.dart';

import '../test_helpers.dart';

void main() {
  group('WnChatList', () {
    group('loading state', () {
      testWidgets('shows loading indicator when loading with no items', (tester) async {
        await mountWidget(
          const WnChatList(itemCount: 0, isLoading: true, itemBuilder: _emptyBuilder),
          tester,
        );
        await tester.pump();

        expect(find.byKey(const Key('chat_list_loading')), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('does not show loading indicator when items exist', (tester) async {
        await mountWidget(
          const WnChatList(itemCount: 2, isLoading: true, itemBuilder: _textBuilder),
          tester,
        );
        await tester.pump();

        expect(find.byKey(const Key('chat_list_loading')), findsNothing);
        expect(find.byKey(const Key('chat_list')), findsOneWidget);
      });
    });

    group('empty state', () {
      testWidgets('shows empty state when not loading and no items', (tester) async {
        await mountWidget(
          const WnChatList(itemCount: 0, itemBuilder: _emptyBuilder),
          tester,
        );
        await tester.pump();

        expect(find.byKey(const Key('chat_list_empty')), findsOneWidget);
        expect(find.text('No chats yet'), findsOneWidget);
        expect(find.text('Start a conversation'), findsOneWidget);
      });
    });

    group('list state', () {
      testWidgets('renders items via itemBuilder', (tester) async {
        await mountWidget(
          const WnChatList(itemCount: 3, itemBuilder: _textBuilder),
          tester,
        );
        await tester.pump();

        expect(find.byKey(const Key('chat_list')), findsOneWidget);
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
      });

      testWidgets('list is scrollable', (tester) async {
        await mountWidget(
          WnChatList(
            itemCount: 50,
            itemBuilder: (context, index) => SizedBox(
              height: 76,
              child: Text('Item $index'),
            ),
          ),
          tester,
        );
        await tester.pump();

        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 49'), findsNothing);

        await tester.drag(find.byKey(const Key('chat_list')), const Offset(0, -3000));
        await tester.pump();

        expect(find.text('Item 49'), findsOneWidget);
      });

      testWidgets('applies top padding including topPadding param', (tester) async {
        await mountWidget(
          const WnChatList(itemCount: 1, topPadding: 80, itemBuilder: _textBuilder),
          tester,
        );
        await tester.pump();

        final listView = tester.widget<ListView>(find.byType(ListView));
        final padding = listView.padding!;
        final resolved = padding.resolve(TextDirection.ltr);
        expect(resolved.top, greaterThanOrEqualTo(80));
      });

      testWidgets('applies horizontal padding', (tester) async {
        await mountWidget(
          const WnChatList(itemCount: 1, itemBuilder: _textBuilder),
          tester,
        );
        await tester.pump();

        final listView = tester.widget<ListView>(find.byType(ListView));
        final padding = listView.padding!;
        final resolved = padding.resolve(TextDirection.ltr);
        expect(resolved.left, greaterThan(0));
        expect(resolved.right, greaterThan(0));
      });
    });

    group('scroll edge effect', () {
      testWidgets('does not show scroll edge effect at top initially', (tester) async {
        await mountWidget(
          WnChatList(
            itemCount: 50,
            itemBuilder: (context, index) => SizedBox(
              height: 76,
              child: Text('Item $index'),
            ),
          ),
          tester,
        );
        await tester.pump();

        expect(find.byKey(const Key('chat_list_scroll_edge')), findsNothing);
      });

      testWidgets('shows scroll edge effect after scrolling down', (tester) async {
        await mountWidget(
          WnChatList(
            itemCount: 50,
            itemBuilder: (context, index) => SizedBox(
              height: 76,
              child: Text('Item $index'),
            ),
          ),
          tester,
        );
        await tester.pump();

        await tester.drag(find.byKey(const Key('chat_list')), const Offset(0, -200));
        await tester.pump();

        expect(find.byKey(const Key('chat_list_scroll_edge')), findsOneWidget);
      });

      testWidgets('hides scroll edge effect when scrolled back to top', (tester) async {
        await mountWidget(
          WnChatList(
            itemCount: 50,
            itemBuilder: (context, index) => SizedBox(
              height: 76,
              child: Text('Item $index'),
            ),
          ),
          tester,
        );
        await tester.pump();

        await tester.drag(find.byKey(const Key('chat_list')), const Offset(0, -200));
        await tester.pump();
        expect(find.byKey(const Key('chat_list_scroll_edge')), findsOneWidget);

        await tester.drag(find.byKey(const Key('chat_list')), const Offset(0, 200));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('chat_list_scroll_edge')), findsNothing);
      });
    });
  });
}

Widget _emptyBuilder(BuildContext context, int index) => const SizedBox.shrink();

Widget _textBuilder(BuildContext context, int index) => SizedBox(
  height: 76,
  child: Text('Item $index'),
);
