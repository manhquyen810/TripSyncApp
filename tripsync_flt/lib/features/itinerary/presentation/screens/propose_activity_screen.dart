import 'package:flutter/material.dart';
import '../widgets/propose_activity_widgets.dart';

class ProposeActivityScreen extends StatefulWidget {
  const ProposeActivityScreen({super.key});

  @override
  State<ProposeActivityScreen> createState() => _ProposeActivityScreenState();
}

class _ProposeActivityScreenState extends State<ProposeActivityScreen> {
  static const Color _green = Color(0xFF00C950);
  static const Color _surface = Color(0xFFF4F4F4);
  static const Color _muted = Color(0xFF99A1AF);
  static const Color _hint = Color(0xFF959DA3);

  // Lazy init helps avoid Flutter Web hot-reload cases where existing State
  // instances get new fields as `null` and then crash on dispose.
  TextEditingController? _nameController;
  TextEditingController? _descriptionController;
  TextEditingController? _locationController;

  FocusNode? _nameFocusNode;
  FocusNode? _descriptionFocusNode;
  FocusNode? _locationFocusNode;

  TextEditingController get _nameCtrl =>
      _nameController ??= TextEditingController();
  TextEditingController get _descriptionCtrl =>
      _descriptionController ??= TextEditingController();
  TextEditingController get _locationCtrl =>
      _locationController ??= TextEditingController();

  FocusNode get _nameFocus => _nameFocusNode ??= FocusNode();
  FocusNode get _descriptionFocus => _descriptionFocusNode ??= FocusNode();
  FocusNode get _locationFocus => _locationFocusNode ??= FocusNode();

  DateTime? _date;
  TimeOfDay? _time;

  int _selectedTypeIndex = 0;

  final List<ProposeActivityType> _types = const [
    ProposeActivityType(label: 'Ăn uống', icon: Icons.restaurant_outlined),
    ProposeActivityType(label: 'Khách sạn', icon: Icons.apartment_outlined),
    ProposeActivityType(label: 'Tham quan', icon: Icons.photo_camera_outlined),
    ProposeActivityType(
      label: 'Hoạt động',
      icon: Icons.local_activity_outlined,
    ),
    ProposeActivityType(
      label: 'Di chuyển',
      icon: Icons.directions_car_filled_outlined,
    ),
  ];

  @override
  void dispose() {
    _nameController?.dispose();
    _descriptionController?.dispose();
    _locationController?.dispose();

    _nameFocusNode?.dispose();
    _descriptionFocusNode?.dispose();
    _locationFocusNode?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 40, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProposeActivityHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loại hoạt động*',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ProposeActivityTypeSelector(
                      green: _green,
                      surface: _surface,
                      types: _types,
                      selectedIndex: _selectedTypeIndex,
                      onSelect: (index) =>
                          setState(() => _selectedTypeIndex = index),
                    ),
                    const SizedBox(height: 36),
                    ProposeActivityLabeledTextField(
                      label: 'Tên hoạt động *',
                      hintText: 'VD:Sapa- Xứ xở sương mù',
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      green: _green,
                      muted: _muted,
                      hintColor: _hint,
                    ),
                    const SizedBox(height: 36),
                    ProposeActivityLabeledTextField(
                      label: 'Mô tả *',
                      hintText: 'VD:Sapa- Xứ xở sương mù',
                      controller: _descriptionCtrl,
                      focusNode: _descriptionFocus,
                      maxLines: 6,
                      minHeight: 117,
                      green: _green,
                      muted: _muted,
                      hintColor: _hint,
                    ),
                    const SizedBox(height: 24),
                    ProposeActivityLocationField(
                      controller: _locationCtrl,
                      focusNode: _locationFocus,
                      green: _green,
                      muted: _muted,
                      hintColor: _hint,
                    ),
                    const SizedBox(height: 18),
                    _buildDateTimeRow(context),
                    const SizedBox(height: 24),
                    ProposeActivityBottomButtons(
                      onCancel: () => Navigator.pop(context),
                      onSubmit: () => Navigator.pop(context),
                      green: _green,
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

  Widget _buildDateTimeRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerField(
            context: context,
            label: 'Ngày *',
            labelIcon: Icons.calendar_month_outlined,
            value: _date == null ? 'dd/mm/yyyy' : _formatDate(_date!),
            isPlaceholder: _date == null,
            trailingIcon: Icons.calendar_month_outlined,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _date ?? now,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 5),
              );
              if (picked == null) return;
              setState(() => _date = picked);
            },
          ),
        ),
        const SizedBox(width: 19),
        Expanded(
          child: _buildPickerField(
            context: context,
            label: 'Giờ *',
            labelIcon: Icons.access_time,
            value: _time == null ? '--:--:--' : _formatTime(_time!),
            isPlaceholder: _time == null,
            trailingIcon: Icons.access_time,
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time ?? TimeOfDay.now(),
              );
              if (picked == null) return;
              setState(() => _time = picked);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required BuildContext context,
    required String label,
    required IconData labelIcon,
    required String value,
    required bool isPlaceholder,
    required IconData trailingIcon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(labelIcon, size: 24, color: Colors.black),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _muted.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: isPlaceholder ? _hint : Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(trailingIcon, size: 20, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd/$mm/$yyyy';
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }
}
