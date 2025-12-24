import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../models/document_item.dart';
import '../widgets/document_category_filters.dart';
import '../widgets/document_header.dart';
import '../widgets/document_list_item.dart';
import '../widgets/upload_document_sheet.dart';

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  DocumentCategory _selectedCategory = DocumentCategory.all;

  late final List<DocumentItem> _documents = [
    const DocumentItem(
      title: 'Vé máy bay - Hà Nội→Đà Lạt',
      author: 'Quang Sáng',
      date: '15/12/2025',
      iconAsset: 'assets/icons/vemaybay.png',
      category: DocumentCategory.flight,
    ),
    const DocumentItem(
      title: 'Xác nhận đặt cọc khách sạn Wonder - Hà Nội→Đà Lạt',
      author: 'Quang Sáng',
      date: '15/12/2025',
      iconAsset: 'assets/icons/building.png',
      category: DocumentCategory.hotel,
    ),
    const DocumentItem(
      title: 'Giấy tờ - Hà Nội→Đà Lạt',
      author: 'Quang Sáng',
      date: '15/12/2025',
      iconAsset: 'assets/icons/tailieu.png',
      category: DocumentCategory.cccd,
    ),
    const DocumentItem(
      title: 'Vé xe khách - Hà Nội→Đà Lạt',
      author: 'Quang Sáng',
      date: '15/12/2025',
      iconAsset: 'assets/icons/xekhach.png',
      category: DocumentCategory.bus,
    ),
    const DocumentItem(
      title: 'Vé máy bay - Hà Nội→Đà Lạt',
      author: 'Quang Sáng',
      date: '15/12/2025',
      iconAsset: 'assets/icons/vemaybay.png',
      category: DocumentCategory.flight,
    ),
  ];

  String _categoryIconAsset(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.all:
        return 'assets/icons/document all.png';
      case DocumentCategory.flight:
        return 'assets/icons/vemaybay.png';
      case DocumentCategory.hotel:
        return 'assets/icons/building.png';
      case DocumentCategory.cccd:
        return 'assets/icons/tailieu.png';
      case DocumentCategory.bus:
        return 'assets/icons/xekhach.png';
    }
  }

  String _categoryLabel(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.all:
        return 'Tất cả';
      case DocumentCategory.flight:
        return 'Vé máy bay';
      case DocumentCategory.hotel:
        return 'Khách Sạn';
      case DocumentCategory.cccd:
        return 'CCCD';
      case DocumentCategory.bus:
        return 'Vé Xe Khách';
    }
  }

  void _openUploadDocumentSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UploadDocumentSheet(
        onUploaded: (file, category) {
          _addDocumentFromUpload(file: file, category: category);
        },
      ),
    );
  }

  void _addDocumentFromUpload({
    required PlatformFile file,
    required DocumentCategory category,
  }) {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    setState(() {
      _documents.insert(
        0,
        DocumentItem(
          title: file.name,
          author: 'Quang Sáng',
          date: date,
          iconAsset: _categoryIconAsset(category),
          category: category,
          bytes: file.bytes,
          extension: (file.extension ?? '').toLowerCase(),
        ),
      );

      if (_selectedCategory != DocumentCategory.all &&
          _selectedCategory != category) {
        _selectedCategory = DocumentCategory.all;
      }
    });
  }

  bool _isImageExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return true;
      default:
        return false;
    }
  }

  void _openDocumentPreview(DocumentItem doc) {
    final bytes = doc.bytes;
    final ext = (doc.extension ?? '').toLowerCase();

    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có file để xem.')),
      );
      return;
    }

    if (!_isImageExtension(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiện chỉ hỗ trợ xem ảnh (JPG/PNG/WEBP).')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        final maxWidth = MediaQuery.sizeOf(context).width - 32;
        final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Không thể hiển thị ảnh',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<DocumentItem> get _filteredDocuments {
    if (_selectedCategory == DocumentCategory.all) {
      return _documents;
    }
    return _documents
        .where((doc) => doc.category == _selectedCategory)
        .toList(growable: false);
  }

  int _countForCategory(DocumentCategory category) {
    if (category == DocumentCategory.all) {
      return _documents.length;
    }
    return _documents.where((d) => d.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = _filteredDocuments;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                DocumentHeader(
                  onBack: () => Navigator.pop(context),
                  title: 'Đà Lạt-Thành Phố Mộng Mơ',
                  location: 'Đà Lạt, Lâm Đồng',
                ),

                // Category Filters
                DocumentCategoryFilters(
                  selectedCategory: _selectedCategory,
                  onChanged: (c) => setState(() => _selectedCategory = c),
                  countForCategory: _countForCategory,
                  iconAssetForCategory: _categoryIconAsset,
                ),

                // Documents List Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          'Tài liệu (${filteredDocuments.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _buildDocumentsList(filteredDocuments)),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation
                const TripBottomNavigation(currentIndex: 1),
              ],
            ),

            // FAB
            Positioned(
              right: 16,
              bottom: 100,
              child: _buildFloatingActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(List<DocumentItem> documents) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: DocumentListItem(
            doc: doc,
            categoryTitle: _categoryLabel(doc.category),
            onMorePressed: () => _openDocumentPreview(doc),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        _openUploadDocumentSheet();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
