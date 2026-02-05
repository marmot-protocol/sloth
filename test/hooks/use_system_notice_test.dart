import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_system_notice.dart';
import 'package:sloth/widgets/wn_system_notice.dart';

import '../test_helpers.dart';

void main() {
  group('useSystemNotice', () {
    testWidgets('showSuccessNotice sets message with success type', (tester) async {
      final getResult = await mountHook(tester, useSystemNotice);
      await tester.pump();

      expect(getResult().noticeMessage, isNull);
      expect(getResult().noticeType, WnSystemNoticeType.success);

      getResult().showSuccessNotice('Copied!');
      await tester.pump();

      expect(getResult().noticeMessage, 'Copied!');
      expect(getResult().noticeType, WnSystemNoticeType.success);
    });

    testWidgets('showErrorNotice sets message with error type', (tester) async {
      final getResult = await mountHook(tester, useSystemNotice);
      await tester.pump();
      expect(getResult().noticeMessage, isNull);
      getResult().showErrorNotice('Error');
      await tester.pump();

      expect(getResult().noticeMessage, 'Error');
      expect(getResult().noticeType, WnSystemNoticeType.error);
    });

    testWidgets('dismissNotice clears message', (tester) async {
      final getResult = await mountHook(tester, useSystemNotice);
      await tester.pump();

      getResult().showSuccessNotice('Copied!');
      await tester.pump();
      expect(getResult().noticeMessage, 'Copied!');

      getResult().dismissNotice();
      await tester.pump();
      expect(getResult().noticeMessage, isNull);
    });
  });
}
