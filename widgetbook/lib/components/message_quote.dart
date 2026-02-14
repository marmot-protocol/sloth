import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_message_quote.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _sampleImageUrl = 'https://www.whitenoise.chat/images/mask-man.webp';

class WnMessageQuoteStory extends StatelessWidget {
  const WnMessageQuoteStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Message Quote', type: WnMessageQuoteStory)
Widget wnMessageQuoteShowcase(BuildContext context) {
  return Scaffold(
    backgroundColor: context.colors.backgroundSecondary,
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
          'Use the knobs panel to customize this message quote.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const _InteractiveMessageQuote(),
          ),
        ),
        const SizedBox(height: 32),
        Divider(color: context.colors.borderTertiary),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'All Variants',
          'Message Quote shows who was quoted and a snippet of the quoted text.',
          [
            const _QuoteExample(
              label: 'Short message',
              child: WnMessageQuote(
                author: 'Wes Borland',
                text: 'There may be something good in silence.',
              ),
            ),
            const _QuoteExample(
              label: 'Long message (2 lines max)',
              child: WnMessageQuote(
                author: 'Wes Borland',
                text:
                    "There may be something good in silence. It's a brand new thing. "
                    'You can hear the funniest little discussions, if you keep turning '
                    'the volume down. Shut yourself up, and listen out loud.',
              ),
            ),
            const _QuoteExample(
              label: 'Text only',
              child: WnMessageQuote(author: 'Bob', text: 'Just some text'),
            ),
            _QuoteExample(
              label: 'Media only',
              child: WnMessageQuote(
                author: 'Bob',
                text: '',
                image: const NetworkImage(_sampleImageUrl),
              ),
            ),
            _QuoteExample(
              label: 'Text and media',
              child: WnMessageQuote(
                author: 'Bob',
                text: 'Check out this photo!',
                image: const NetworkImage(_sampleImageUrl),
              ),
            ),
            _QuoteExample(
              label: 'Text and cancel button',
              child: WnMessageQuote(
                author: 'Alice',
                text: 'Replying to this...',
                onCancel: () {},
              ),
            ),
            _QuoteExample(
              label: 'Text, media and cancel button',
              child: WnMessageQuote(
                author: 'Alice',
                text: 'Replying to this...',
                image: const NetworkImage(_sampleImageUrl),
                onCancel: () {},
              ),
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

class _QuoteExample extends StatelessWidget {
  const _QuoteExample({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.colors.backgroundContentSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: child,
        ),
      ],
    );
  }
}

class _InteractiveMessageQuote extends StatelessWidget {
  const _InteractiveMessageQuote();

  @override
  Widget build(BuildContext context) {
    final author = context.knobs.string(
      label: 'Author Name',
      initialValue: 'Wes Borland',
    );

    final text = context.knobs.string(
      label: 'Text',
      initialValue:
          "There may be something good in silence. It's a brand new thing.",
    );

    final showImage = context.knobs.boolean(
      label: 'Show Image',
      initialValue: false,
    );

    final showCancelButton = context.knobs.boolean(
      label: 'Show Cancel Button',
      initialValue: false,
    );

    return WnMessageQuote(
      author: author,
      text: text,
      image: showImage ? const NetworkImage(_sampleImageUrl) : null,
      onCancel: showCancelButton ? () {} : null,
      onTap: () {},
    );
  }
}
