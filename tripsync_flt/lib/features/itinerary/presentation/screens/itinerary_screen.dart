import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'propose_activity_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../shared/widgets/add_floating_button.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/trip_bottom_navigation.dart';
import '../../../../shared/widgets/trip_header.dart';
import '../../../home/presentation/widgets/member_avatar.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/presentation/services/trip_list_loader.dart';
import 'trip_member_management_screen.dart';

part '../widgets/itinerary_screen_widgets.dart';

class TripItineraryScreen extends StatefulWidget {
  final Trip trip;

  const TripItineraryScreen({super.key, required this.trip});

  @override
  State<TripItineraryScreen> createState() => _TripItineraryScreenState();
}

class _TripItineraryScreenState extends State<TripItineraryScreen> {
  late int _memberCount;
  late List<String> _memberAvatarUrls;
  bool _membersChanged = false;
  int _selectedDayIndex = 0;

  final Set<int> _busyActivityIds = <int>{};

  late final ApiClient _apiClient;
  Future<_DayActivities>? _activitiesFuture;

  Trip get trip => widget.trip;

  @override
  void initState() {
    super.initState();
    _memberCount = widget.trip.memberCount;
    _memberAvatarUrls = List<String>.from(widget.trip.memberAvatarUrls);
    _applyMembersSnapshotIfAny();

    _apiClient = ApiClient(authTokenProvider: AuthTokenStore.getAccessToken);
    _activitiesFuture = _loadActivitiesForSelectedDay();
  }

  @override
  void didUpdateWidget(covariant TripItineraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.id != widget.trip.id) {
      _selectedDayIndex = 0;
      _activitiesFuture = _loadActivitiesForSelectedDay();
    }
  }

  void _applyMembersSnapshotIfAny() {
    final tripId = widget.trip.id;
    if (tripId == null) return;
    final cachedCount = TripListLoader.getCachedMemberCount(tripId);
    final cachedUrls = TripListLoader.getCachedMemberAvatarUrls(tripId);
    if (cachedCount == null && cachedUrls == null) return;

    setState(() {
      if (cachedCount != null) _memberCount = cachedCount;
      if (cachedUrls != null) {
        _memberAvatarUrls = List<String>.from(cachedUrls);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_membersChanged);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              TripHeader(
                title: widget.trip.title,
                location: widget.trip.location,
                onBackPressed: () => Navigator.of(context).pop(_membersChanged),
                onSettingsPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) =>
                          TripMemberManagementScreen(trip: widget.trip),
                    ),
                  );
                  if (changed == true) {
                    _membersChanged = true;
                    _applyMembersSnapshotIfAny();
                  }
                },
              ),

              // Trip Image and Info
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      _buildTripImageCard(),
                      const SizedBox(height: 12),
                      _buildMemberAndDateCard(
                        memberCount: _memberCount,
                        avatarUrls: _memberAvatarUrls,
                      ),
                      const SizedBox(height: 12),
                      _buildStatsSection(),
                      const SizedBox(height: 12),
                      _buildActionButtons(context),
                      const SizedBox(height: 12),
                      _buildDaySelector(),
                      const SizedBox(height: 8),
                      _buildItinerarySections(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation
              const TripBottomNavigation(currentIndex: 0),
            ],
          ),
        ),
        floatingActionButton: AddFloatingButton(
          onPressed: () async {
            final tripId = trip.id;
            if (tripId == null) return;

            final createdDayNumber = await Navigator.of(context).push<int>(
              MaterialPageRoute(
                builder: (_) => ProposeActivityScreen(
                  tripId: tripId,
                  initialDayNumber: _selectedDayIndex + 1,
                  tripStartDate: _tryParseDate(trip.startDate),
                  tripEndDate: _tryParseDate(trip.endDate),
                ),
              ),
            );
            if (createdDayNumber == null) return;

            setState(() {
              _selectedDayIndex = max(0, createdDayNumber - 1);
              _activitiesFuture = _loadActivitiesForSelectedDay();
            });
          },
        ),
      ),
    );
  }

  Widget _buildTripImageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCoverImage(trip.imageUrl),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 220 * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/location.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontFamily: 'Poppins',
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
        ),
      ),
    );
  }

  Widget _buildCoverImage(String rawUrl) {
    final url = _coerceCoverUrl(rawUrl);
    final placeholder = Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.image, size: 50),
    );

    if (url.isEmpty) return placeholder;

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    if (kIsWeb) return placeholder;

    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }

  String _coerceCoverUrl(String raw) {
    var value = raw.trim();
    if (value.isEmpty) return value;

    if (value.startsWith('assets/')) {
      final rest = value.substring('assets/'.length);
      if (_looksLikeEncodedHttpUrl(rest)) value = rest;
    }

    for (var i = 0; i < 2; i++) {
      if (!_looksLikeEncodedHttpUrl(value)) break;
      try {
        value = Uri.decodeFull(value).trim();
      } catch (_) {
        break;
      }
    }

    return value;
  }

  bool _looksLikeEncodedHttpUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http%3a') ||
        lower.startsWith('https%3a') ||
        lower.startsWith('http%253a') ||
        lower.startsWith('https%253a');
  }

  Widget _buildMemberAndDateCard({
    required int memberCount,
    required List<String> avatarUrls,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildAvatarStack(
                    memberCount: memberCount,
                    avatarUrls: avatarUrls,
                  ),
                  Text(
                    '$memberCount thành viên',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 32, color: AppColors.divider),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildDateRow('assets/icons/celendar.png', trip.startDate),
                const SizedBox(height: 4),
                _buildDateRow('assets/icons/celendar.png', trip.endDate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack({
    required int memberCount,
    required List<String> avatarUrls,
  }) {
    final normalizedAvatarUrls = avatarUrls
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final colors = trip.memberColors
        .map((hex) => Color(int.parse(hex.replaceFirst('#', '0xFF'))))
        .toList(growable: false);

    const maxShown = 3; // Match Home TripCard.
    final effectiveMemberCount = memberCount < 0 ? 0 : memberCount;

    final avatars = <Widget>[];

    if (normalizedAvatarUrls.isNotEmpty) {
      var shownCount = maxShown;
      if (effectiveMemberCount < shownCount) shownCount = effectiveMemberCount;
      if (normalizedAvatarUrls.length < shownCount) {
        shownCount = normalizedAvatarUrls.length;
      }

      final shownUrls = normalizedAvatarUrls
          .take(shownCount)
          .toList(growable: false);
      for (final url in shownUrls) {
        avatars.add(
          MemberAvatar(color: Colors.grey.shade300, imageUrl: url, size: 25),
        );
      }

      final overflow = effectiveMemberCount - shownUrls.length;
      if (overflow > 0) {
        avatars.add(_buildOverflowAvatar(overflow));
      }

      return Row(mainAxisSize: MainAxisSize.min, children: avatars);
    }

    var shownCount = maxShown;
    if (effectiveMemberCount < shownCount) shownCount = effectiveMemberCount;
    if (colors.length < shownCount) shownCount = colors.length;

    final shownColors = colors.take(shownCount).toList(growable: false);
    for (final color in shownColors) {
      avatars.add(MemberAvatar(color: color, size: 25));
    }

    final overflow = effectiveMemberCount - shownColors.length;
    if (overflow > 0) {
      avatars.add(_buildOverflowAvatar(overflow));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: avatars);
  }

  Widget _buildOverflowAvatar(int overflow) {
    return Container(
      width: 25,
      height: 25,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade500,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$overflow',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _buildDateRow(String iconAsset, String dateText) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconAsset,
          width: 14,
          height: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final future =
        _activitiesFuture ??
        (_activitiesFuture = _loadActivitiesForSelectedDay());

    return _ItineraryStatsSection(
      future: future,
      dayNumber: _selectedDayIndex + 1,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final tripId = trip.id;
                if (tripId == null) return;

                final createdDayNumber = await Navigator.of(context).push<int>(
                  MaterialPageRoute(
                    builder: (_) => ProposeActivityScreen(
                      tripId: tripId,
                      initialDayNumber: _selectedDayIndex + 1,
                      tripStartDate: _tryParseDate(trip.startDate),
                      tripEndDate: _tryParseDate(trip.endDate),
                    ),
                  ),
                );
                if (createdDayNumber == null) return;

                setState(() {
                  _selectedDayIndex = max(0, createdDayNumber - 1);
                  _activitiesFuture = _loadActivitiesForSelectedDay();
                });
              },
              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ).copyWith(
                    shadowColor: WidgetStatePropertyAll(
                      AppColors.primary.withValues(alpha: 0.30),
                    ),
                  ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Thêm đề xuất hoạt động',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF3F4F6)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.map_outlined,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = _buildDayItems();
    if (_selectedDayIndex >= days.length) {
      _selectedDayIndex = days.isEmpty ? 0 : (days.length - 1);
    }

    return _ItineraryDaySelector(
      days: days,
      selectedIndex: _selectedDayIndex,
      onSelected: (index) {
        if (_selectedDayIndex == index) return;
        setState(() {
          _selectedDayIndex = index;
          _activitiesFuture = _loadActivitiesForSelectedDay();
        });
      },
    );
  }

  List<Map<String, String>> _buildDayItems() {
    final count = _safeDayCount();
    if (count <= 0) {
      return <Map<String, String>>[
        {'label': 'Ngày 1', 'date': _toShortDate(trip.startDate)},
      ];
    }

    final start = _tryParseDate(trip.startDate);
    return List<Map<String, String>>.generate(count, (index) {
      final label = 'Ngày ${index + 1}';
      final date = (start != null)
          ? _formatDdMm(start.add(Duration(days: index)))
          : _toShortDate(trip.startDate);
      return {'label': label, 'date': date};
    }, growable: false);
  }

  int _safeDayCount() {
    final v = trip.daysCount;
    if (v > 0) return v;

    final start = _tryParseDate(trip.startDate);
    final end = _tryParseDate(trip.endDate);
    if (start == null || end == null) return 1;
    final diff = end.difference(start).inDays;
    return diff >= 0 ? diff + 1 : 1;
  }

  DateTime? _tryParseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // ISO-like
    try {
      return DateTime.parse(s);
    } catch (_) {
      // continue
    }

    // dd/MM/yyyy or dd/MM
    final parts = s.split('/');
    if (parts.length >= 2) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = (parts.length >= 3) ? int.tryParse(parts[2]) : null;
      if (day != null && month != null) {
        final y = year ?? DateTime.now().year;
        return DateTime(y, month, day);
      }
    }

    return null;
  }

  String _formatDdMm(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  String _toShortDate(String raw) {
    final value = raw.trim();
    if (value.length >= 10 && value[2] == '/' && value[5] == '/') {
      return value.substring(0, 5);
    }
    if (value.length >= 5 && value.length > 2 && value[2] == '/') {
      return value.substring(0, 5);
    }
    return value;
  }

  Future<_DayActivities> _loadActivitiesForSelectedDay() async {
    final tripId = trip.id;
    if (tripId == null) return const _DayActivities.empty();

    final dayNumber = _selectedDayIndex + 1;
    final res = await _apiClient.get<dynamic>(
      ApiEndpoints.itineraryActivitiesByDay(
        tripId: tripId,
        dayNumber: dayNumber,
      ),
    );

    final raw = res.data;
    if (raw is! Map) return const _DayActivities.empty();

    final data = raw['data'];
    final payload = _extractActivitiesPayload(data);

    final confirmed = <_ActivityItem>[];
    final proposed = <_ActivityItem>[];

    for (final item in payload.items) {
      final a = _ActivityItem.fromJson(item);
      if (a == null) continue;
      (a.isConfirmed ? confirmed : proposed).add(a);
    }

    for (final item in payload.confirmed) {
      final a = _ActivityItem.fromJson(item, forceConfirmed: true);
      if (a != null) confirmed.add(a);
    }

    for (final item in payload.proposed) {
      final a = _ActivityItem.fromJson(item, forceConfirmed: false);
      if (a != null) proposed.add(a);
    }

    return _DayActivities(confirmed: confirmed, proposed: proposed);
  }

  bool _isBusyActivity(int activityId) => _busyActivityIds.contains(activityId);

  String _voteRatioText(_ActivityItem activity, int memberCount) {
    if (memberCount > 0) {
      final up = activity.upvotes ?? 0;
      return '$up/$memberCount đồng ý';
    }
    return activity.ratioText;
  }

  Future<void> _voteActivity(int activityId, String voteType) async {
    if (_isBusyActivity(activityId)) return;
    setState(() => _busyActivityIds.add(activityId));
    try {
      await _apiClient.post<dynamic>(
        ApiEndpoints.itineraryVoteActivity(activityId),
        queryParameters: <String, dynamic>{'vote_type': voteType},
      );
      if (!mounted) return;
      setState(() {
        _activitiesFuture = _loadActivitiesForSelectedDay();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;
      setState(() => _busyActivityIds.remove(activityId));
    }
  }

  Future<void> _confirmActivity(int activityId) async {
    if (_isBusyActivity(activityId)) return;
    setState(() => _busyActivityIds.add(activityId));
    try {
      await _apiClient.post<dynamic>(
        ApiEndpoints.itineraryConfirmActivity(activityId),
      );
      if (!mounted) return;
      setState(() {
        _activitiesFuture = _loadActivitiesForSelectedDay();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (!mounted) return;
      setState(() => _busyActivityIds.remove(activityId));
    }
  }

  _ActivitiesPayload _extractActivitiesPayload(dynamic data) {
    if (data is List) {
      return _ActivitiesPayload(items: data);
    }

    if (data is Map) {
      final confirmed = data['confirmed'];
      final proposed = data['proposed'];
      if (confirmed is List || proposed is List) {
        return _ActivitiesPayload(
          items: const [],
          confirmed: (confirmed is List) ? confirmed : const [],
          proposed: (proposed is List) ? proposed : const [],
        );
      }

      final activities =
          data['activities'] ??
          data['items'] ??
          data['results'] ??
          data['data'];
      if (activities is List) {
        return _ActivitiesPayload(items: activities);
      }
    }

    return const _ActivitiesPayload(items: []);
  }

  Widget _buildItinerarySections() {
    final future =
        _activitiesFuture ??
        (_activitiesFuture = _loadActivitiesForSelectedDay());

    return _ItinerarySections(
      tripId: trip.id,
      future: future,
      memberCount: _memberCount,
      isBusy: _isBusyActivity,
      ratioText: (a) => _voteRatioText(a, _memberCount),
      onVote: _voteActivity,
      onConfirm: _confirmActivity,
    );
  }

  // Old per-day activity list UI removed in favor of the Figma layout.
}

typedef _IsBusyFn = bool Function(int activityId);
typedef _VoteRatioTextFn = String Function(_ActivityItem activity);
typedef _VoteFn = Future<void> Function(int activityId, String voteType);
typedef _ConfirmFn = Future<void> Function(int activityId);

class _DayActivities {
  final List<_ActivityItem> confirmed;
  final List<_ActivityItem> proposed;

  const _DayActivities({required this.confirmed, required this.proposed});

  const _DayActivities.empty() : confirmed = const [], proposed = const [];
}

class _ActivitiesPayload {
  final List<dynamic> items;
  final List<dynamic> confirmed;
  final List<dynamic> proposed;

  const _ActivitiesPayload({
    required this.items,
    this.confirmed = const [],
    this.proposed = const [],
  });
}

class _ActivityItem {
  final int? id;
  final String title;
  final String subtitle;
  final String location;
  final String timeText;
  final String proposedBy;
  final bool isConfirmed;
  final int? upvotes;
  final int? totalVotes;
  final String? myVote;

  const _ActivityItem({
    this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.timeText,
    required this.proposedBy,
    required this.isConfirmed,
    this.upvotes,
    this.totalVotes,
    this.myVote,
  });

  String get likesText {
    final v = upvotes;
    if (v == null) return '';
    return '$v người thích';
  }

  String get ratioText {
    final up = upvotes;
    final total = totalVotes;
    if (up != null && total != null && total > 0) return '$up/$total đồng ý';
    if (up != null) return '$up người đồng ý';
    return 'Chưa có lượt bình chọn';
  }

  static _ActivityItem? fromJson(dynamic raw, {bool? forceConfirmed}) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw as Map);

    String pickString(List<String> keys) {
      for (final k in keys) {
        final v = m[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return '';
    }

    int? pickInt(List<String> keys) {
      for (final k in keys) {
        final v = m[k];
        if (v == null) continue;
        if (v is int) return v;
        final parsed = int.tryParse(v.toString());
        if (parsed != null) return parsed;
      }
      return null;
    }

    bool pickBool(List<String> keys) {
      for (final k in keys) {
        final v = m[k];
        if (v == null) continue;
        if (v is bool) return v;
        final s = v.toString().toLowerCase();
        if (s == 'true') return true;
        if (s == 'false') return false;
      }
      return false;
    }

    String timeText = pickString(['time', 'start_time', 'startTime']);
    final endTime = pickString(['end_time', 'endTime']);
    if (timeText.isNotEmpty && endTime.isNotEmpty) {
      timeText = '$timeText - $endTime';
    }

    final title = pickString(['title', 'name']);
    final subtitle = pickString(['description', 'subtitle', 'note']);
    final location = pickString(['location', 'address', 'place']);

    final createdBy = m['created_by'] ?? m['createdBy'] ?? m['creator'];
    String proposedBy = '';
    if (createdBy is Map) {
      final cm = Map<String, dynamic>.from(createdBy);
      proposedBy = (cm['name'] ?? cm['full_name'] ?? cm['email'] ?? '')
          .toString()
          .trim();
    }
    if (proposedBy.isEmpty) {
      proposedBy = pickString([
        'created_by_name',
        'createdByName',
        'proposed_by',
      ]);
    }

    final status = pickString(['status', 'state']).toLowerCase();
    final isConfirmed =
        forceConfirmed ??
        pickBool(['is_confirmed', 'confirmed', 'isConfirmed']) ||
            status == 'confirmed';

    final id = pickInt(['id', 'activity_id', 'activityId']);

    final upvotes = pickInt(['upvotes', 'likes', 'like_count', 'upvote_count']);
    final totalVotes = pickInt(['total_votes', 'votes', 'vote_count']);
    final myVote = pickString(['my_vote', 'myVote']);

    return _ActivityItem(
      id: id,
      title: title.isEmpty ? 'Hoạt động' : title,
      subtitle: subtitle,
      location: location,
      timeText: timeText,
      proposedBy: proposedBy,
      isConfirmed: isConfirmed,
      upvotes: upvotes,
      totalVotes: totalVotes,
      myVote: myVote.isEmpty ? null : myVote,
    );
  }
}
