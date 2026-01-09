import 'package:flutter/material.dart';
import '../widgets/propose_activity_widgets.dart';
import '../widgets/propose_activity_form_widgets.dart';
import 'choose_location_screen.dart';
import '../models/picked_location.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/auth_token_store.dart';

class ProposeActivityScreen extends StatefulWidget {
  final int tripId;
  final int initialDayNumber;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;

  const ProposeActivityScreen({
    super.key,
    required this.tripId,
    required this.initialDayNumber,
    this.tripStartDate,
    this.tripEndDate,
  });

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

  PickedLocation? _pickedLocation;

  late final ApiClient _apiClient;
  bool _submitting = false;

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
  void initState() {
    super.initState();
    _apiClient = ApiClient(authTokenProvider: AuthTokenStore.getAccessToken);

    // Prefill date based on the currently selected day (if we can infer it).
    final start = widget.tripStartDate;
    final end = widget.tripEndDate;
    if (start != null) {
      var offsetDays = ((widget.initialDayNumber - 1).clamp(0, 3650)).toInt();

      if (end != null) {
        final maxOffset = end.difference(_dateOnly(start)).inDays;
        if (maxOffset >= 0) {
          if (offsetDays < 0) offsetDays = 0;
          if (offsetDays > maxOffset) offsetDays = maxOffset;
        }
      }

      _date = _dateOnly(start).add(Duration(days: offsetDays));
    }
  }

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
        child: ProposeActivityBody(
          green: _green,
          surface: _surface,
          muted: _muted,
          hint: _hint,
          types: _types,
          selectedTypeIndex: _selectedTypeIndex,
          onSelectType: (index) => setState(() => _selectedTypeIndex = index),
          nameController: _nameCtrl,
          nameFocusNode: _nameFocus,
          descriptionController: _descriptionCtrl,
          descriptionFocusNode: _descriptionFocus,
          locationController: _locationCtrl,
          locationFocusNode: _locationFocus,
          dateText: _date == null ? 'dd/mm/yyyy' : _formatDate(_date!),
          isDatePlaceholder: _date == null,
          timeText: _time == null ? '--:--:--' : _formatTime(_time!),
          isTimePlaceholder: _time == null,
          onPickDate: _pickDate,
          onPickTime: _pickTime,
          onPickLocation: _pickLocation,
          onCancel: () => Navigator.pop(context),
          onSubmit: _submitting ? null : _handleSubmit,
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final selected = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const ChooseLocationScreen()),
    );
    if (selected == null) return;
    setState(() {
      _pickedLocation = selected;
      _locationCtrl.text = selected.label;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final start = widget.tripStartDate;
    final end = widget.tripEndDate;

    // Constrain to the trip duration if available.
    final firstDate = start != null ? _dateOnly(start) : DateTime(now.year - 5);
    final lastDate = end != null ? _dateOnly(end) : DateTime(now.year + 5);

    final effectiveFirst = lastDate.isBefore(firstDate) ? lastDate : firstDate;
    final effectiveLast = lastDate.isBefore(firstDate) ? firstDate : lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: (_date != null)
          ? _dateOnly(_date!)
          : (start != null ? _dateOnly(start) : now),
      firstDate: effectiveFirst,
      lastDate: effectiveLast,
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày trước.')),
      );
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => _time = picked);
  }

  void _handleSubmit() {
    _submit();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final title = _nameCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final locationText = _locationCtrl.text.trim();
    final selectedTime = _time;

    void showError(String message) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    if (title.isEmpty) {
      showError('Vui lòng nhập tên hoạt động.');
      return;
    }
    if (description.isEmpty) {
      showError('Vui lòng nhập mô tả.');
      return;
    }
    if (locationText.isEmpty) {
      showError('Vui lòng chọn địa điểm.');
      return;
    }

    final picked = _pickedLocation;
    if (picked == null || picked.label.trim().isEmpty) {
      showError('Vui lòng bấm “Chọn địa điểm” để lấy tọa độ.');
      return;
    }
    if (picked.label.trim() != locationText) {
      showError('Địa điểm đã thay đổi. Vui lòng chọn lại để lấy tọa độ.');
      return;
    }
    if (selectedTime == null) {
      showError('Vui lòng chọn giờ.');
      return;
    }

    final targetDayNumber = _resolveTargetDayNumber();

    if (!_isDayNumberInTripRange(targetDayNumber)) {
      showError('Ngày chọn phải nằm trong thời gian chuyến đi.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final dayRes = await _apiClient.post<dynamic>(
        ApiEndpoints.itineraryCreateDay,
        queryParameters: <String, dynamic>{
          'trip_id': widget.tripId,
          'day_number': targetDayNumber,
        },
      );

      final dayId = _extractDayId(dayRes.data);
      if (dayId == null) {
        throw Exception('Không lấy được day_id từ server.');
      }

      await _apiClient.post<dynamic>(
        ApiEndpoints.itineraryActivities,
        data: <String, dynamic>{
          'day_id': dayId,
          'title': title,
          'category': _types[_selectedTypeIndex].label,
          'description': description,
          'location': locationText,
          'location_lat': picked.latitude.toString(),
          'location_long': picked.longitude.toString(),
          'start_time': _formatTime(selectedTime),
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop<int>(targetDayNumber);
    } catch (e) {
      showError(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  int _resolveTargetDayNumber() {
    final start = widget.tripStartDate;
    final selectedDate = _date;
    if (start == null || selectedDate == null) return widget.initialDayNumber;

    final diffDays = _dateOnly(
      selectedDate,
    ).difference(_dateOnly(start)).inDays;
    final day = diffDays + 1;
    if (day <= 0) return widget.initialDayNumber;
    return day;
  }

  bool _isDayNumberInTripRange(int dayNumber) {
    final start = widget.tripStartDate;
    final end = widget.tripEndDate;
    if (start == null || end == null) return true; // best-effort
    final totalDays = end.difference(_dateOnly(start)).inDays + 1;
    if (totalDays <= 0) return true;
    return dayNumber >= 1 && dayNumber <= totalDays;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int? _extractDayId(dynamic raw) {
    if (raw is! Map) return null;
    final data = raw['data'];
    if (data is! Map) return null;
    final id = data['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return null;
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
