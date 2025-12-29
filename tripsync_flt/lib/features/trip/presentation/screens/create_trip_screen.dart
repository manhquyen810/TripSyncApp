import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/repositories/trip_repository.dart';
import '../services/trip_cover_images.dart';
import '../services/trip_cover_store.dart';
import '../widgets/createTrip/custom_text_field.dart';
import '../widgets/createTrip/date_picker_field.dart';
import '../widgets/createTrip/cover_images_grid.dart';
import '../widgets/createTrip/member_invite_field.dart';
import '../widgets/createTrip/action_buttons.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController memberEmailController = TextEditingController();
  int? selectedImageIndex;
  String? selectedCoverFilePath;
  DateTime? startDate;
  DateTime? endDate;

  bool _isSubmitting = false;
  late final TripRepository _tripRepository;

  @override
  void initState() {
    super.initState();
    _tripRepository = TripRepositoryImpl(
      TripRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );
  }

  @override
  void dispose() {
    tripNameController.dispose();
    destinationController.dispose();
    descriptionController.dispose();
    memberEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 24),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Tạo chuyến đi mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Điền thông tin để bắt đầu lên kế hoạch cho chuyến đi của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA8B1BE),
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 32),

                CustomTextField(
                  label: 'Tên chuyến đi *',
                  controller: tripNameController,
                  hintText: 'VD:Sapa- Xứ xở sương mù',
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Điểm đến *',
                  controller: destinationController,
                  hintText: 'VD:Sapa, Lào Cai',
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DatePickerField(
                        label: 'Ngày bắt đầu *',
                        selectedDate: startDate,
                        onTap: () => _selectStartDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DatePickerField(
                        label: 'Ngày kết thúc *',
                        selectedDate: endDate,
                        onTap: () => _selectEndDate(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Mô tả (tùy chọn)',
                  controller: descriptionController,
                  hintText: 'Mô tả ngắn về chuyến đi',
                  maxLines: 4,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Ảnh bìa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                CoverImagesGrid(
                  selectedImageIndex: selectedImageIndex,
                  selectedFilePath: selectedCoverFilePath,
                  onImageSelected: (index) {
                    setState(() {
                      selectedImageIndex = index;
                      selectedCoverFilePath = null;
                    });
                  },
                  onPickFromFile: () => _pickCoverFromFile(),
                ),

                const SizedBox(height: 32),

                MemberInviteField(
                  controller: memberEmailController,
                  onAddPressed: _handleAddMember,
                ),

                const SizedBox(height: 32),

                ActionButtons(
                  onCancel: () => Navigator.pop(context),
                  onCreate: () => _handleCreateTrip(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        if (endDate != null && picked.isAfter(endDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? today,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void _handleAddMember() {
    print('Adding member: ${memberEmailController.text}');
  }

  Future<void> _handleCreateTrip() async {
    if (_isSubmitting) return;

    final name = tripNameController.text.trim();
    final destination = destinationController.text.trim();

    if (name.isEmpty ||
        destination.isEmpty ||
        startDate == null ||
        endDate == null) {
      showTopToast(
        context,
        message: 'Vui lòng điền đủ thông tin bắt buộc',
        type: TopToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final raw = await _tripRepository.createTrip(
        name: name,
        destination: destination,
        description: descriptionController.text,
        coverImageUrl: _selectedCoverForCreatePayload(),
        startDate: startDate!,
        endDate: endDate!,
      );

      final createdTripId = _extractTripId(raw);
      final createdTripKey = _extractTripKey(raw);
      final createdInviteCode = _extractInviteCode(raw);

      String? syncedCoverUrl;
      var coverSyncFailed = false;

      final selectedFile = selectedCoverFilePath?.trim();
      if (selectedFile != null &&
          selectedFile.isNotEmpty &&
          createdTripId != null) {
        try {
          final uploadedUrl = await _tripRepository.uploadTripCover(
            tripId: createdTripId,
            filePath: selectedFile,
          );

          await _tripRepository.updateTripCover(
            tripId: createdTripId,
            coverImageUrl: uploadedUrl,
          );

          syncedCoverUrl = uploadedUrl;

          await TripCoverStore.saveCoverAssetForTripId(
            tripId: createdTripId,
            assetPath: uploadedUrl,
          );

          if (createdInviteCode != null) {
            await TripCoverStore.saveCoverAssetForTripKey(
              tripKey: createdInviteCode,
              assetPath: uploadedUrl,
            );
          }
        } catch (_) {
          coverSyncFailed = true;
          if (mounted) {
            showTopToast(
              context,
              message: 'Tải ảnh bìa lên server thất bại. Thử lại sau.',
              type: TopToastType.error,
            );
          }
        }
      }

      final coverPath = _resolveSelectedCoverPath();
      if (coverPath != null) {
        // Never persist a local file path as the trip cover.
        // - Other users/devices can't access it.
        // - File picker paths are often in cache and can disappear after restart.
        final candidate = (syncedCoverUrl ?? coverPath).trim();
        final String? asset =
            (candidate.startsWith('http://') ||
                candidate.startsWith('https://') ||
                candidate.startsWith('assets/'))
            ? candidate
            : null;

        if (asset == null) {
          // Fall back to default cover behavior (server cover if available, else
          // UI fallback assets). Do not write an unusable local path.
          final baseMessage =
              (raw['message'] ?? raw['detail'] ?? 'Tạo chuyến đi thành công')
                  .toString();
          final message = coverSyncFailed
              ? '$baseMessage (ảnh bìa chưa đồng bộ lên server)'
              : baseMessage;

          if (mounted) {
            showTopToast(context, message: message, type: TopToastType.success);
          }

          await Future<void>.delayed(const Duration(milliseconds: 650));
          if (!mounted) return;
          Navigator.pop(context, createdTripId);
          return;
        }

        if (createdTripKey != null) {
          await TripCoverStore.saveCoverAssetForTripKey(
            tripKey: createdTripKey,
            assetPath: asset,
          );
        } else if (createdTripId != null) {
          await TripCoverStore.saveCoverAssetForTripId(
            tripId: createdTripId,
            assetPath: asset,
          );
        }

        if (createdInviteCode != null) {
          await TripCoverStore.saveCoverAssetForTripKey(
            tripKey: createdInviteCode,
            assetPath: asset,
          );
        }
      }

      final baseMessage =
          (raw['message'] ?? raw['detail'] ?? 'Tạo chuyến đi thành công')
              .toString();
      final message = coverSyncFailed
          ? '$baseMessage (ảnh bìa chưa đồng bộ lên server)'
          : baseMessage;

      if (mounted) {
        showTopToast(context, message: message, type: TopToastType.success);
      }

      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      Navigator.pop(context, createdTripId);
    } on ApiException catch (e) {
      if (mounted) {
        final msg = switch (e) {
          TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
          UnauthorizedException() => 'Vui lòng đăng nhập để tạo chuyến đi',
          _ => e.message,
        };
        showTopToast(context, message: msg, type: TopToastType.error);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Tạo chuyến đi thất bại: $e',
          type: TopToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pickCoverFromFile() async {
    if (_isSubmitting) return;

    if (kIsWeb) {
      if (!mounted) return;
      showTopToast(
        context,
        message: 'Chọn ảnh từ tệp chưa hỗ trợ trên Web',
        type: TopToastType.error,
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );
      final path = result?.files.single.path;
      if (path == null || path.trim().isEmpty) return;

      if (!mounted) return;
      setState(() {
        selectedCoverFilePath = path;
        selectedImageIndex = null;
      });
    } catch (e) {
      if (!mounted) return;
      showTopToast(
        context,
        message: 'Không chọn được ảnh: $e',
        type: TopToastType.error,
      );
    }
  }

  String? _resolveSelectedCoverPath() {
    final filePath = selectedCoverFilePath?.trim();
    if (filePath != null && filePath.isNotEmpty) return filePath;

    final idx = selectedImageIndex;
    if (idx != null && idx >= 0 && idx < TripCoverImages.assets.length) {
      return TripCoverImages.assets[idx];
    }
    return null;
  }

  String? _selectedCoverAsRemoteUrl() {
    // Kept for backward-compatibility with existing call sites (if any).
    // Prefer using _selectedCoverForCreatePayload().
    final cover = _resolveSelectedCoverPath();
    if (cover == null) return null;
    final trimmed = cover.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
      return trimmed;
    return null;
  }

  String? _selectedCoverForCreatePayload() {
    // We only send values that are valid for all devices:
    // - Remote URLs (http/https)
    // - Built-in assets (assets/..)
    // Never send a local file path (e.g. C:\... or /storage/..).
    final cover = _resolveSelectedCoverPath();
    if (cover == null) return null;

    final trimmed = cover.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('assets/')) {
      return trimmed;
    }

    return null;
  }

  int? _extractTripId(Map<String, dynamic> raw) {
    // Some endpoints may return TripRead directly (root-level "id")
    // while others return ApiResponse { message, data: { id, ... } }.
    final rootId = raw['id'] ?? raw['trip_id'] ?? raw['tripId'];
    final parsedRoot = _parseId(rootId);
    if (parsedRoot != null) return parsedRoot;

    final data = raw['data'];
    if (data is Map) {
      final id =
          (data as Map)['id'] ??
          (data as Map)['trip_id'] ??
          (data as Map)['tripId'];
      final parsed = _parseId(id);
      if (parsed != null) return parsed;

      final trip = (data as Map)['trip'];
      if (trip is Map) {
        final nestedId =
            (trip as Map)['id'] ??
            (trip as Map)['trip_id'] ??
            (trip as Map)['tripId'];
        return _parseId(nestedId);
      }
    }
    return null;
  }

  String? _extractTripKey(Map<String, dynamic> raw) {
    final rootId = raw['id'] ?? raw['trip_id'] ?? raw['tripId'];
    final rootKey = _parseKey(rootId);
    if (rootKey != null) return rootKey;

    final data = raw['data'];
    if (data is Map) {
      final id =
          (data as Map)['id'] ??
          (data as Map)['trip_id'] ??
          (data as Map)['tripId'];
      final parsed = _parseKey(id);
      if (parsed != null) return parsed;

      final trip = (data as Map)['trip'];
      if (trip is Map) {
        final nestedId =
            (trip as Map)['id'] ??
            (trip as Map)['trip_id'] ??
            (trip as Map)['tripId'];
        return _parseKey(nestedId);
      }
    }
    return null;
  }

  String? _extractInviteCode(Map<String, dynamic> raw) {
    final root = raw['invite_code'];
    final parsedRoot = _parseKey(root);
    if (parsedRoot != null) return parsedRoot;

    final data = raw['data'];
    if (data is Map) {
      final direct = (data as Map)['invite_code'];
      final parsedDirect = _parseKey(direct);
      if (parsedDirect != null) return parsedDirect;

      final trip = (data as Map)['trip'];
      if (trip is Map) {
        final nested = (trip as Map)['invite_code'];
        final parsedNested = _parseKey(nested);
        if (parsedNested != null) return parsedNested;

        final nestedDirect = (trip as Map)['code'];
        return _parseKey(nestedDirect);
      }
    }
    return null;
  }

  int? _parseId(dynamic id) {
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }

  String? _parseKey(dynamic id) {
    if (id == null) return null;
    final key = id.toString().trim();
    if (key.isEmpty || key.toLowerCase() == 'null') return null;
    return key;
  }
}
