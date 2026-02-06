import 'package:flutter/material.dart' show FontWeight, Key, Text, TextOverflow;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/widgets/wn_timestamp.dart';
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnTimestamp tests', () {
    group('Now (less than 60 seconds)', () {
      testWidgets('displays "Now" for timestamp 0 seconds ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Now'), findsOneWidget);
      });

      testWidgets('displays "Now" for timestamp 30 seconds ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Now'), findsOneWidget);
      });

      testWidgets('displays "Now" for timestamp 59 seconds ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30, 59);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Now'), findsOneWidget);
      });
    });

    group('Minutes (1-59 minutes)', () {
      testWidgets('displays "1m" for timestamp 1 minute ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 31);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('1m'), findsOneWidget);
      });

      testWidgets('displays "32m" for timestamp 32 minutes ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 15, 2);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('32m'), findsOneWidget);
      });

      testWidgets('displays "59m" for timestamp 59 minutes ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 15, 29);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('59m'), findsOneWidget);
      });
    });

    group('Hours (1-11 hours)', () {
      testWidgets('displays "1h" for timestamp 1 hour ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 15, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('1h'), findsOneWidget);
      });

      testWidgets('displays "4h" for timestamp 4 hours ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 18, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('4h'), findsOneWidget);
      });

      testWidgets('displays "11h" for timestamp 11 hours ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 16, 1, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('11h'), findsOneWidget);
      });
    });

    group('Time (same day, 12+ hours)', () {
      testWidgets('displays time format for timestamp 12 hours ago same day', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 15, 22, 30);
        final timestamp = DateTime(2024, 6, 15, 10, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('10:30'), findsOneWidget);
      });

      testWidgets('displays time format with leading zeros', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 23);
        final timestamp = DateTime(2024, 6, 15, 10, 5);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('10:05'), findsOneWidget);
      });

      testWidgets('displays "06:30" format for 14 hours difference same day', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 15, 20, 30);
        final timestamp = DateTime(2024, 6, 15, 6, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('06:30'), findsOneWidget);
      });
    });

    group('Yesterday', () {
      testWidgets('displays "Yesterday" for timestamp from yesterday over 12h ago', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 16, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 10);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Yesterday'), findsOneWidget);
      });

      testWidgets('displays hours for timestamp from yesterday within 12h', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 16, 8);
        final timestamp = DateTime(2024, 6, 15, 23);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('9h'), findsOneWidget);
      });

      testWidgets('displays "Yesterday" for late night to evening next day', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 16, 22);
        final timestamp = DateTime(2024, 6, 15, 8);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Yesterday'), findsOneWidget);
      });
    });

    group('Weekday (2-6 days ago)', () {
      testWidgets('displays weekday name for 2 days ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 17, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Saturday'), findsOneWidget);
      });

      testWidgets('displays "Monday" for timestamp on Monday', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 20, 14, 30);
        final timestamp = DateTime(2024, 6, 17, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Monday'), findsOneWidget);
      });

      testWidgets('displays "Tuesday" for timestamp on Tuesday', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 21, 14, 30);
        final timestamp = DateTime(2024, 6, 18, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Tuesday'), findsOneWidget);
      });

      testWidgets('displays "Wednesday" for timestamp on Wednesday', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 22, 14, 30);
        final timestamp = DateTime(2024, 6, 19, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Wednesday'), findsOneWidget);
      });

      testWidgets('displays "Thursday" for timestamp on Thursday', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 23, 14, 30);
        final timestamp = DateTime(2024, 6, 20, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Thursday'), findsOneWidget);
      });

      testWidgets('displays "Friday" for timestamp on Friday', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 24, 14, 30);
        final timestamp = DateTime(2024, 6, 21, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Friday'), findsOneWidget);
      });

      testWidgets('displays "Sunday" for timestamp on Sunday', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 19, 14, 30);
        final timestamp = DateTime(2024, 6, 16, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Sunday'), findsOneWidget);
      });

      testWidgets('displays weekday for 6 days ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 21, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Saturday'), findsOneWidget);
      });
    });

    group('Date (older than 6 days, within 1 year)', () {
      testWidgets('displays "Jun 10" format for date within current year', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 20, 14, 30);
        final timestamp = DateTime(2024, 6, 10, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Jun 10'), findsOneWidget);
      });

      testWidgets('displays month and day for 2 weeks ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 29, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Jun 15'), findsOneWidget);
      });

      testWidgets('displays "Jan 1" for new year date', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2024, 1, 1, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Jan 1'), findsOneWidget);
      });

      testWidgets('displays all month names correctly', (WidgetTester tester) async {
        final now = DateTime(2024, 12, 31, 14, 30);

        final months = [
          (DateTime(2024, 1, 15), 'Jan 15'),
          (DateTime(2024, 2, 15), 'Feb 15'),
          (DateTime(2024, 3, 15), 'Mar 15'),
          (DateTime(2024, 4, 15), 'Apr 15'),
          (DateTime(2024, 5, 15), 'May 15'),
          (DateTime(2024, 6, 15), 'Jun 15'),
          (DateTime(2024, 7, 15), 'Jul 15'),
          (DateTime(2024, 8, 15), 'Aug 15'),
          (DateTime(2024, 9, 15), 'Sep 15'),
          (DateTime(2024, 10, 15), 'Oct 15'),
          (DateTime(2024, 11, 15), 'Nov 15'),
          (DateTime(2024, 12, 15), 'Dec 15'),
        ];

        for (final (timestamp, expected) in months) {
          await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);
          expect(find.text(expected), findsOneWidget, reason: 'Expected $expected');
        }
      });
    });

    group('Date & Year (older than 1 year)', () {
      testWidgets('displays "Jan 9, 2009" format for old dates', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2009, 1, 9, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Jan 9, 2009'), findsOneWidget);
      });

      testWidgets('handles leap year Feb 29 correctly when current date is non-leap year', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2025, 2, 28, 14, 30);
        final timestamp = DateTime(2024, 2, 29, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Feb 29'), findsOneWidget);
      });

      testWidgets('displays month/day for exactly 365 days ago (edge case)', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2023, 6, 15, 14, 30);
        final timestamp = DateTime(2022, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Jun 15'), findsOneWidget);
      });

      testWidgets('displays year for more than 1 year ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2023, 6, 14, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Jun 14, 2023'), findsOneWidget);
      });

      testWidgets('displays year for dates more than 1 year ago', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2022, 12, 25, 10);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Dec 25, 2022'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('handles midnight timestamps', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 12);
        final timestamp = DateTime(2024, 6, 15);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('handles end of day timestamps', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 16, 12);
        final timestamp = DateTime(2024, 6, 15, 23, 59);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('Yesterday'), findsOneWidget);
      });

      testWidgets('renders as Text widget', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.byType(WnTimestamp), findsOneWidget);
      });

      testWidgets('respects key parameter', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(
          WnTimestamp(key: const Key('test_timestamp'), timestamp: timestamp, now: now),
          tester,
        );

        expect(find.byKey(const Key('test_timestamp')), findsOneWidget);
      });
    });

    group('boundary conditions', () {
      testWidgets('transitions from Now to Minutes at 60 seconds', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 31);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('1m'), findsOneWidget);
      });

      testWidgets('transitions from Minutes to Hours at 60 minutes', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 15, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('1h'), findsOneWidget);
      });

      testWidgets('transitions from Hours to Time at 12 hours same day', (
        WidgetTester tester,
      ) async {
        final now = DateTime(2024, 6, 15, 22, 30);
        final timestamp = DateTime(2024, 6, 15, 10, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        expect(find.text('10:30'), findsOneWidget);
      });
    });

    group('text styling', () {
      testWidgets('applies correct text style', (WidgetTester tester) async {
        final now = DateTime(2024, 6, 15, 14, 30);
        final timestamp = DateTime(2024, 6, 15, 14, 30);

        await mountWidget(WnTimestamp(timestamp: timestamp, now: now), tester);

        final text = tester.widget<Text>(find.text('Now'));
        expect(text.style?.fontWeight, FontWeight.w500);
        expect(text.overflow, TextOverflow.ellipsis);
        expect(text.maxLines, 1);
      });
    });
  });
}
