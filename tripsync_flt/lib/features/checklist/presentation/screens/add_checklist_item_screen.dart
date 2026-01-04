import 'package:flutter/material.dart';

class AddChecklistItemScreen extends StatefulWidget {
  final Function(String itemName, String category, String? assignee)? onAdd;
  final List<String>? members;

  final String? initialItemName;
  final String? initialCategory;
  final String? initialAssignee;
  final String? headerText;
  final String? submitText;

  const AddChecklistItemScreen({
    super.key,
    this.onAdd,
    this.members,
    this.initialItemName,
    this.initialCategory,
    this.initialAssignee,
    this.headerText,
    this.submitText,
  });

  @override
  State<AddChecklistItemScreen> createState() => _AddChecklistItemScreenState();
}

class _AddChecklistItemScreenState extends State<AddChecklistItemScreen> {
  final TextEditingController _itemNameController = TextEditingController();
  String? _selectedCategory;
  String? _selectedAssignee;

  List<String> get _memberNames {
    final fromParent = widget.members;
    if (fromParent != null && fromParent.isNotEmpty) return fromParent;
    return const <String>[
      'Nguyễn Văn A',
      'Trần Thị B',
      'Lê Văn C',
      'Phạm Thị D',
    ];
  }

  final _categories = [
    {'name': 'Thiết yếu', 'color': Color(0xFFE7000B), 'icon': Icons.warning},
    {'name': 'Quần áo', 'color': Color(0xFF55ACEE), 'icon': Icons.checkroom},
    {'name': 'Vệ sinh cá nhân', 'color': Color(0x8000C950), 'icon': Icons.clean_hands},
    {'name': 'Thiết bị điện tử', 'color': Color(0xFFFFA1E0), 'icon': Icons.devices},
    {'name': 'Khác', 'color': Color(0xFF65758B), 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _itemNameController.text = widget.initialItemName?.trim() ?? '';
    _selectedCategory = widget.initialCategory;
    _selectedAssignee = widget.initialAssignee;
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final itemName = _itemNameController.text.trim();
    if (itemName.isNotEmpty && _selectedCategory != null) {
      widget.onAdd?.call(itemName, _selectedCategory!, _selectedAssignee);
      Navigator.pop(context);
    }
  }

  void _showMemberSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Chọn thành viên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _memberNames.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8E8E8),
                      child: Icon(Icons.clear, color: Color(0xFF65758B)),
                    ),
                    title: const Text(
                      'Không phân công',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedAssignee = null;
                      });
                      Navigator.pop(context);
                    },
                  );
                }
                final memberName = _memberNames[index - 1];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF55ACEE),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    memberName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  trailing: _selectedAssignee == memberName
                      ? const Icon(Icons.check, color: Color(0xFF00C950))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedAssignee = memberName;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              _buildItemNameField(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildAssigneeSection(),
              const SizedBox(height: 32),
              _buildAddButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF55ACEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.checklist,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.headerText ?? 'Thêm món đồ cần mang',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 24, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildItemNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tên món đồ *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _itemNameController,
            decoration: InputDecoration(
              hintText: 'VD:Áo mưa kem chống nắng',
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Color(0xFF99A1AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC8C8C8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC8C8C8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00C950), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại hoạt động*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category['name'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryCard(
                      name: category['name'] as String,
                      color: category['color'] as Color,
                      icon: category['icon'] as IconData,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'] as String;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Colors.black),
              const SizedBox(width: 5),
              const Text(
                'Phân công cho',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showMemberSelectionBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFC8C8C8)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedAssignee ?? 'Chọn thành viên(tùy chọn)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        color: _selectedAssignee == null
                            ? const Color(0xFF99A1AF)
                            : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF959DA3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C950),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.submitText ?? 'Thêm món đồ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00C950) : const Color(0xFFC8C8C8),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
