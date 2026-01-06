import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/data/datasources/trip_remote_data_source.dart';
import '../../../trip/data/repositories/trip_repository_impl.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../data/datasources/documents_remote_data_source.dart';
import '../../data/repositories/documents_repository_impl.dart';
import '../../data/services/document_offline_store.dart';
import '../../domain/repositories/documents_repository.dart';
import '../models/document_item.dart';
import '../widgets/document_category_filters.dart';
import '../widgets/document_header.dart';
import '../widgets/documents_list_view.dart';
import '../widgets/upload_document_sheet.dart';

class DocumentManagementScreen extends StatefulWidget {
  final Trip trip;

  const DocumentManagementScreen({super.key, required this.trip});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  DocumentCategory _selectedCategory = DocumentCategory.all;

  late final DocumentsRepository _documentsRepository;
  late final TripRepository _tripRepository;
  late final DocumentOfflineStore _offlineStore;
  bool _isLoading = true;
  bool _hasShownLoadError = false;

  final List<DocumentItem> _documents = <DocumentItem>[];

  Trip get trip => widget.trip;

  @override
  void initState() {
    super.initState();
    final authedClient = ApiClient(
      authTokenProvider: AuthTokenStore.getAccessToken,
    );

    _documentsRepository = DocumentsRepositoryImpl(
      DocumentsRemoteDataSourceImpl(authedClient),
    );

    _tripRepository = TripRepositoryImpl(
      TripRemoteDataSourceImpl(authedClient),
    );
    _offlineStore = DocumentOfflineStore();
    _refreshDocuments();
  }

  Future<void> _refreshDocuments() async {
    final tripId = trip.id;
    if (tripId == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        showTopToast(
          context,
          message: 'Không thể tải tài liệu (thiếu trip_id)',
          type: TopToastType.error,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docsFuture = _documentsRepository.listDocumentsByTrip(
        tripId: tripId,
      );
      final membersFuture = _tripRepository.listTripMembers(tripId: tripId);

      final docs = await docsFuture;
      final userNameById = _extractUserNameById(await membersFuture);

      // Cache list for offline use (best-effort).
      try {
        await _offlineStore.saveTripDocuments(tripId: tripId, docs: docs);
      } catch (_) {}

      final mapped = <DocumentItem>[];
      for (final d in docs) {
        final category = _categoryFromApi(d.category);
        final filename = d.filename.trim().isEmpty
            ? 'Document #${d.id}'
            : d.filename;
        final extension = _extensionFromFilename(filename);

        String? localPath;
        try {
          localPath = await _offlineStore.getLocalPath(documentId: d.id);
        } catch (_) {}

        mapped.add(
          DocumentItem(
            id: d.id,
            title: filename,
            author: userNameById[d.uploaderId] ?? 'User ${d.uploaderId}',
            date: _formatDate(d.createdAt),
            iconAsset: _categoryIconAsset(category),
            category: category,
            url: d.url,
            localPath: localPath,
            extension: extension,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _documents
          ..clear()
          ..addAll(mapped);
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Try offline cache fallback.
      final cached = await _offlineStore.loadTripDocuments(tripId: tripId);
      if (cached != null && cached.isNotEmpty) {
        final mapped = cached
            .map((c) {
              final d = c.dto;
              final category = _categoryFromApi(d.category);
              final filename = d.filename.trim().isEmpty
                  ? 'Document #${d.id}'
                  : d.filename;
              final extension = _extensionFromFilename(filename);
              return DocumentItem(
                id: d.id,
                title: filename,
                author: 'User ${d.uploaderId}',
                date: _formatDate(d.createdAt),
                iconAsset: _categoryIconAsset(category),
                category: category,
                url: d.url,
                localPath: c.localPath,
                extension: extension,
              );
            })
            .toList(growable: false);

        setState(() {
          _documents
            ..clear()
            ..addAll(mapped);
        });

        if (!_hasShownLoadError) {
          _hasShownLoadError = true;
          if (!mounted) return;
          showTopToast(
            context,
            message: 'Đang hiển thị tài liệu offline',
            type: TopToastType.success,
          );
        }

        return;
      }

      if (_hasShownLoadError) return;
      _hasShownLoadError = true;

      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để xem tài liệu',
        ApiException() => err.message,
        _ => 'Không tải được danh sách tài liệu',
      };
      if (!mounted) return;
      showTopToast(context, message: msg, type: TopToastType.error);
    }
  }

  Map<int, String> _extractUserNameById(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is! List) return <int, String>{};

    int? readInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? readString(dynamic v) {
      if (v is String) {
        final s = v.trim();
        return s.isEmpty ? null : s;
      }
      return null;
    }

    final out = <int, String>{};
    for (final item in data) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final nestedUser = map['user'];
      final userMap = nestedUser is Map
          ? Map<String, dynamic>.from(nestedUser)
          : null;

      final id = readInt((userMap ?? map)['id']) ?? readInt(map['user_id']);
      if (id == null) continue;

      final name =
          readString((userMap ?? map)['name']) ??
          readString((userMap ?? map)['full_name']) ??
          readString((userMap ?? map)['email']);

      if (name != null) {
        out[id] = name;
      }
    }

    return out;
  }

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
          _uploadDocument(file: file, category: category);
        },
      ),
    );
  }

  Future<void> _uploadDocument({
    required PlatformFile file,
    required DocumentCategory category,
  }) async {
    final tripId = trip.id;
    if (tripId == null) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Không thể tải lên (thiếu trip_id)',
          type: TopToastType.error,
        );
      }
      return;
    }

    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Không đọc được file để tải lên',
          type: TopToastType.error,
        );
      }
      return;
    }

    setState(() {
      _hasShownLoadError = false;
      _isLoading = true;
    });

    try {
      await _documentsRepository.uploadDocument(
        tripId: tripId,
        category: _apiCategoryForUpload(category),
        bytes: bytes,
        filename: file.name,
      );

      if (!mounted) return;
      showTopToast(
        context,
        message: 'Tải lên thành công',
        type: TopToastType.success,
      );

      if (_selectedCategory != DocumentCategory.all &&
          _selectedCategory != category) {
        setState(() => _selectedCategory = DocumentCategory.all);
      }

      await _refreshDocuments();
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để tải tài liệu',
        ApiException() => err.message,
        _ => 'Tải lên thất bại',
      };
      showTopToast(context, message: msg, type: TopToastType.error);
    }
  }

  String _apiCategoryForUpload(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.flight:
        return 'flight';
      case DocumentCategory.hotel:
        return 'hotel';
      case DocumentCategory.cccd:
        return 'cccd';
      case DocumentCategory.bus:
        return 'bus';
      case DocumentCategory.all:
        return 'other';
    }
  }

  DocumentCategory _categoryFromApi(String? raw) {
    final c = (raw ?? '').trim().toLowerCase();
    switch (c) {
      case 'flight':
        return DocumentCategory.flight;
      case 'hotel':
        return DocumentCategory.hotel;
      case 'cccd':
      case 'id':
      case 'identity':
        return DocumentCategory.cccd;
      case 'bus':
      case 'train':
      case 'ticket':
        return DocumentCategory.bus;
      case 'other':
        return DocumentCategory.all;
      default:
        return DocumentCategory.all;
    }
  }

  String _extensionFromFilename(String filename) {
    final trimmed = filename.trim();
    final dot = trimmed.lastIndexOf('.');
    if (dot < 0 || dot == trimmed.length - 1) return '';
    return trimmed.substring(dot + 1).toLowerCase();
  }

  String _formatDate(DateTime? dt) {
    final d = dt ?? DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  bool _isKnownNonImageExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'txt':
        return true;
      default:
        return false;
    }
  }

  String _downloadErrorMessage(Object err) {
    if (err is TimeoutException) {
      return 'Server đang khởi động, thử lại sau vài giây';
    }
    if (err is UnauthorizedException) {
      return 'Vui lòng đăng nhập để tải tài liệu';
    }
    if (err is ApiException) {
      return err.message;
    }

    if (err is DioException) {
      final status = err.response?.statusCode;
      if (status == 401 || status == 403) {
        return 'Không có quyền truy cập file (vui lòng đăng nhập lại)';
      }
      switch (err.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Không có mạng hoặc kết nối yếu và chưa tải offline.';
        case DioExceptionType.badResponse:
          return 'Không tải được file (lỗi server).';
        case DioExceptionType.badCertificate:
          return 'Không tải được file (chứng chỉ không hợp lệ).';
        case DioExceptionType.cancel:
          return 'Đã hủy tải xuống.';
        case DioExceptionType.unknown:
          return 'Không tải được file (lỗi kết nối).';
      }
    }

    return 'Không tải được file.';
  }

  bool _looksLikeImageBytes(List<int> bytes) {
    if (bytes.isEmpty) return false;

    // JPEG: FF D8 FF
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // WEBP: RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return true;
    }

    return false;
  }

  bool _looksLikeNonImageUrl(String url) {
    final u = url.trim().toLowerCase();
    if (u.isEmpty) return false;

    // Common file extensions.
    if (u.contains('.pdf') ||
        u.contains('.doc') ||
        u.contains('.docx') ||
        u.contains('.txt')) {
      return true;
    }

    // Cloudinary: non-image assets often use /raw/upload/.
    if (u.contains('/raw/upload/')) {
      return true;
    }

    return false;
  }

  Future<void> _openDocumentPreview(DocumentItem doc) async {
    final ext = (doc.extension ?? '').toLowerCase();

    // If it's a known non-image type, don't try rendering as an image.
    if (_isKnownNonImageExtension(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hiện chỉ hỗ trợ xem ảnh (JPG/PNG/WEBP).'),
        ),
      );
      return;
    }

    final bytes = doc.bytes;
    final url = doc.url;

    if (url != null && url.trim().isNotEmpty && _looksLikeNonImageUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tài liệu này không phải ảnh. Hãy tải về để mở bằng ứng dụng khác.',
          ),
        ),
      );
      return;
    }

    final documentId = doc.id;
    final localPath = doc.localPath;
    if (bytes == null || bytes.isEmpty) {
      if (documentId != null) {
        final existing = await _offlineStore.getExistingLocalFile(
          documentId: documentId,
        );
        if (existing != null) {
          _showImageDialog(image: Image.file(existing, fit: BoxFit.contain));
          return;
        }
      }
    }

    if ((bytes == null || bytes.isEmpty) &&
        (url == null || url.trim().isEmpty) &&
        (localPath == null || localPath.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có file để xem.')));
      return;
    }

    // If we have bytes already, show immediately.
    if (bytes != null && bytes.isNotEmpty) {
      _showImageDialog(
        image: Image.memory(
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
      );
      return;
    }

    // Otherwise try to download and cache for offline.
    if (url != null &&
        url.trim().isNotEmpty &&
        documentId != null &&
        trip.id != null) {
      setState(() => _isLoading = true);
      try {
        final downloaded = await _documentsRepository.downloadBytes(
          url: url.trim(),
        );
        if (!mounted) return;

        if (!_looksLikeImageBytes(downloaded)) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không đọc được ảnh từ link (có thể file không phải ảnh hoặc bị lỗi quyền truy cập).',
              ),
            ),
          );
          return;
        }

        if (downloaded.isNotEmpty) {
          await _offlineStore.persistBytes(
            tripId: trip.id!,
            documentId: documentId,
            filename: doc.title,
            bytes: downloaded,
          );

          final localPath = await _offlineStore.getLocalPath(
            documentId: documentId,
          );
          if (!mounted) return;
          _replaceDocumentLocalPath(documentId, localPath);
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        _showImageDialog(
          image: Image.memory(
            downloaded,
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
        );
        return;
      } catch (err) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_downloadErrorMessage(err))));
        return;
      }
    }

    // Fallback: try network-only preview (no caching).
    if (url == null || url.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có file offline và không có URL để tải.'),
        ),
      );
      return;
    }

    _showImageDialog(
      image: Image.network(
        url.trim(),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text(
              'Không thể tải ảnh',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog({required Widget image}) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final maxWidth = MediaQuery.sizeOf(context).width - 32;
        final maxHeight = MediaQuery.sizeOf(context).height * 0.7;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: image,
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

  void _replaceDocumentLocalPath(int documentId, String? localPath) {
    if (localPath == null || localPath.trim().isEmpty) return;
    final idx = _documents.indexWhere((d) => d.id == documentId);
    if (idx < 0) return;
    final current = _documents[idx];
    _documents[idx] = DocumentItem(
      id: current.id,
      title: current.title,
      author: current.author,
      date: current.date,
      iconAsset: current.iconAsset,
      category: current.category,
      url: current.url,
      localPath: localPath,
      bytes: current.bytes,
      extension: current.extension,
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
                  onBack: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                  title: trip.title,
                  location: trip.location,
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
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : DocumentsListView(
                                  documents: filteredDocuments,
                                  categoryLabelFor: _categoryLabel,
                                  onTap: _openDocumentPreview,
                                  onDownloadPressed: _handleDownloadPressed,
                                  onDeleteRequested: (doc) async {
                                    await _confirmAndDeleteDocument(doc);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Navigation
                TripBottomNavigation(currentIndex: 1, trip: trip),
              ],
            ),

            // FAB
            Positioned(
              right: 16,
              bottom: 100,
              child: AddFloatingButton(
                padding: EdgeInsets.zero,
                onPressed: _openUploadDocumentSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmAndDeleteDocument(DocumentItem doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        );
        return AlertDialog(
          title: const Text('Xóa tài liệu?'),
          content: Text('Bạn có chắc muốn xóa "${doc.title}" không?'),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: shape,
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: shape,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xóa'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed != true) return false;
    if (!mounted) return false;

    final documentId = doc.id;
    if (documentId == null) {
      showTopToast(
        context,
        message: 'Không thể xóa (thiếu document_id)',
        type: TopToastType.error,
      );
      return false;
    }

    setState(() => _isLoading = true);
    try {
      await _documentsRepository.deleteDocument(documentId: documentId);

      try {
        await _offlineStore.clearLocalPath(documentId: documentId);
      } catch (_) {}
      if (!mounted) return false;
      showTopToast(
        context,
        message: 'Xóa tài liệu thành công',
        type: TopToastType.success,
      );
      await _refreshDocuments();
      return true;
    } catch (err) {
      if (!mounted) return false;
      setState(() => _isLoading = false);

      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để xóa tài liệu',
        ApiException() => err.message,
        _ => 'Không xóa được tài liệu',
      };
      showTopToast(context, message: msg, type: TopToastType.error);
      return false;
    }
  }

  Future<void> _downloadDocument(DocumentItem doc) async {
    final tripId = trip.id;
    if (tripId == null) {
      if (!mounted) return;
      showTopToast(
        context,
        message: 'Không thể tải về (thiếu trip_id)',
        type: TopToastType.error,
      );
      return;
    }

    final documentId = doc.id;
    if (documentId == null) {
      if (!mounted) return;
      showTopToast(
        context,
        message: 'Không thể tải về (thiếu document_id)',
        type: TopToastType.error,
      );
      return;
    }

    try {
      final existing = await _offlineStore.getExistingLocalFile(
        documentId: documentId,
      );
      if (existing != null) {
        if (!mounted) return;
        showTopToast(
          context,
          message: 'Tài liệu đã được tải về',
          type: TopToastType.success,
        );
        return;
      }
    } catch (_) {}

    final url = doc.url;
    if (url == null || url.trim().isEmpty) {
      if (!mounted) return;
      showTopToast(
        context,
        message: 'Không có đường dẫn để tải tài liệu',
        type: TopToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final downloaded = await _documentsRepository.downloadBytes(
        url: url.trim(),
      );

      if (downloaded.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showTopToast(
          context,
          message: 'Tải xuống thất bại (file rỗng).',
          type: TopToastType.error,
        );
        return;
      }

      await _offlineStore.persistBytes(
        tripId: tripId,
        documentId: documentId,
        filename: doc.title,
        bytes: downloaded,
      );

      // Verify file is really persisted.
      final saved = await _offlineStore.getExistingLocalFile(
        documentId: documentId,
      );
      if (saved == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showTopToast(
          context,
          message: 'Không lưu được file vào bộ nhớ máy.',
          type: TopToastType.error,
        );
        return;
      }

      final localPath = await _offlineStore.getLocalPath(
        documentId: documentId,
      );
      if (!mounted) return;

      _replaceDocumentLocalPath(documentId, localPath);
      setState(() => _isLoading = false);

      showTopToast(
        context,
        message: 'Đã lưu tài liệu để xem offline (bấm vào tài liệu để xem).',
        type: TopToastType.success,
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showTopToast(
        context,
        message: _downloadErrorMessage(err),
        type: TopToastType.error,
      );
    }
  }

  void _handleDownloadPressed(DocumentItem doc) {
    // Fire-and-forget from a sync callback.
    _downloadThenMaybePreview(doc);
  }

  Future<void> _downloadThenMaybePreview(DocumentItem doc) async {
    final documentId = doc.id;
    if (documentId == null) {
      await _downloadDocument(doc);
      return;
    }

    // If already cached locally, open immediately.
    final existingBefore = await _offlineStore.getExistingLocalFile(
      documentId: documentId,
    );
    if (existingBefore != null) {
      await _openDocumentPreview(doc);
      return;
    }

    await _downloadDocument(doc);

    // Only preview if the download actually produced a cached file.
    final existingAfter = await _offlineStore.getExistingLocalFile(
      documentId: documentId,
    );
    if (existingAfter == null) return;

    if (_isKnownNonImageExtension((doc.extension ?? '').toLowerCase())) {
      return;
    }

    await _openDocumentPreview(doc);
  }
}
