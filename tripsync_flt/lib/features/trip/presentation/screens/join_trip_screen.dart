import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../core/network/exceptions.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/repositories/trip_repository.dart';
import '../widgets/joinTrip/join_trip_header.dart';
import '../widgets/joinTrip/invite_code_input.dart';
import '../widgets/joinTrip/join_trip_actions.dart';

class JoinTripScreen extends StatefulWidget {
  const JoinTripScreen({super.key});

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();

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
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _handleJoin() {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) return;
    _joinTrip(inviteCode);
  }

  Future<void> _joinTrip(String inviteCode) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final raw = await _tripRepository.joinTrip(inviteCode: inviteCode);

      DateTime? endDate = _extractTripEndDate(raw);
      endDate ??= await _fetchEndDateByInviteCode(inviteCode);

      if (endDate != null && _isExpired(endDate)) {
        if (mounted) {
          showTopToast(
            context,
            message: 'Chuyến đi đã hết hạn',
            type: TopToastType.error,
          );
        }
        return;
      }

      final message =
          (raw['message'] ?? raw['detail'] ?? 'Tham gia chuyến đi thành công')
              .toString();

      if (mounted) {
        showTopToast(context, message: message, type: TopToastType.success);
      }

      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        final msg = switch (e) {
          TimeoutException() => 'Server đang khởi động, thử lại sau vài giây',
          UnauthorizedException() => 'Vui lòng đăng nhập để tham gia chuyến đi',
          _ => e.message,
        };
        showTopToast(context, message: msg, type: TopToastType.error);
      }
    } catch (e) {
      if (mounted) {
        showTopToast(
          context,
          message: 'Tham gia chuyến đi thất bại: $e',
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

  Future<DateTime?> _fetchEndDateByInviteCode(String inviteCode) async {
    try {
      final raw = await _tripRepository.listTrips();
      final data = raw['data'];
      if (data is! List) return null;

      for (final item in data) {
        if (item is! Map) continue;
        final json = Map<String, dynamic>.from(item);
        final code = (json['invite_code'] ?? '').toString().trim();
        if (code == inviteCode) {
          final end = (json['end_date'] ?? '').toString();
          return _tryParseIsoDate(end);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  DateTime? _extractTripEndDate(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is! Map) return null;
    final end = (data)['end_date'];
    if (end == null) return null;
    return _tryParseIsoDate(end.toString());
  }

  DateTime? _tryParseIsoDate(String value) {
    // Backend uses date (yyyy-MM-dd). We only care about date part.
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  bool _isExpired(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(128),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 24,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(false),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(LucideIcons.x, size: 24),
                ),
              ),
              const SizedBox(height: 30),

              const JoinTripHeader(),
              const SizedBox(height: 30),

              InviteCodeInput(controller: _inviteCodeController),
              const SizedBox(height: 30),

              JoinTripActions(
                onCancel: () => Navigator.of(context).pop(false),
                onJoin: _handleJoin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showJoinTripDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withAlpha(128),
    builder: (context) => const JoinTripScreen(),
  );
}
