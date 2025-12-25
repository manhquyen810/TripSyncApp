import 'package:flutter/material.dart';

import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../home/presentation/widgets/member_avatar.dart';
import '../../../trip/domain/entities/trip.dart';
import '../widgets/checklist_category_card.dart';
import '../../../../routes/app_routes.dart';
import 'add_checklist_item_screen.dart';

class ChecklistScreen extends StatefulWidget {
  final Trip trip;

  const ChecklistScreen({super.key, required this.trip});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<ChecklistCategoryData> _categories;

  Trip get trip => widget.trip;

  @override
  void initState() {
    super.initState();
    _categories = const <ChecklistCategoryData>[
      ChecklistCategoryData(
        title: 'Thiết yếu',
        items: [
          ChecklistItemData(title: 'Thuốc say xe', assigneeName: 'Minh Anh'),
          ChecklistItemData(title: 'Kem chống nắng', assigneeName: 'Sáng'),
          ChecklistItemData(title: 'Áo ấm', assigneeName: 'Quyền'),
        ],
      ),
      ChecklistCategoryData(
        title: 'Quần áo',
        items: [
          ChecklistItemData(title: 'Áo ấm', assigneeName: 'Minh Anh'),
          ChecklistItemData(title: 'Áo mưa', assigneeName: 'Sáng'),
          ChecklistItemData(title: 'Khăn', assigneeName: 'Quyền'),
        ],
      ),
      ChecklistCategoryData(
        title: 'Thiết bị điện tử',
        items: [
          ChecklistItemData(title: 'Sạc dự phòng', assigneeName: 'Minh Anh'),
          ChecklistItemData(title: 'Loa bluetooth', assigneeName: 'Sáng'),
          ChecklistItemData(title: 'Tai nghe', assigneeName: 'Quyền'),
        ],
      ),
      ChecklistCategoryData(
        title: 'Vệ sinh cá nhân',
        items: [
          ChecklistItemData(
            title: 'Giấy ướt lau mặt',
            assigneeName: 'Minh Anh',
          ),
          ChecklistItemData(title: 'Xịt thơm', assigneeName: 'Sáng'),
          ChecklistItemData(title: 'Kem đánh răng', assigneeName: 'Quyền'),
        ],
      ),
      ChecklistCategoryData(
        title: 'Khác',
        items: [
          ChecklistItemData(
            title: 'Giấy ướt lau mặt',
            assigneeName: 'Minh Anh',
          ),
          ChecklistItemData(title: 'Xịt thơm', assigneeName: 'Sáng'),
          ChecklistItemData(title: 'Kem đánh răng', assigneeName: 'Quyền'),
        ],
      ),
    ];
  }

  void _toggleItem(int categoryIndex, int itemIndex) {
    setState(() {
      final category = _categories[categoryIndex];
      final items = List<ChecklistItemData>.from(category.items);
      final oldItem = items[itemIndex];
      items[itemIndex] = oldItem.copyWith(isChecked: !oldItem.isChecked);
      _categories = List<ChecklistCategoryData>.from(_categories);
      _categories[categoryIndex] = category.copyWith(items: items);
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 100),
        child: AddChecklistItemScreen(
          onAdd: (itemName, category, assignee) {
            setState(() {
              final categoryIndex = _categories.indexWhere(
                (c) => c.title == category,
              );
              if (categoryIndex != -1) {
                final cat = _categories[categoryIndex];
                final newItems = List<ChecklistItemData>.from(cat.items)
                  ..add(
                    ChecklistItemData(
                      title: itemName,
                      isChecked: false,
                      assigneeName: assignee,
                    ),
                  );
                _categories = List<ChecklistCategoryData>.from(_categories);
                _categories[categoryIndex] = cat.copyWith(items: newItems);
              }
            });
          },
        ),
      ),
    );
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
    final trip = widget.trip;

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
                    const SizedBox(height: 4),
                    _buildMemberInfo(),
                    const SizedBox(height: 16),
                    _buildPreparationProgress(_progress),
                    const SizedBox(height: 41),
                    _buildAddItemCta(),
                    const SizedBox(height: 41),
                    ..._categories.asMap().entries.map((entry) {
                      final categoryIndex = entry.key;
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 41),
                        child: ChecklistCategoryCard(
                          data: category,
                          onItemTap: (itemIndex) =>
                              _toggleItem(categoryIndex, itemIndex),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            TripBottomNavigation(currentIndex: 3),
          ],
        ),
      ),
      floatingActionButton: AddFloatingButton(onPressed: _showAddItemDialog),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, size: 24),
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

  Widget _buildMemberInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset('assets/icons/group.png', width: 24, height: 24),
            const SizedBox(width: 6),
            Text(
              '${widget.trip.memberCount} thành viên',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const Spacer(),
            ...widget.trip.memberColors
                .map(
                  (color) => MemberAvatar(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    size: 25,
                  ),
                )
                .toList(),
          ],
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
        onTap: _showAddItemDialog,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
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
}
