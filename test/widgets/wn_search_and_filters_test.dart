import 'package:flutter/material.dart' show Key, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_filter_chip.dart';
import 'package:whitenoise/widgets/wn_search_and_filters.dart';
import 'package:whitenoise/widgets/wn_search_field.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnSearchAndFilters', () {
    group('structure', () {
      testWidgets('renders search field', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.byType(WnSearchField), findsOneWidget);
      });

      testWidgets('renders search field with Search placeholder', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.text('Search'), findsOneWidget);
      });

      testWidgets('renders two filter chips', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.byType(WnFilterChip), findsNWidgets(2));
      });

      testWidgets('renders Chats filter chip', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.text('Chats'), findsOneWidget);
      });

      testWidgets('renders Archive filter chip', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.text('Archive'), findsOneWidget);
      });

      testWidgets('renders filter chips row', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.byKey(const Key('filter_chips_row')), findsOneWidget);
      });

      testWidgets('renders search and filters container', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);
        expect(find.byKey(const Key('search_and_filters')), findsOneWidget);
      });
    });

    group('default state', () {
      testWidgets('Chats filter is selected by default', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        final chatsChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_chats')),
        );
        expect(chatsChip.selected, isTrue);
      });

      testWidgets('Archive filter is not selected by default', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        final archiveChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_archive')),
        );
        expect(archiveChip.selected, isFalse);
      });
    });

    group('search callback', () {
      testWidgets('calls onSearchChanged when text is entered', (tester) async {
        String? searchValue;
        await mountWidget(
          WnSearchAndFilters(onSearchChanged: (value) => searchValue = value),
          tester,
        );

        await tester.enterText(find.byType(TextField), 'hello');
        expect(searchValue, 'hello');
      });

      testWidgets('does not crash when onSearchChanged is null', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        await tester.enterText(find.byType(TextField), 'hello');
        await tester.pump();
        expect(find.text('hello'), findsOneWidget);
      });
    });

    group('filter selection', () {
      testWidgets('tapping Archive selects it and deselects Chats', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        await tester.tap(find.byKey(const Key('filter_chip_archive')));
        await tester.pump();

        final archiveChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_archive')),
        );
        final chatsChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_chats')),
        );
        expect(archiveChip.selected, isTrue);
        expect(chatsChip.selected, isFalse);
      });

      testWidgets('tapping Chats when Archive is selected switches back', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        await tester.tap(find.byKey(const Key('filter_chip_archive')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('filter_chip_chats')));
        await tester.pump();

        final chatsChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_chats')),
        );
        final archiveChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_archive')),
        );
        expect(chatsChip.selected, isTrue);
        expect(archiveChip.selected, isFalse);
      });

      testWidgets('tapping already selected Chats keeps it selected', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        await tester.tap(find.byKey(const Key('filter_chip_chats')));
        await tester.pump();

        final chatsChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_chats')),
        );
        expect(chatsChip.selected, isTrue);
      });
    });

    group('filter callback', () {
      testWidgets('calls onFilterChanged with archive when Archive is tapped', (tester) async {
        ChatFilter? filterValue;
        await mountWidget(
          WnSearchAndFilters(onFilterChanged: (filter) => filterValue = filter),
          tester,
        );

        await tester.tap(find.byKey(const Key('filter_chip_archive')));
        await tester.pump();
        expect(filterValue, ChatFilter.archive);
      });

      testWidgets('calls onFilterChanged with chats when Chats is tapped', (tester) async {
        ChatFilter? filterValue;
        await mountWidget(
          WnSearchAndFilters(onFilterChanged: (filter) => filterValue = filter),
          tester,
        );

        await tester.tap(find.byKey(const Key('filter_chip_archive')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('filter_chip_chats')));
        await tester.pump();
        expect(filterValue, ChatFilter.chats);
      });

      testWidgets('does not crash when onFilterChanged is null', (tester) async {
        await mountWidget(const WnSearchAndFilters(), tester);

        await tester.tap(find.byKey(const Key('filter_chip_archive')));
        await tester.pump();

        final archiveChip = tester.widget<WnFilterChip>(
          find.byKey(const Key('filter_chip_archive')),
        );
        expect(archiveChip.selected, isTrue);
      });
    });
  });
}
