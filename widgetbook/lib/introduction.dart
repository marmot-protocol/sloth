import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'White Noise Design System',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Browse components, foundations, and design tokens used in the White Noise messaging app.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Design Resources',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ResourceCard(
                    title: 'Foundations',
                    description:
                        'Colors, typography, icons, and other design basics',
                    url:
                        'https://www.figma.com/design/CUEbUyUPJhdH8VRrL7JzWl/00.-Foundations',
                    icon: Icons.palette_outlined,
                  ),
                  _ResourceCard(
                    title: 'Application Components',
                    description: 'Reusable application components',
                    url:
                        'https://www.figma.com/design/J9pCZpUhcm0MRs7dFX7LTN/01.-Application-Components',
                    icon: Icons.widgets_outlined,
                  ),
                  _ResourceCard(
                    title: 'Application Design',
                    description: 'Full application screens and user flows',
                    url:
                        'https://www.figma.com/design/Y12t1SzBbrQ9Q4UTNBSoEs/02.-Application-Design',
                    icon: Icons.phone_android_outlined,
                  ),
                  _ResourceCard(
                    title: 'Widgetbook Docs',
                    description: 'Learn how to use and extend this catalog',
                    url: 'https://docs.widgetbook.io',
                    icon: Icons.menu_book_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Resources', type: Introduction)
Widget introduction(BuildContext context) {
  return const Introduction();
}

class _ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final String url;
  final IconData icon;

  const _ResourceCard({
    required this.title,
    required this.description,
    required this.url,
    required this.icon,
  });

  Future<void> _launchUrl() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _launchUrl,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF666666)),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Open',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
