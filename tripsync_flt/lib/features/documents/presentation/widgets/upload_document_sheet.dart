import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors.dart';
import '../models/document_item.dart';

class UploadDocumentSheet extends StatefulWidget {
  final void Function(PlatformFile file, DocumentCategory category) onUploaded;

  const UploadDocumentSheet({
    super.key,
    required this.onUploaded,
  });

  @override
  State<UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<UploadDocumentSheet> {
  DocumentCategory _selectedType = DocumentCategory.flight;
  PlatformFile? _selectedFile;

  static const int _maxBytes = 10 * 1024 * 1024;
  static const List<String> _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'webp',
    'doc',
    'docx',
    'txt',
  ];

  String _typeIconAsset(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.flight:
        return 'assets/icons/vemaybay.png';
      case DocumentCategory.hotel:
        return 'assets/icons/document.png';
      case DocumentCategory.cccd:
        return 'assets/icons/document.png';
      case DocumentCategory.bus:
        return 'assets/icons/xekhach.png';
      case DocumentCategory.all:
        return 'assets/icons/document.png';
    }
  }

  DocumentCategory _guessCategoryFromFilename(String filename) {
    final name = filename.toLowerCase();

    bool hasAny(List<String> keywords) => keywords.any(name.contains);

    if (hasAny(['cccd', 'cmnd', 'passport', 'visa', 'id', 'identity', 'giay to'])) {
      return DocumentCategory.cccd;
    }
    if (hasAny(['hotel', 'booking', 'reservation', 'voucher', 'khach san'])) {
      return DocumentCategory.hotel;
    }
    if (hasAny(['flight', 'boarding', 'air', 'vietjet', 'bamboo', 'vna', 'airlines', 've may bay'])) {
      return DocumentCategory.flight;
    }
    if (hasAny(['bus', 'xe', 'coach', 'train', 'tau', 'xe khach'])) {
      return DocumentCategory.bus;
    }

    return _selectedType;
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * (2 / 3);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: sheetHeight,
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primary.withValues(alpha: 0.14),
                Colors.white,
                Colors.white,
              ],
              stops: const [0.0, 0.35, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 18,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tải lên tài liệu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropArea(),
                  const SizedBox(height: 18),
                  const Text(
                    'Loại tài liệu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeChip(
                          iconAsset: _typeIconAsset(DocumentCategory.flight),
                          label: 'Vé máy bay',
                          value: DocumentCategory.flight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeChip(
                          iconAsset: _typeIconAsset(DocumentCategory.hotel),
                          label: 'Khách Sạn',
                          value: DocumentCategory.hotel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeChip(
                          iconAsset: _typeIconAsset(DocumentCategory.bus),
                          label: 'Vé xe',
                          value: DocumentCategory.bus,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeChip(
                          iconAsset: _typeIconAsset(DocumentCategory.cccd),
                          label: 'Giấy tờ tùy thân',
                          value: DocumentCategory.cccd,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _onUploadPressed,
                      child: const Text(
                        'Tải Lên',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/icons/tailieu.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chọn file từ thiết bị',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.buttonBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Image(
                        image: AssetImage('assets/icons/document.png'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Chọn file',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 10),
              Text(
                'Đã chọn: ${_selectedFile!.name}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Hỗ trợ: JPG,PNG,PDF,WEBP,DOC,DOCX,TXT (tối đa 10MB)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) {
      return;
    }

    final ext = (file.extension ?? '').toLowerCase();
    if (ext.isEmpty || !_allowedExtensions.contains(ext)) {
      _showSnack('File không đúng định dạng.');
      return;
    }
    if (file.size > _maxBytes) {
      _showSnack('File vượt quá 10MB.');
      return;
    }

    setState(() {
      _selectedFile = file;
      _selectedType = _guessCategoryFromFilename(file.name);
    });
  }

  void _onUploadPressed() {
    if (_selectedFile == null) {
      _showSnack('Vui lòng chọn file để tải lên.');
      return;
    }

    widget.onUploaded(_selectedFile!, _selectedType);
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTypeChip({
    required String iconAsset,
    required String label,
    required DocumentCategory value,
  }) {
    final isSelected = _selectedType == value;
    final backgroundColor = isSelected
      ? AppColors.blue.withValues(alpha: 0.25)
        : AppColors.buttonBackground;
    final foregroundColor = isSelected ? AppColors.blue : AppColors.textPrimary;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
