import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Horizontal scrollable category chips (ChoiceChips)
class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final Color primaryColor;
  final Color textPrimary;
  final Color cardColor;
  final Color borderColor;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.primaryColor,
    required this.textPrimary,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              selected: selected,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: primaryColor,
              backgroundColor: cardColor,
              side: BorderSide(
                color: selected ? Colors.transparent : borderColor,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              elevation: selected ? 2 : 0,
              pressElevation: 4,
              shadowColor: primaryColor.withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }
}