import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_dropdown_selector.dart';

import '../test_helpers.dart';

void main() {
  group('WnDropdownSelector', () {
    testWidgets('displays label', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test Label',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
            WnDropdownOption(value: 'b', label: 'Option B'),
          ],
          value: 'a',
          onChanged: (_) {},
        ),
        tester,
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('displays current value', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
            WnDropdownOption(value: 'b', label: 'Option B'),
          ],
          value: 'a',
          onChanged: (_) {},
        ),
        tester,
      );

      expect(find.text('Option A'), findsOneWidget);
    });

    testWidgets('shows dropdown options when tapped', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
            WnDropdownOption(value: 'b', label: 'Option B'),
            WnDropdownOption(value: 'c', label: 'Option C'),
          ],
          value: 'a',
          onChanged: (_) {},
        ),
        tester,
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Option A'), findsWidgets);
      expect(find.text('Option B'), findsOneWidget);
      expect(find.text('Option C'), findsOneWidget);
    });

    testWidgets('calls onChanged when option is selected', (tester) async {
      String? selectedValue;

      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
            WnDropdownOption(value: 'b', label: 'Option B'),
          ],
          value: 'a',
          onChanged: (value) => selectedValue = value,
        ),
        tester,
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'b');
    });

    testWidgets('works with enum values', (tester) async {
      ThemeMode? selectedMode;

      await mountWidget(
        WnDropdownSelector<ThemeMode>(
          label: 'Theme',
          options: const [
            WnDropdownOption(value: ThemeMode.system, label: 'System'),
            WnDropdownOption(value: ThemeMode.light, label: 'Light'),
            WnDropdownOption(value: ThemeMode.dark, label: 'Dark'),
          ],
          value: ThemeMode.system,
          onChanged: (value) => selectedMode = value,
        ),
        tester,
      );

      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      expect(selectedMode, ThemeMode.dark);
    });

    testWidgets('displays dropdown icon', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
          ],
          value: 'a',
          onChanged: (_) {},
        ),
        tester,
      );

      expect(find.byKey(const Key('dropdown_icon')), findsOneWidget);
    });

    testWidgets('works with int values', (tester) async {
      int? selectedValue;

      await mountWidget(
        WnDropdownSelector<int>(
          label: 'Numbers',
          options: const [
            WnDropdownOption(value: 1, label: 'One'),
            WnDropdownOption(value: 2, label: 'Two'),
            WnDropdownOption(value: 3, label: 'Three'),
          ],
          value: 1,
          onChanged: (value) => selectedValue = value,
        ),
        tester,
      );

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Three').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 3);
    });

    testWidgets('displays correct selected value after change', (tester) async {
      String currentValue = 'a';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: WnDropdownSelector<String>(
                  label: 'Test',
                  options: const [
                    WnDropdownOption(value: 'a', label: 'Option A'),
                    WnDropdownOption(value: 'b', label: 'Option B'),
                  ],
                  value: currentValue,
                  onChanged: (value) => setState(() => currentValue = value),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Option B').last);
      await tester.pumpAndSettle();

      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets('handles single option', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Single',
          options: const [
            WnDropdownOption(value: 'only', label: 'Only Option'),
          ],
          value: 'only',
          onChanged: (_) {},
        ),
        tester,
      );

      expect(find.text('Only Option'), findsOneWidget);
    });
  });

  group('WnDropdownOption', () {
    test('stores value and label correctly', () {
      const option = WnDropdownOption(value: 42, label: 'Forty Two');

      expect(option.value, 42);
      expect(option.label, 'Forty Two');
    });

    test('works with nullable types', () {
      const option = WnDropdownOption<String?>(value: null, label: 'None');

      expect(option.value, isNull);
      expect(option.label, 'None');
    });
  });
}
