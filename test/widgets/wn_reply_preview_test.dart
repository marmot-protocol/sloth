import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/models/reply_preview.dart';
import 'package:whitenoise/src/rust/api/metadata.dart';
import 'package:whitenoise/widgets/wn_reply_preview.dart';
import '../test_helpers.dart';

ReplyPreview _replyData({
  String messageId = 'test-message-id',
  String authorPubkey = testPubkeyA,
  FlutterMetadata? authorMetadata,
  String content = 'Reply content',
  bool isNotFound = false,
}) => (
  messageId: messageId,
  authorPubkey: authorPubkey,
  authorMetadata: authorMetadata,
  content: content,
  isNotFound: isNotFound,
);

void main() {
  group('WnReplyPreview', () {
    testWidgets('renders author displayName from authorMetadata when present', (tester) async {
      await mountWidget(
        WnReplyPreview(
          data: _replyData(
            authorMetadata: const FlutterMetadata(displayName: 'Test Author', custom: {}),
          ),
        ),
        tester,
      );

      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('renders author name from authorMetadata when displayName is null', (tester) async {
      await mountWidget(
        WnReplyPreview(
          data: _replyData(
            authorMetadata: const FlutterMetadata(name: 'Fallback Name', custom: {}),
          ),
        ),
        tester,
      );

      expect(find.text('Fallback Name'), findsOneWidget);
    });

    testWidgets('renders unknown user when authorMetadata is null', (tester) async {
      await mountWidget(
        WnReplyPreview(data: _replyData()),
        tester,
      );

      expect(find.text('Unknown user'), findsOneWidget);
    });

    testWidgets('renders You when currentUserPubkey equals authorPubkey', (tester) async {
      await mountWidget(
        WnReplyPreview(
          data: _replyData(),
          currentUserPubkey: testPubkeyA,
        ),
        tester,
      );

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('renders Unknown user when isNotFound', (tester) async {
      await mountWidget(
        WnReplyPreview(data: _replyData(content: 'ignored', isNotFound: true)),
        tester,
      );

      expect(find.text('Unknown user'), findsOneWidget);
    });

    testWidgets('renders Message not found when isNotFound', (tester) async {
      await mountWidget(
        WnReplyPreview(data: _replyData(content: 'ignored', isNotFound: true)),
        tester,
      );

      expect(find.text('Message not found'), findsOneWidget);
    });

    testWidgets('renders content when not isNotFound', (tester) async {
      await mountWidget(
        WnReplyPreview(data: _replyData(content: 'This is the reply content')),
        tester,
      );

      expect(find.text('This is the reply content'), findsOneWidget);
    });

    testWidgets('shows cancel button when onCancel is provided', (tester) async {
      await mountWidget(
        WnReplyPreview(
          data: _replyData(),
          onCancel: () {},
        ),
        tester,
      );

      expect(find.byKey(const Key('cancel_reply_button')), findsOneWidget);
    });

    testWidgets('hides cancel button when onCancel is null', (tester) async {
      await mountWidget(
        WnReplyPreview(data: _replyData()),
        tester,
      );

      expect(find.byKey(const Key('cancel_reply_button')), findsNothing);
    });

    testWidgets('calls onCancel when cancel button is tapped', (tester) async {
      var cancelCalled = false;
      await mountWidget(
        WnReplyPreview(
          data: _replyData(),
          onCancel: () => cancelCalled = true,
        ),
        tester,
      );

      await tester.tap(find.byKey(const Key('cancel_reply_button')));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });

    testWidgets('content text is single line with ellipsis', (tester) async {
      await mountWidget(
        WnReplyPreview(data: _replyData(content: 'Some content')),
        tester,
      );

      final textWidget = tester.widget<Text>(find.text('Some content'));
      expect((textWidget.maxLines, textWidget.overflow), (1, TextOverflow.ellipsis));
    });

    testWidgets('author name text is single line with ellipsis', (tester) async {
      await mountWidget(
        WnReplyPreview(
          data: _replyData(
            authorMetadata: const FlutterMetadata(displayName: 'Author', custom: {}),
          ),
        ),
        tester,
      );

      final textWidget = tester.widget<Text>(find.text('Author'));
      expect((textWidget.maxLines, textWidget.overflow), (1, TextOverflow.ellipsis));
    });

    group('onTap', () {
      testWidgets('calls onTap when tapped', (tester) async {
        var tapCalled = false;
        await mountWidget(
          WnReplyPreview(
            data: _replyData(),
            onTap: () => tapCalled = true,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('reply_preview_tap_area')));
        await tester.pumpAndSettle();

        expect(tapCalled, isTrue);
      });

      testWidgets('no tap area key when onTap is null', (tester) async {
        await mountWidget(
          WnReplyPreview(data: _replyData()),
          tester,
        );

        expect(find.byKey(const Key('reply_preview_tap_area')), findsNothing);
      });

      testWidgets('works with both onTap and onCancel', (tester) async {
        var tapCalled = false;
        var cancelCalled = false;
        await mountWidget(
          WnReplyPreview(
            data: _replyData(),
            onTap: () => tapCalled = true,
            onCancel: () => cancelCalled = true,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('cancel_reply_button')));
        await tester.pumpAndSettle();
        expect(cancelCalled, isTrue);
        expect(tapCalled, isFalse);
      });
    });
  });
}
