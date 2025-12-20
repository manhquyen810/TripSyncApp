import 'package:flutter/material.dart';
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
  DateTime? startDate;
  DateTime? endDate;

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
                  onImageSelected: (index) {
                    setState(() {
                      selectedImageIndex = index;
                    });
                  },
                ),

                const SizedBox(height: 32),

                MemberInviteField(
                  controller: memberEmailController,
                  onAddPressed: _handleAddMember,
                ),

                const SizedBox(height: 32),

                ActionButtons(
                  onCancel: () => Navigator.pop(context),
                  onCreate: _handleCreateTrip,
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2000),
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

  void _handleCreateTrip() {
    print('Creating trip...');
    Navigator.pop(context);
  }
}
