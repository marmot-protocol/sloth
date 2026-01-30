import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_callout.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class WnCalloutStory extends StatelessWidget {
  const WnCalloutStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Callout', type: WnCalloutStory)
Widget wnCalloutShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundPrimary,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSection(
          'Callout Types',
          'Callouts come in 5 types to communicate different levels of importance.',
          [
            _CalloutExample(
              label: 'Neutral',
              child: _StaticCallout(
                title: 'Neutral callout',
                type: CalloutType.neutral,
              ),
            ),
            _CalloutExample(
              label: 'Info',
              child: _StaticCallout(
                title: 'Info callout',
                type: CalloutType.info,
              ),
            ),
            _CalloutExample(
              label: 'Warning',
              child: _StaticCallout(
                title: 'Warning callout',
                type: CalloutType.warning,
              ),
            ),
            _CalloutExample(
              label: 'Success',
              child: _StaticCallout(
                title: 'Success callout',
                type: CalloutType.success,
              ),
            ),
            _CalloutExample(
              label: 'Error',
              child: _StaticCallout(
                title: 'Error callout',
                type: CalloutType.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          'Content Variations',
          'Callouts can display a title only or include an additional description.',
          [
            _CalloutExample(
              label: 'Title Only',
              child: _StaticCallout(
                title: 'This is a title-only callout',
                type: CalloutType.info,
              ),
            ),
            _CalloutExample(
              label: 'Title + Description',
              child: _StaticCallout(
                title: 'Callout with description',
                description:
                    'This is additional context that helps explain the callout message in more detail.',
                type: CalloutType.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          'Dismissible',
          'Callouts can include a dismiss button to allow users to close them.',
          [
            _CalloutExample(
              label: 'Without Dismiss',
              child: _StaticCallout(
                title: 'Non-dismissible callout',
                type: CalloutType.neutral,
                dismissible: false,
              ),
            ),
            _CalloutExample(
              label: 'With Dismiss',
              child: _StaticCallout(
                title: 'Dismissible callout',
                type: CalloutType.neutral,
                dismissible: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection(
          'Complete Examples',
          'Combinations of different callout configurations.',
          [
            _CalloutExample(
              label: 'Error with Description',
              child: _StaticCallout(
                title: 'Action failed',
                description:
                    'Unable to complete the requested operation. Please try again later.',
                type: CalloutType.error,
              ),
            ),
            _CalloutExample(
              label: 'Error + Dismiss',
              child: _StaticCallout(
                title: 'Connection lost',
                description: 'Your internet connection appears to be offline.',
                type: CalloutType.error,
                dismissible: true,
              ),
            ),
            _CalloutExample(
              label: 'Success + Description',
              child: _StaticCallout(
                title: 'Changes saved',
                description: 'Your profile has been updated successfully.',
                type: CalloutType.success,
              ),
            ),
            _CalloutExample(
              label: 'Warning + Dismiss',
              child: _StaticCallout(
                title: 'Session expiring',
                description:
                    'Your session will expire in 5 minutes. Save your work.',
                type: CalloutType.warning,
                dismissible: true,
              ),
            ),
            _CalloutExample(
              label: 'Info + All Features',
              child: _StaticCallout(
                title: 'New feature available',
                description: 'Check out the new dark mode option in settings.',
                type: CalloutType.info,
                dismissible: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const Divider(),
        const SizedBox(height: 24),
        const Text(
          'Interactive Playground',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the knobs panel to customize this callout.',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 16),
        _InteractiveCallout(context: context),
      ],
    ),
  );
}

Widget _buildSection(String title, String description, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 24, runSpacing: 24, children: children),
    ],
  );
}

class _CalloutExample extends StatelessWidget {
  const _CalloutExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StaticCallout extends StatelessWidget {
  const _StaticCallout({
    required this.title,
    this.description,
    required this.type,
    this.dismissible = false,
  });

  final String title;
  final String? description;
  final CalloutType type;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    return WnCallout(
      title: title,
      description: description,
      type: type,
      onDismiss: dismissible ? () {} : null,
    );
  }
}

class _InteractiveCallout extends StatelessWidget {
  const _InteractiveCallout({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return WnCallout(
      title: this.context.knobs.string(
        label: 'Title',
        initialValue: 'Callout Title',
      ),
      description: this.context.knobs.stringOrNull(
        label: 'Description',
        initialValue: 'This is a description for the callout.',
      ),
      type: this.context.knobs.object.dropdown<CalloutType>(
        label: 'Type',
        options: CalloutType.values,
        initialOption: CalloutType.neutral,
        labelBuilder: (value) => value.name,
      ),
      onDismiss:
          this.context.knobs.boolean(label: 'Dismissible', initialValue: false)
          ? () {}
          : null,
    );
  }
}

extension on CalloutType {
  String get name => toString().split('.').last;
}
