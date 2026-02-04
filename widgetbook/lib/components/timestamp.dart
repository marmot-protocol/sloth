import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_timestamp.dart';
import 'package:sloth_widgetbook/knobs/custom_datetime_knob.dart';
import 'package:sloth_widgetbook/utils/format_datetime_for_display.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnTimestampStory extends StatelessWidget {
  const WnTimestampStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Timestamp', type: WnTimestampStory)
Widget wnTimestampShowcase(BuildContext context) {
  final now = DateTime.now();
  final timestamp = context.knobs.customDateTime(
    label: 'Timestamp',
    initialValue: now,
  );

  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Playground',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.colors.backgroundContentPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use the knobs panel to customize the timestamp.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 375),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Last activity: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.backgroundContentPrimary,
                    ),
                  ),
                  WnTimestamp(timestamp: timestamp),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Selected: ${formatDateTimeForDisplay(timestamp)}',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Format Types',
          'Timestamps display relative time for recent activity, then switch to absolute formats as messages get older.',
          [
            _TimestampExample(
              label: 'Now',
              description: '< 60 seconds',
              timestamp: DateTime.now(),
            ),
            _TimestampExample(
              label: 'Minutes',
              description: '1-59 minutes',
              timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
            ),
            _TimestampExample(
              label: 'Hours',
              description: '1-12 hours',
              timestamp: DateTime.now().subtract(const Duration(hours: 4)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Time & Day Formats',
          'For older timestamps, the display switches to time, yesterday, or weekday.',
          [
            _TimestampExample(
              label: 'Time',
              description: 'Same day, 12+ hours',
              timestamp: DateTime.now().subtract(const Duration(hours: 14)),
              now: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                23,
                0,
              ),
            ),
            _TimestampExample(
              label: 'Yesterday',
              description: 'Previous day',
              timestamp: DateTime.now().subtract(
                const Duration(days: 1, hours: 14),
              ),
            ),
            _TimestampExample(
              label: 'Weekday',
              description: '2-6 days ago',
              timestamp: DateTime.now().subtract(const Duration(days: 3)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          context,
          'Date Formats',
          'For timestamps older than a week, dates are shown with or without the year.',
          [
            _TimestampExample(
              label: 'Date',
              description: '> 6 days, < 1 year',
              timestamp: DateTime.now().subtract(const Duration(days: 30)),
            ),
            _TimestampExample(
              label: 'Date & Year',
              description: '> 1 year',
              timestamp: DateTime(2009, 1, 9, 14, 30),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSection(
  BuildContext context,
  String title,
  String description,
  List<Widget> children,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.colors.backgroundContentPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: context.colors.backgroundContentSecondary,
        ),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 24, runSpacing: 24, children: children),
    ],
  );
}

class _TimestampExample extends StatelessWidget {
  const _TimestampExample({
    required this.label,
    required this.description,
    required this.timestamp,
    this.now,
  });

  final String label;
  final String description;
  final DateTime timestamp;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: context.colors.backgroundContentSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: WnTimestamp(timestamp: timestamp, now: now),
          ),
        ],
      ),
    );
  }
}
