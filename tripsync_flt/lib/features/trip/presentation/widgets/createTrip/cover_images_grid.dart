import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../services/trip_cover_images.dart';

class CoverImagesGrid extends StatelessWidget {
  final int? selectedImageIndex;
  final String? selectedFilePath;
  final Function(int) onImageSelected;
  final VoidCallback onPickFromFile;

  const CoverImagesGrid({
    super.key,
    required this.selectedImageIndex,
    required this.selectedFilePath,
    required this.onImageSelected,
    required this.onPickFromFile,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrls = TripCoverImages.assets;
    final filePath = selectedFilePath?.trim();
    final hasFileSelected = filePath != null && filePath.isNotEmpty;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 2,
      ),
      itemCount: imageUrls.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: onPickFromFile,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasFileSelected
                      ? const Color(0xFF00C950)
                      : Colors.black,
                  width: hasFileSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hasFileSelected
                    ? (kIsWeb
                          ? Container(
                              color: const Color(0xFFF5F6F8),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            )
                          : Image.file(
                              File(filePath),
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFF5F6F8),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ))
                    : Container(
                        color: const Color(0xFFF5F6F8),
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Chọn từ tệp',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        }

        final assetIndex = index - 1;
        final isSelected = selectedImageIndex == assetIndex && !hasFileSelected;
        return GestureDetector(
          onTap: () => onImageSelected(assetIndex),
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
                imageUrls[assetIndex],
                fit: isSelected ? BoxFit.contain : BoxFit.cover,
                alignment: Alignment.center,
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
