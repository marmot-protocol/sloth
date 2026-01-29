import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_slate_avatar_header.dart';
import '../test_helpers.dart';

void main() {
  group('WnSlateAvatarHeader', () {
    testWidgets('renders avatar', (tester) async {
      await mountWidget(
        const WnSlateAvatarHeader(),
        tester,
      );

      expect(find.byType(WnAvatar), findsOneWidget);
    });
  });
}
