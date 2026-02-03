import 'package:flutter/material.dart';
import 'package:whitenoise/theme.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class TypographyStory extends StatelessWidget {
  const TypographyStory({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@widgetbook.UseCase(name: 'Typography', type: TypographyStory)
Widget allTypography(BuildContext context) {
  const typography = AppTypography.instance;

  return Scaffold(
    backgroundColor: Colors.white,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Typography Scale',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'All text styles organized by size. Each size has three weight variants: Medium (w500), SemiBold (w600), and Bold (w700).',
          style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
        ),
        const SizedBox(height: 32),
        _buildSizeSection(
          'Size 96',
          fontSize: 96,
          lineHeight: 104,
          letterSpacing: -1.5,
          styles: [
            _StyleItem('medium96', typography.medium96, 'Medium'),
            _StyleItem('semiBold96', typography.semiBold96, 'SemiBold'),
            _StyleItem('bold96', typography.bold96, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 72',
          fontSize: 72,
          lineHeight: 80,
          letterSpacing: -1.2,
          styles: [
            _StyleItem('medium72', typography.medium72, 'Medium'),
            _StyleItem('semiBold72', typography.semiBold72, 'SemiBold'),
            _StyleItem('bold72', typography.bold72, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 60',
          fontSize: 60,
          lineHeight: 68,
          letterSpacing: -1.0,
          styles: [
            _StyleItem('medium60', typography.medium60, 'Medium'),
            _StyleItem('semiBold60', typography.semiBold60, 'SemiBold'),
            _StyleItem('bold60', typography.bold60, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 48',
          fontSize: 48,
          lineHeight: 56,
          letterSpacing: -0.6,
          styles: [
            _StyleItem('medium48', typography.medium48, 'Medium'),
            _StyleItem('semiBold48', typography.semiBold48, 'SemiBold'),
            _StyleItem('bold48', typography.bold48, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 36',
          fontSize: 36,
          lineHeight: 44,
          letterSpacing: -0.4,
          styles: [
            _StyleItem('medium36', typography.medium36, 'Medium'),
            _StyleItem('semiBold36', typography.semiBold36, 'SemiBold'),
            _StyleItem('bold36', typography.bold36, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 32',
          fontSize: 32,
          lineHeight: 38,
          letterSpacing: -0.3,
          styles: [
            _StyleItem('medium32', typography.medium32, 'Medium'),
            _StyleItem('semiBold32', typography.semiBold32, 'SemiBold'),
            _StyleItem('bold32', typography.bold32, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 28',
          fontSize: 28,
          lineHeight: 34,
          letterSpacing: -0.2,
          styles: [
            _StyleItem('medium28', typography.medium28, 'Medium'),
            _StyleItem('semiBold28', typography.semiBold28, 'SemiBold'),
            _StyleItem('bold28', typography.bold28, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 24',
          fontSize: 24,
          lineHeight: 30,
          letterSpacing: -0.1,
          styles: [
            _StyleItem('medium24', typography.medium24, 'Medium'),
            _StyleItem('semiBold24', typography.semiBold24, 'SemiBold'),
            _StyleItem('bold24', typography.bold24, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 20',
          fontSize: 20,
          lineHeight: 26,
          letterSpacing: 0,
          styles: [
            _StyleItem('medium20', typography.medium20, 'Medium'),
            _StyleItem('semiBold20', typography.semiBold20, 'SemiBold'),
            _StyleItem('bold20', typography.bold20, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 18',
          fontSize: 18,
          lineHeight: 24,
          letterSpacing: 0.1,
          styles: [
            _StyleItem('medium18', typography.medium18, 'Medium'),
            _StyleItem('semiBold18', typography.semiBold18, 'SemiBold'),
            _StyleItem('bold18', typography.bold18, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 16',
          fontSize: 16,
          lineHeight: 22,
          letterSpacing: 0.2,
          styles: [
            _StyleItem('medium16', typography.medium16, 'Medium'),
            _StyleItem('semiBold16', typography.semiBold16, 'SemiBold'),
            _StyleItem('bold16', typography.bold16, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 14',
          fontSize: 14,
          lineHeight: 18,
          letterSpacing: 0.4,
          styles: [
            _StyleItem('medium14', typography.medium14, 'Medium'),
            _StyleItem('semiBold14', typography.semiBold14, 'SemiBold'),
            _StyleItem('bold14', typography.bold14, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 14 Compact',
          fontSize: 14,
          lineHeight: 16,
          letterSpacing: 0.4,
          styles: [
            _StyleItem('medium14Compact', typography.medium14Compact, 'Medium'),
            _StyleItem(
              'semiBold14Compact',
              typography.semiBold14Compact,
              'SemiBold',
            ),
            _StyleItem('bold14Compact', typography.bold14Compact, 'Bold'),
          ],
          description: 'Tighter line height for compact layouts',
        ),
        _buildSizeSection(
          'Size 12',
          fontSize: 12,
          lineHeight: 16,
          letterSpacing: 0.6,
          styles: [
            _StyleItem('medium12', typography.medium12, 'Medium'),
            _StyleItem('semiBold12', typography.semiBold12, 'SemiBold'),
            _StyleItem('bold12', typography.bold12, 'Bold'),
          ],
        ),
        _buildSizeSection(
          'Size 10',
          fontSize: 10,
          lineHeight: 14,
          letterSpacing: 0.8,
          styles: [
            _StyleItem('medium10', typography.medium10, 'Medium'),
            _StyleItem('semiBold10', typography.semiBold10, 'SemiBold'),
            _StyleItem('bold10', typography.bold10, 'Bold'),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSizeSection(
  String title, {
  required double fontSize,
  required double lineHeight,
  required double letterSpacing,
  required List<_StyleItem> styles,
  String? description,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Size: ${fontSize.toInt()}px  |  Line: ${lineHeight.toInt()}px  |  Letter: ${letterSpacing}px',
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color(0xFF757575),
                ),
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
        const SizedBox(height: 12),
        ...styles.map((item) => _TypographySample(item: item)),
      ],
    ),
  );
}

class _StyleItem {
  final String name;
  final TextStyle style;
  final String weight;

  const _StyleItem(this.name, this.style, this.weight);
}

class _TypographySample extends StatelessWidget {
  final _StyleItem item;

  const _TypographySample({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.weight,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'The quick brown fox jumps over the lazy dog',
              style: item.style,
            ),
          ),
        ],
      ),
    );
  }
}
