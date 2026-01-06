import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../../data/datasources/expense_remote_data_source.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/trip_member.dart';

class AddExpenseScreen extends StatefulWidget {
  final int tripId;

  const AddExpenseScreen({super.key, required this.tripId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String? selectedCategory;
  int? selectedPayerId;
  final Set<int> selectedMemberIds = {};
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  late final ExpenseRepositoryImpl _repository;
  late Future<List<TripMember>> _membersFuture;
  bool _isSubmitting = false;

  final Map<String, Map<String, dynamic>> categories = {
    'food': {'name': 'Ăn uống', 'icon': Icons.restaurant},
    'flight': {'name': 'Vé máy bay', 'icon': Icons.flight},
    'transportation': {'name': 'Vé xe khách', 'icon': Icons.directions_bus},
    'accommodation': {'name': 'Khách sạn', 'icon': Icons.hotel},
    'other': {'name': 'Khác', 'icon': Icons.more_horiz},
  };

  @override
  void initState() {
    super.initState();
    _repository = ExpenseRepositoryImpl(
      ExpenseRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );
    _membersFuture = _repository.getTripMembers(widget.tripId);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Scrollable Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    _buildCategorySection(),
                    const SizedBox(height: 30),
                    _buildDescriptionSection(),
                    const SizedBox(height: 30),
                    _buildAmountSection(),
                    const SizedBox(height: 30),
                    _buildDateTimeSection(),
                    const SizedBox(height: 30),
                    _buildPayerSection(),
                    const SizedBox(height: 30),
                    _buildParticipantsSection(),
                    const SizedBox(height: 40),
                    _buildActionButtons(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF4CA5E0),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          const Text(
            'Thêm chi tiêu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 43),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh mục*',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.entries.map((entry) {
            final key = entry.key;
            final category = entry.value;
            final isSelected = selectedCategory == key;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = key;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00C950)
                        : const Color(0xFF99A1AF),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mô tả chi tiêu*',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            hintText: 'VD: Ăn trưa quán bé mặn, Vé máy bay ...',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9A9A9A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9A9A9A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C950)),
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Số tiền(VND)*',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'VD: 1500000',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9A9A9A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9A9A9A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C950)),
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thời gian chi tiêu*',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              if (!mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDateTime),
              );
              if (time != null) {
                setState(() {
                  selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF9A9A9A)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFF9A9A9A),
                ),
                const SizedBox(width: 12),
                Text(
                  '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} - ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ai đã trả*',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<TripMember>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Không thể tải danh sách thành viên');
            }

            final members = snapshot.data!;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: members.map((member) {
                final isSelected = selectedPayerId == member.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPayerId = member.id;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00C950)
                            : const Color(0xFF99A1AF),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00C950),
                            size: 20,
                          ),
                        if (isSelected) const SizedBox(width: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(member.name, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chia cho ai*',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<TripMember>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Không thể tải danh sách thành viên');
            }

            final members = snapshot.data!;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: members.map((member) {
                final isSelected = selectedMemberIds.contains(member.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedMemberIds.remove(member.id);
                      } else {
                        selectedMemberIds.add(member.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00C950)
                            : const Color(0xFF99A1AF),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00C950),
                            size: 20,
                          ),
                        if (isSelected) const SizedBox(width: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(member.name, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Huỷ',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '+ Thêm chi tiêu',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (selectedCategory == null) {
      showTopToast(
        context,
        message: 'Vui lòng chọn danh mục',
        type: TopToastType.error,
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      showTopToast(
        context,
        message: 'Vui lòng nhập mô tả',
        type: TopToastType.error,
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      showTopToast(
        context,
        message: 'Vui lòng nhập số tiền hợp lệ',
        type: TopToastType.error,
      );
      return;
    }

    if (selectedPayerId == null) {
      showTopToast(
        context,
        message: 'Vui lòng chọn người đã trả',
        type: TopToastType.error,
      );
      return;
    }

    if (selectedMemberIds.isEmpty) {
      showTopToast(
        context,
        message: 'Vui lòng chọn người tham gia',
        type: TopToastType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repository.createExpense(
        tripId: widget.tripId,
        amount: amount,
        description: descriptionController.text.trim(),
        category: selectedCategory,
        payerId: selectedPayerId!,
        involvedUserIds: selectedMemberIds.toList(),
        expenseDate: selectedDateTime,
      );

      if (!mounted) return;

      showTopToast(
        context,
        message: 'Thêm chi tiêu thành công',
        type: TopToastType.success,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showTopToast(context, message: 'Lỗi: $e', type: TopToastType.error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ignore: unused_field
  static const String _addExpenseScreenLegacy = r'''

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
              color: const Color(0xFF4CA5E0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(

                    }
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Mô tả chi tiêu *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'VD: Ăn trưa quán bé mặn, Vé máy bay ...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Color(0xFFA8B1BE),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9A9A9A), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CA5E0), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Số tiền (VND) *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'VD: 1500000',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      color: Color(0xFFA8B1BE),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9A9A9A), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CA5E0), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Ai đã trả *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: users.map((user) {
                    final isSelected = selectedPayer == user['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPayer = user['name'];
                        });
                      },
                      child: Container(
                        height: 56,
                        width: 141,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4CA5E0) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4CA5E0) : const Color(0xFF99A1AF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              user['avatar']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                user['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Ai được chia *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: users.map((user) {
                    final isSelected = selectedSplitWith.contains(user['name']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedSplitWith.remove(user['name']);
                          } else {
                            selectedSplitWith.add(user['name']!);
                          }
                        });
                      },
                      child: Container(
                        height: 56,
                        width: 141,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF4CA5E0) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF4CA5E0) : const Color(0xFF99A1AF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            Text(
                              user['avatar']!,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                user['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Huỷ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (selectedCategory != null &&
                              descriptionController.text.isNotEmpty &&
                              amountController.text.isNotEmpty &&
                              selectedPayer != null &&
                              selectedSplitWith.isNotEmpty) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm chi tiêu thành công'),
                                backgroundColor: Color(0xFF00C950),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng điền đầy đủ thông tin'),
                                backgroundColor: Color(0xFFDF1F32),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Thêm chi tiêu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ''';
}
