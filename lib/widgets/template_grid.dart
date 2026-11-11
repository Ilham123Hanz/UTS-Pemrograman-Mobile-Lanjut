import 'package:flutter/material.dart';
import '../models/design_template.dart';
import '../theme/app_colors.dart';
import '../widgets/template_card.dart';

/// Grid of template cards
class TemplateGrid extends StatelessWidget {
  final List<DesignTemplate> templates;
  final Function(DesignTemplate) onTemplateTap;

  const TemplateGrid({
    super.key,
    required this.templates,
    required this.onTemplateTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final template = templates[index];
            return TemplateCard(
              template: template,
              onTap: () => onTemplateTap(template),
            );
          },
          childCount: templates.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 18,
          mainAxisSpacing: 20,
          childAspectRatio: 0.7,
        ),
      ),
    );
  }
}