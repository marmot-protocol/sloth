import 'package:flutter/material.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_copy_card.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../foundations/design_width_container.dart';

const _samplePubkey =
    'npub 1zuu ajd7 u3sx 8xu9 2yav 9jwx pr83 9cs0 kc3q 6t56 vd5u 9q03 3xmh sk6c 2uc';
const _sampleCopiablePubkey =
    'npub1zuuajd7u3sx8xu92yav9jwxpr839cs0kc3q6t56vd5u9q033xmhsk6c2uc';

class WnCopyCardStory extends StatelessWidget {
  const WnCopyCardStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Copy Card', type: WnCopyCardStory)
Widget wnCopyCardShowcase(BuildContext context) {
  final colors = context.colors;

  final textToDisplay = context.knobs.string(
    label: 'Text to display',
    initialValue: _samplePubkey,
  );
  final textToCopy = context.knobs.string(
    label: 'Text to copy',
    initialValue: _sampleCopiablePubkey,
  );

  return Scaffold(
    backgroundColor: colors.backgroundPrimary,
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Copy Card',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Playground',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Interactive - hover and click to see state changes',
            style: TextStyle(
              fontSize: 14,
              color: colors.backgroundContentSecondary,
            ),
          ),
          const SizedBox(height: 16),
          DesignWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: WnCopyCard(
                textToDisplay: textToDisplay,
                textToCopy: textToCopy,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Divider(color: colors.borderTertiary),
          const SizedBox(height: 32),
          Text(
            'Variants',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.backgroundContentPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Different text lengths showing truncation behavior',
            style: TextStyle(
              fontSize: 14,
              color: colors.backgroundContentSecondary,
            ),
          ),
          const SizedBox(height: 24),
          DesignWidthContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildVariantsColumn(colors),
            ),
          ),
        ],
      ),
    ),
  );
}

const _shortText = 'I am a short text that fits in oneline';
const _mediumText =
    'I am a medium text that can fit in two lines and does not need truncation';

const _longText =
    'I am a very long text that needs to be truncated because I am too long to fit in the container and I need to be truncated';
Widget _buildVariantsColumn(SemanticColors colors) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: [
      _buildVariantItem(colors, 'Short text', _shortText),
      _buildVariantItem(colors, 'Medium text', _mediumText),
      _buildVariantItem(colors, 'Long text (truncated)', _longText),
    ],
  );
}

Widget _buildVariantItem(SemanticColors colors, String label, String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.backgroundContentSecondary,
        ),
      ),
      const SizedBox(height: 8),
      WnCopyCard(textToDisplay: text, textToCopy: text),
    ],
  );
}
