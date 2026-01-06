import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors.dart';
import '../models/document_item.dart';

class DocumentCategoryFilters extends StatelessWidget {
  final DocumentCategory selectedCategory;
  final ValueChanged<DocumentCategory> onChanged;
  final int Function(DocumentCategory) countForCategory;
  final String Function(DocumentCategory) iconAssetForCategory;

  const DocumentCategoryFilters({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    required this.countForCategory,
    required this.iconAssetForCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 123,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _CategoryCard(
              title: 'Tất cả',
              subtitle: '${countForCategory(DocumentCategory.all)} tài liệu',
              iconAsset: iconAssetForCategory(DocumentCategory.all),
              isSelected: selectedCategory == DocumentCategory.all,
              onTap: () => onChanged(DocumentCategory.all),
            ),
            const SizedBox(width: 16),
            _CategoryCard(
              title: 'Vé máy bay',
              subtitle: '${countForCategory(DocumentCategory.flight)} tài liệu',
              iconAsset: iconAssetForCategory(DocumentCategory.flight),
              isSelected: selectedCategory == DocumentCategory.flight,
              onTap: () => onChanged(DocumentCategory.flight),
            ),
            const SizedBox(width: 16),
            _CategoryCard(
              title: 'Khách Sạn',
              subtitle: '${countForCategory(DocumentCategory.hotel)} tài liệu',
              iconAsset: iconAssetForCategory(DocumentCategory.hotel),
              isSelected: selectedCategory == DocumentCategory.hotel,
              onTap: () => onChanged(DocumentCategory.hotel),
            ),
            const SizedBox(width: 16),
            _CategoryCard(
              title: 'Giấy tờ',
              subtitle: '${countForCategory(DocumentCategory.cccd)} tài liệu',
              iconAsset: iconAssetForCategory(DocumentCategory.cccd),
              isSelected: selectedCategory == DocumentCategory.cccd,
              onTap: () => onChanged(DocumentCategory.cccd),
            ),
            const SizedBox(width: 16),
            _CategoryCard(
              title: 'Vé xe',
              subtitle: '${countForCategory(DocumentCategory.bus)} tài liệu',
              iconAsset: iconAssetForCategory(DocumentCategory.bus),
              isSelected: selectedCategory == DocumentCategory.bus,
              onTap: () => onChanged(DocumentCategory.bus),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isSelected ? AppColors.primary : Colors.white;
    final textColor = isSelected ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isSelected ? Colors.white70 : AppColors.textSecondary;
    final iconBackgroundColor = isSelected
        ? Colors.white
        : AppColors.iconBackground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 123,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(iconAsset, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
