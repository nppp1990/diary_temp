import 'package:dribbble/diary/bean/template.dart';
import 'package:dribbble/diary/common/test_colors.dart';
import 'package:dribbble/diary/common/test_configuration.dart';
import 'package:dribbble/diary/widgets/card.dart';
import 'package:flutter/material.dart';

class TemplateListPage extends StatelessWidget {
  static final _testData = [
    Template(title: 'Template white', subtitle: 'Subtitle white', content: 'Content 1', color: Colors.white),
    Template(title: 'Template 1', subtitle: 'Subtitle 1', content: 'Content 1', color: const Color(0xFFF8F8F8)),
    Template(title: 'Template 2', subtitle: 'Subtitle 2', content: 'Content 2', color: const Color(0xFFfcede1)),
    Template(title: 'Template 3', subtitle: 'Subtitle 3', content: 'Content 3', color: const Color(0xFFe4f7f6)),
    Template(title: 'Template 4', subtitle: 'Subtitle 4', content: 'Content 4', color: const Color(0xFFfdeefb)),
    Template(title: 'Template 5', subtitle: 'Subtitle 5', content: 'Content 5', color: const Color(0xFFD8E6E8)),
    Template(title: 'Template 6', subtitle: 'Subtitle 6', content: 'Content 6', color: const Color(0xFFCACFCA)),
    Template(title: 'Template 7', subtitle: 'Subtitle 7', content: 'Content 7', color: const Color(0xFFEEFEE4)),
    Template(title: 'Template 8', subtitle: 'Subtitle 8', content: 'Content 7', color: const Color(0xFF395C78)),
    Template(
        title: 'Template 9',
        subtitle: 'Subtitle 9llllllllxxxxxxxxxhhhhhhhhhhhhhhhhhhhhhhhhhhhhh你好好哈哈哈哈',
        content: 'Content 7',
        color: const Color(0xFF4CA477)),
  ];

  const TemplateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template List'),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _testData.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final template = _testData[index];
          return _TemplateListItem(title: template.title, subtitle: template.subtitle, backgroundColor: template.color);
        },
      ),
    );
  }
}

class _TemplateListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;

  const _TemplateListItem({required this.title, required this.subtitle, required this.backgroundColor});

  bool _isDarkColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TestConfiguration.dialogPadding, vertical: 8),
      child: OffsetCard(
        cardHeight: TestConfiguration.templateItemHeight,
        offset: const Offset(0, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: TestConfiguration.templateItemHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.white,
                    foregroundColor: TestColors.black1,
                    side: const BorderSide(color: TestColors.black1, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  ),
                  child: const Text(
                    'Use',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
