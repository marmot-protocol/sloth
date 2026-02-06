import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_emoji_picker.dart';
import '../test_helpers.dart';

void main() {
  group('WnEmojiPicker', () {
    Future<void> mountEmojiPicker(
      WidgetTester tester, {
      VoidCallback? onClose,
      void Function(String)? onEmojiSelected,
    }) async {
      await mountWidget(
        WnEmojiPicker(
          onClose: onClose ?? () {},
          onEmojiSelected: onEmojiSelected ?? (_) {},
        ),
        tester,
      );
    }

    testWidgets('displays close button', (tester) async {
      await mountEmojiPicker(tester);

      expect(find.byKey(const Key('emoji_picker_close_button')), findsOneWidget);
    });

    testWidgets('calls onClose when close button is tapped', (tester) async {
      var closeCalled = false;
      await mountEmojiPicker(tester, onClose: () => closeCalled = true);

      await tester.tap(find.byKey(const Key('emoji_picker_close_button')));
      await tester.pumpAndSettle();

      expect(closeCalled, isTrue);
    });

    group('EmojiPicker config', () {
      testWidgets('shows smileys category on initial load', (tester) async {
        await mountEmojiPicker(tester);

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        expect(emojiPicker.config.categoryViewConfig.initCategory, Category.SMILEYS);
      });

      testWidgets('has custom category view', (tester) async {
        await mountEmojiPicker(tester);

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        expect(emojiPicker.config.categoryViewConfig.customCategoryView, isNotNull);
      });

      testWidgets('has bottom action bar disabled', (tester) async {
        await mountEmojiPicker(tester);

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        expect(emojiPicker.config.bottomActionBarConfig.enabled, isFalse);
      });

      testWidgets('displays 8 emoji columns', (tester) async {
        await mountEmojiPicker(tester);

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        expect(emojiPicker.config.emojiViewConfig.columns, 8);
      });
    });

    group('onEmojiSelected', () {
      testWidgets('triggers callback with selected emoji', (tester) async {
        String? receivedEmoji;
        await mountEmojiPicker(
          tester,
          onEmojiSelected: (emoji) => receivedEmoji = emoji,
        );

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        emojiPicker.onEmojiSelected!(Category.SMILEYS, const Emoji('😀', 'grinning face'));
        await tester.pumpAndSettle();

        expect(receivedEmoji, '😀');
      });
    });

    group('category bar', () {
      Future<({CategoryViewBuilder customCategoryView, Config emojiConfig})> getEmojiPickerConfig(
        WidgetTester tester,
      ) async {
        await mountEmojiPicker(tester);

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        return (
          customCategoryView: emojiPicker.config.categoryViewConfig.customCategoryView!,
          emojiConfig: emojiPicker.config,
        );
      }

      Future<void> mountCategoryBar(
        WidgetTester tester,
        CategoryViewBuilder customCategoryView,
        Config emojiConfig, {
        PageController? pageController,
        void Function(TabController)? onTabController,
      }) async {
        final pc = pageController ?? PageController();
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: testDesignSize,
            builder: (_, _) => MaterialApp(
              home: DefaultTabController(
                length: 9,
                child: Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    onTabController?.call(tabController);
                    final state = EmojiViewState(
                      const [],
                      (_, _) {},
                      () {},
                      () {},
                      () {},
                      (_) {},
                    );
                    return Scaffold(
                      body: Column(
                        children: [
                          customCategoryView(emojiConfig, state, tabController, pc),
                          Expanded(
                            child: PageView(
                              controller: pc,
                              children: List.generate(9, (i) => Container()),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }

      testWidgets('displays all 9 category tabs', (tester) async {
        final config = await getEmojiPickerConfig(tester);
        await mountCategoryBar(tester, config.customCategoryView, config.emojiConfig);

        const categories = [
          'recent',
          'smileys',
          'animals',
          'foods',
          'activities',
          'travel',
          'objects',
          'symbols',
          'flags',
        ];
        for (final category in categories) {
          expect(find.byKey(Key('emoji_category_$category')), findsOneWidget);
        }
      });

      testWidgets('tab controller starts at index 0', (tester) async {
        final config = await getEmojiPickerConfig(tester);
        late TabController tabController;
        await mountCategoryBar(
          tester,
          config.customCategoryView,
          config.emojiConfig,
          onTabController: (tc) => tabController = tc,
        );

        expect(tabController.index, 0);
      });

      testWidgets('page controller starts at page 0', (tester) async {
        final config = await getEmojiPickerConfig(tester);
        final pageController = PageController();
        await mountCategoryBar(
          tester,
          config.customCategoryView,
          config.emojiConfig,
          pageController: pageController,
        );

        expect(pageController.page, 0);
      });

      testWidgets('tapping category updates tab controller index', (tester) async {
        final config = await getEmojiPickerConfig(tester);
        late TabController tabController;
        await mountCategoryBar(
          tester,
          config.customCategoryView,
          config.emojiConfig,
          onTabController: (tc) => tabController = tc,
        );

        final gestureDetector = tester.widget<GestureDetector>(
          find.descendant(
            of: find.byKey(const Key('emoji_category_animals')),
            matching: find.byType(GestureDetector),
          ),
        );
        gestureDetector.onTap!();
        await tester.pumpAndSettle();

        expect(tabController.index, 2);
      });

      testWidgets('tapping category updates page controller page', (tester) async {
        final config = await getEmojiPickerConfig(tester);
        final pageController = PageController();
        await mountCategoryBar(
          tester,
          config.customCategoryView,
          config.emojiConfig,
          pageController: pageController,
        );

        final gestureDetector = tester.widget<GestureDetector>(
          find.descendant(
            of: find.byKey(const Key('emoji_category_animals')),
            matching: find.byType(GestureDetector),
          ),
        );
        gestureDetector.onTap!();
        await tester.pumpAndSettle();

        expect(pageController.page, 2);
      });
    });
  });
}
