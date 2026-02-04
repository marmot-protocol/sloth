import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_timestamp.dart';
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
            child: _InteractiveTimestamp(context: context),
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

class _InteractiveTimestamp extends StatefulWidget {
  const _InteractiveTimestamp({required this.context});

  final BuildContext context;

  @override
  State<_InteractiveTimestamp> createState() => _InteractiveTimestampState();
}

class _InteractiveTimestampState extends State<_InteractiveTimestamp> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now().subtract(const Duration(hours: 2));
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final date =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              WnTimestamp(timestamp: _selectedDateTime),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Selected: ${_formatDateTime(_selectedDateTime)}',
          style: TextStyle(
            fontSize: 12,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('Pick Date'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time, size: 16),
              label: const Text('Pick Time'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickButton(
              label: 'Now',
              onPressed: () =>
                  setState(() => _selectedDateTime = DateTime.now()),
            ),
            _QuickButton(
              label: '30 min ago',
              onPressed: () => setState(
                () => _selectedDateTime = DateTime.now().subtract(
                  const Duration(minutes: 30),
                ),
              ),
            ),
            _QuickButton(
              label: '5 hours ago',
              onPressed: () => setState(
                () => _selectedDateTime = DateTime.now().subtract(
                  const Duration(hours: 5),
                ),
              ),
            ),
            _QuickButton(
              label: 'Yesterday',
              onPressed: () => setState(
                () => _selectedDateTime = DateTime.now().subtract(
                  const Duration(days: 1, hours: 14),
                ),
              ),
            ),
            _QuickButton(
              label: '3 days ago',
              onPressed: () => setState(
                () => _selectedDateTime = DateTime.now().subtract(
                  const Duration(days: 3),
                ),
              ),
            ),
            _QuickButton(
              label: '2 weeks ago',
              onPressed: () => setState(
                () => _selectedDateTime = DateTime.now().subtract(
                  const Duration(days: 14),
                ),
              ),
            ),
            _QuickButton(
              label: '2 years ago',
              onPressed: () => setState(
                () => _selectedDateTime = DateTime.now().subtract(
                  const Duration(days: 730),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}
