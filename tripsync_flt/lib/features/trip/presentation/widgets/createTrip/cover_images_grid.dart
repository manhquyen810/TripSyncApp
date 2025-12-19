import 'package:flutter/material.dart';

class CoverImagesGrid extends StatelessWidget {
  final int? selectedImageIndex;
  final Function(int) onImageSelected;

  const CoverImagesGrid({
    super.key,
    required this.selectedImageIndex,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = [
      'images/trip/background_1.jpg',
      'images/trip/background_2.jpg',
      'images/trip/background_3.jpg',
      'images/trip/background_4.jpg',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 2,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final isSelected = selectedImageIndex == index;
        return GestureDetector(
          onTap: () => onImageSelected(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF00C950) : Colors.black,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF5F6F8),
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
