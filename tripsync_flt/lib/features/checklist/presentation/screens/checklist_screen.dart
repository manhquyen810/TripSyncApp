import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/config/env.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/data/datasources/trip_remote_data_source.dart';
import '../../../trip/data/repositories/trip_repository_impl.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../data/datasources/checklist_remote_data_source.dart';
import '../../data/models/checklist_item_dto.dart';
import '../../data/repositories/checklist_repository_impl.dart';
import '../../domain/repositories/checklist_repository.dart';
import '../widgets/checklist_category_card.dart';
import 'add_checklist_item_screen.dart';

class ChecklistScreen extends StatefulWidget {
  final Trip trip;

  const ChecklistScreen({super.key, required this.trip});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<ChecklistCategoryData> _categories;
  late final ChecklistRepository _checklistRepository;
  late final TripRepository _tripRepository;
  bool _isLoading = true;

  Map<int, String> _userNameById = <int, String>{};
  Map<int, String> _userAvatarUrlById = <int, String>{};
  Map<String, int> _userIdByName = <String, int>{};

  static const List<String> _categoryOrder = <String>[
    'Thiết yếu',
    'Quần áo',
    'Thiết bị điện tử',
    'Vệ sinh cá nhân',
    'Khác',
  ];

  static const String _metaPrefix = '[[ts:';
  static const String _metaSuffix = ']]';

  Trip get trip => widget.trip;

  @override
  void initState() {
    super.initState();

    _categories = const <ChecklistCategoryData>[];

    final authedClient = ApiClient(
      authTokenProvider: AuthTokenStore.getAccessToken,
    );

    _checklistRepository = ChecklistRepositoryImpl(
      ChecklistRemoteDataSourceImpl(authedClient),
    );
    _tripRepository = TripRepositoryImpl(
      TripRemoteDataSourceImpl(authedClient),
    );

    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final tripId = trip.id;
    if (tripId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải checklist (thiếu trip_id)'),
        ),
      );
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final itemsFuture = _checklistRepository.listTripChecklist(
        tripId: tripId,
      );
      final membersFuture = _tripRepository.listTripMembers(tripId: tripId);

      final items = await itemsFuture;
      final rawMembers = await membersFuture;
      final userNameById = _extractUserNameById(rawMembers);
      final userAvatarUrlById = _extractUserAvatarUrlById(rawMembers);
      final userIdByName = <String, int>{
        for (final e in userNameById.entries) e.value: e.key,
      };

      final categories = _buildCategories(items);

      if (!mounted) return;
      setState(() {
        _userNameById = userNameById;
        _userAvatarUrlById = userAvatarUrlById;
        _userIdByName = userIdByName;
        _categories = categories;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để xem checklist',
        ApiException() => err.message,
        _ => 'Không tải được checklist',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _toggleItem(int categoryIndex, int itemIndex) async {
    final category = _categories[categoryIndex];
    final item = category.items[itemIndex];
    final itemId = item.id;
    if (itemId == null) {
      setState(() {
        final items = List<ChecklistItemData>.from(category.items);
        items[itemIndex] = item.copyWith(isChecked: !item.isChecked);
        _categories = List<ChecklistCategoryData>.from(_categories);
        _categories[categoryIndex] = category.copyWith(items: items);
      });
      return;
    }

    final next = !item.isChecked;
    try {
      final updated = await _checklistRepository.toggleItem(
        itemId: itemId,
        isDone: next,
      );

      final decoded = _decodeContent(updated.content);
      final assigneeName = _resolveAssigneeName(
        assigneeId: updated.assigneeId,
        fallback: decoded.assigneeName,
      );
      final assigneeAvatarUrl = _resolveAssigneeAvatarUrl(
        assigneeId: updated.assigneeId,
      );

      setState(() {
        final items = List<ChecklistItemData>.from(category.items);
        items[itemIndex] = item.copyWith(
          isChecked: updated.isDone,
          title: decoded.title,
          assigneeId: updated.assigneeId,
          assigneeName: assigneeName,
          assigneeAvatarUrl: assigneeAvatarUrl,
        );
        _categories = List<ChecklistCategoryData>.from(_categories);
        _categories[categoryIndex] = category.copyWith(items: items);
      });
    } catch (err) {
      if (!mounted) return;
      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để cập nhật checklist',
        ApiException() => err.message,
        _ => 'Không cập nhật được checklist',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withAlpha(51),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.66,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: Colors.white,
              child: AddChecklistItemScreen(
                onAdd: (itemName, category, assignee) {
                  _addItem(
                    itemName: itemName,
                    category: category,
                    assigneeName: assignee,
                  );
                },
                members: _userNameById.values.toList(growable: false),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showItemActions({required int categoryIndex, required int itemIndex}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.pencil),
                title: const Text('Sửa'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditItemDialog(
                    categoryIndex: categoryIndex,
                    itemIndex: itemIndex,
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: Colors.red),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteItem(
                    categoryIndex: categoryIndex,
                    itemIndex: itemIndex,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditItemDialog({
    required int categoryIndex,
    required int itemIndex,
  }) {
    final category = _categories[categoryIndex];
    final item = category.items[itemIndex];
    if (item.id == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withAlpha(51),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.66,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: Colors.white,
              child: AddChecklistItemScreen(
                initialItemName: item.title,
                initialCategory: category.title,
                initialAssignee: item.assigneeName,
                headerText: 'Sửa món đồ cần mang',
                submitText: 'Lưu',
                onAdd: (itemName, newCategory, assigneeName) {
                  _updateItem(
                    itemId: item.id!,
                    itemName: itemName,
                    category: newCategory,
                    assigneeName: assigneeName,
                  );
                },
                members: _userNameById.values.toList(growable: false),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteItem({
    required int categoryIndex,
    required int itemIndex,
  }) async {
    final category = _categories[categoryIndex];
    final item = category.items[itemIndex];
    if (item.id == null) return;

    final ok = await _confirmChecklistDeleteDialog(itemTitle: item.title);
    if (ok != true) return;
    await _deleteItem(itemId: item.id!);
  }

  Future<bool> _confirmChecklistDeleteDialog({
    required String itemTitle,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        );
        return AlertDialog(
          title: const Text('Xóa checklist?'),
          content: Text('Bạn có chắc muốn xóa "$itemTitle" không?'),
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

    return confirmed == true;
  }

  Future<void> _updateItem({
    required int itemId,
    required String itemName,
    required String category,
    required String? assigneeName,
  }) async {
    final content = _encodeContent(
      title: itemName,
      category: category,
      assigneeName: assigneeName,
    );
    final assigneeId = assigneeName == null
        ? null
        : _userIdByName[assigneeName];

    if (mounted) setState(() => _isLoading = true);
    try {
      await _checklistRepository.updateItem(
        itemId: itemId,
        content: content,
        assigneeId: assigneeId,
      );
      await _loadChecklist();
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để cập nhật checklist',
        ApiException() => err.message,
        _ => 'Không cập nhật được checklist',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _deleteItem({required int itemId}) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      await _checklistRepository.deleteItem(itemId: itemId);
      await _loadChecklist();
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để xóa checklist',
        ApiException() => err.message,
        _ => 'Không xóa được checklist',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _addItem({
    required String itemName,
    required String category,
    required String? assigneeName,
  }) async {
    final tripId = trip.id;
    if (tripId == null) return;

    final content = _encodeContent(
      title: itemName,
      category: category,
      assigneeName: assigneeName,
    );
    final assigneeId = assigneeName == null
        ? null
        : _userIdByName[assigneeName];

    if (mounted) setState(() => _isLoading = true);
    try {
      await _checklistRepository.addItem(
        tripId: tripId,
        content: content,
        assigneeId: assigneeId,
      );
      await _loadChecklist();
    } catch (err) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = switch (err) {
        TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
        UnauthorizedException() => 'Vui lòng đăng nhập để thêm checklist',
        ApiException() => err.message,
        _ => 'Không thêm được checklist',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  double get _progress {
    final total = _categories.fold<int>(0, (sum, c) => sum + c.items.length);
    if (total == 0) return 0;
    final checked = _categories.fold<int>(
      0,
      (sum, c) => sum + c.items.where((i) => i.isChecked).length,
    );
    return checked / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTripImageCard(),
                    const SizedBox(height: 15),
                    _buildPreparationProgress(_progress),
                    const SizedBox(height: 7),
                    _buildAddItemCta(),
                    const SizedBox(height: 7),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ..._categories.asMap().entries.map((entry) {
                      final categoryIndex = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ChecklistCategoryCard(
                          data: category,
                          onItemTap: (itemIndex) =>
                              _toggleItem(categoryIndex, itemIndex),
                          onItemLongPress: (itemIndex) => _showItemActions(
                            categoryIndex: categoryIndex,
                            itemIndex: itemIndex,
                          ),
                          onConfirmDelete: (itemIndex) async {
                            final item = category.items[itemIndex];
                            if (item.id == null) return false;
                            return _confirmChecklistDeleteDialog(
                              itemTitle: item.title,
                            );
                          },
                          onDelete: (itemIndex) {
                            final item = category.items[itemIndex];
                            final id = item.id;
                            if (id == null) return;
                            _deleteItem(itemId: id);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            TripBottomNavigation(currentIndex: 3, trip: trip),
          ],
        ),
      ),
      floatingActionButton: AddFloatingButton(onPressed: _showAddItemSheet),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.arrowLeft, size: 24),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/location.png',
                      width: 20,
                      height: 20,
                      color: const Color(0xFF99A1AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip.location,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF99A1AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripImageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 235,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.trip.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 11,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/location.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.trip.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreparationProgress(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 90,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ chuẩn bị',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 13,
                backgroundColor: const Color(0x1A99A1AF),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0x8000C950),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        onTap: _showAddItemSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              '+ Thêm món đồ cần mang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ChecklistCategoryData> _buildCategories(List<ChecklistItemDto> items) {
    final grouped = <String, List<ChecklistItemData>>{
      for (final c in _categoryOrder) c: <ChecklistItemData>[],
    };

    for (final item in items) {
      final decoded = _decodeContent(item.content);
      final category = decoded.category ?? _inferCategory(decoded.title);
      final key = grouped.containsKey(category) ? category : 'Khác';

      final assigneeName = _resolveAssigneeName(
        assigneeId: item.assigneeId,
        fallback: decoded.assigneeName,
      );
      final assigneeAvatarUrl = _resolveAssigneeAvatarUrl(
        assigneeId: item.assigneeId,
      );

      grouped[key]!.add(
        ChecklistItemData(
          id: item.id,
          title: decoded.title,
          isChecked: item.isDone,
          assigneeId: item.assigneeId,
          assigneeName: assigneeName,
          assigneeAvatarUrl: assigneeAvatarUrl,
        ),
      );
    }

    return _categoryOrder
        .map((c) => ChecklistCategoryData(title: c, items: grouped[c]!))
        .where((c) => c.items.isNotEmpty)
        .toList(growable: false);
  }

  String _resolveAssigneeName({
    required int? assigneeId,
    required String? fallback,
  }) {
    if (assigneeId == null) return fallback ?? 'Chưa gán';
    return _userNameById[assigneeId] ?? fallback ?? 'User $assigneeId';
  }

  String? _resolveAssigneeAvatarUrl({required int? assigneeId}) {
    if (assigneeId == null) return null;
    return _userAvatarUrlById[assigneeId];
  }

  String _inferCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('thuốc') ||
        t.contains('kem') ||
        t.contains('chống nắng') ||
        t.contains('say')) {
      return 'Thiết yếu';
    }
    if (t.contains('áo') ||
        t.contains('quần') ||
        t.contains('khăn') ||
        t.contains('mũ') ||
        t.contains('giày')) {
      return 'Quần áo';
    }
    if (t.contains('sạc') ||
        t.contains('loa') ||
        t.contains('tai nghe') ||
        t.contains('điện thoại')) {
      return 'Thiết bị điện tử';
    }
    if (t.contains('kem đánh răng') ||
        t.contains('bàn chải') ||
        t.contains('xịt') ||
        t.contains('giấy ướt') ||
        t.contains('rửa')) {
      return 'Vệ sinh cá nhân';
    }
    return 'Khác';
  }

  String _encodeContent({
    required String title,
    required String category,
    required String? assigneeName,
  }) {
    final safeTitle = title.trim();
    final fields = <String, String>{'cat': category.trim()};
    final a = assigneeName?.trim();
    if (a != null && a.isNotEmpty) fields['assignee'] = a;

    final meta = fields.entries.map((e) => '${e.key}=${e.value}').join(';');
    return '$_metaPrefix$meta$_metaSuffix $safeTitle'.trim();
  }

  _DecodedContent _decodeContent(String raw) {
    final s = raw.trim();
    if (!s.startsWith(_metaPrefix)) {
      return _DecodedContent(title: s);
    }
    final end = s.indexOf(_metaSuffix);
    if (end < 0) return _DecodedContent(title: s);

    final meta = s.substring(_metaPrefix.length, end);
    final rest = s.substring(end + _metaSuffix.length).trim();

    String? category;
    String? assigneeName;
    for (final part in meta.split(';')) {
      final kv = part.split('=');
      if (kv.length != 2) continue;
      final k = kv[0].trim();
      final v = kv[1].trim();
      if (k == 'cat' && v.isNotEmpty) category = v;
      if (k == 'assignee' && v.isNotEmpty) assigneeName = v;
    }

    return _DecodedContent(
      title: rest.isEmpty ? s : rest,
      category: category,
      assigneeName: assigneeName,
    );
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

  Map<int, String> _extractUserAvatarUrlById(Map<String, dynamic> raw) {
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

    const avatarKeys = <String>[
      'avatar_url',
      'avatarUrl',
      'avatar',
      'photo_url',
      'photoUrl',
      'photo',
      'profile_image_url',
      'profileImageUrl',
      'profile_picture_url',
      'profilePictureUrl',
      'image_url',
      'imageUrl',
    ];

    final out = <int, String>{};
    for (final item in data) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);

      final nestedUser = map['user'] ?? map['profile'] ?? map['member'];
      final userMap = nestedUser is Map
          ? Map<String, dynamic>.from(nestedUser)
          : null;

      final id = readInt((userMap ?? map)['id']) ?? readInt(map['user_id']);
      if (id == null) continue;

      String? avatar;
      for (final key in avatarKeys) {
        final v = (userMap ?? map)[key] ?? map[key];
        final s = readString(v);
        if (s == null) continue;
        if (s.toLowerCase() == 'null') continue;
        avatar = s;
        break;
      }

      if (avatar != null) {
        out[id] = _normalizeMediaUrl(avatar);
      }
    }

    return out;
  }

  String _normalizeMediaUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    if (trimmed.startsWith('assets/')) return trimmed;

    if (trimmed.startsWith('/')) return '${Env.apiBaseUrl}$trimmed';
    return '${Env.apiBaseUrl}/$trimmed';
  }
}

class _DecodedContent {
  final String title;
  final String? category;
  final String? assigneeName;

  const _DecodedContent({
    required this.title,
    this.category,
    this.assigneeName,
  });
}
