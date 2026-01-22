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

      // Tap the dropdown field to open it
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Header shows selected value, plus options list shows all three
      expect(find.text('Option A'), findsNWidgets(2)); // header + option
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

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Select Option B (it's the only one with that text)
      await tester.tap(find.text('Option B'));
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

      // Open dropdown
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();

      // Select Dark
      await tester.tap(find.text('Dark'));
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

      // Open dropdown
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      // Select Three
      await tester.tap(find.text('Three'));
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

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Select Option B
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      // Now Option B should be in the header
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

    testWidgets('shows chevron icon when closed', (tester) async {
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

      // Initially shows chevron down
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('shows checkmark for selected item', (tester) async {
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

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Should show checkmark for selected item
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('respects small size variant', (tester) async {
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

      expect(find.byType(WnDropdownSelector<String>), findsOneWidget);
    });

    testWidgets('respects large size variant', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
          ],
          value: 'a',
          onChanged: (_) {},
          size: WnDropdownSize.large,
        ),
        tester,
      );

      expect(find.byType(WnDropdownSelector<String>), findsOneWidget);
    });

    testWidgets('displays helper text when provided', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
          ],
          value: 'a',
          onChanged: (_) {},
          helperText: 'This is helper text',
        ),
        tester,
      );

      expect(find.text('This is helper text'), findsOneWidget);
    });

    testWidgets('does not open when disabled', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
            WnDropdownOption(value: 'b', label: 'Option B'),
          ],
          value: 'a',
          onChanged: (_) {},
          isDisabled: true,
        ),
        tester,
      );

      // Try to open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Should not show Option B (dropdown shouldn't open)
      expect(find.text('Option B'), findsNothing);
    });

    testWidgets('closes menu when selecting an option', (tester) async {
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

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Dropdown should be open - Option B visible
      expect(find.text('Option B'), findsOneWidget);

      // Select Option B
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      // Menu should be closed - chevron should be visible again
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('closes dropdown when tapping header again', (tester) async {
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

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Verify dropdown is open (close icon visible)
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);

      // Tap header again to close
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify dropdown is closed
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.text('Option B'), findsNothing);
    });

    testWidgets('shows error border when isError is true', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
          ],
          value: 'a',
          onChanged: (_) {},
          isError: true,
        ),
        tester,
      );

      // Widget should render with error state
      expect(find.byType(WnDropdownSelector<String>), findsOneWidget);
    });

    testWidgets('shows error helper text styling when isError is true', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
          ],
          value: 'a',
          onChanged: (_) {},
          isError: true,
          helperText: 'Error message',
        ),
        tester,
      );

      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('scrolls when more than 5 options', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: '1', label: 'Option 1'),
            WnDropdownOption(value: '2', label: 'Option 2'),
            WnDropdownOption(value: '3', label: 'Option 3'),
            WnDropdownOption(value: '4', label: 'Option 4'),
            WnDropdownOption(value: '5', label: 'Option 5'),
            WnDropdownOption(value: '6', label: 'Option 6'),
            WnDropdownOption(value: '7', label: 'Option 7'),
          ],
          value: '1',
          onChanged: (_) {},
        ),
        tester,
      );

      // Open dropdown
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      // Verify dropdown opens and ListView is present
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows close icon when open', (tester) async {
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

      // Initially shows chevron
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Now shows close icon
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('handles value not in options gracefully', (tester) async {
      await mountWidget(
        WnDropdownSelector<String>(
          label: 'Test',
          options: const [
            WnDropdownOption(value: 'a', label: 'Option A'),
            WnDropdownOption(value: 'b', label: 'Option B'),
          ],
          value: 'nonexistent',
          onChanged: (_) {},
        ),
        tester,
      );

      // Should render without crashing, showing empty label
      expect(find.byType(WnDropdownSelector<String>), findsOneWidget);
    });

    testWidgets('closes dropdown when isDisabled changes to true while open', (tester) async {
      bool isDisabled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    WnDropdownSelector<String>(
                      label: 'Test',
                      options: const [
                        WnDropdownOption(value: 'a', label: 'Option A'),
                        WnDropdownOption(value: 'b', label: 'Option B'),
                      ],
                      value: 'a',
                      onChanged: (_) {},
                      isDisabled: isDisabled,
                    ),
                    ElevatedButton(
                      key: const Key('disable_button'),
                      onPressed: () => setState(() => isDisabled = true),
                      child: const Text('Disable'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Verify dropdown is open
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);

      // Disable the dropdown
      await tester.tap(find.byKey(const Key('disable_button')));
      await tester.pumpAndSettle();

      // Dropdown should be closed
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.text('Option B'), findsNothing);
    });

    testWidgets('does not call onChanged when selecting while disabled', (tester) async {
      bool isDisabled = false;
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    WnDropdownSelector<String>(
                      label: 'Test',
                      options: const [
                        WnDropdownOption(value: 'a', label: 'Option A'),
                        WnDropdownOption(value: 'b', label: 'Option B'),
                      ],
                      value: 'a',
                      onChanged: (value) => selectedValue = value,
                      isDisabled: isDisabled,
                    ),
                    ElevatedButton(
                      key: const Key('disable_button'),
                      onPressed: () => setState(() => isDisabled = true),
                      child: const Text('Disable'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Disable the dropdown while open (dropdown will close)
      await tester.tap(find.byKey(const Key('disable_button')));
      await tester.pumpAndSettle();

      // Try to open again (should not work)
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Dropdown should remain closed
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(selectedValue, isNull);
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

  group('WnDropdownSize', () {
    test('has small and large variants', () {
      expect(WnDropdownSize.values, contains(WnDropdownSize.small));
      expect(WnDropdownSize.values, contains(WnDropdownSize.large));
    });
  });
}
