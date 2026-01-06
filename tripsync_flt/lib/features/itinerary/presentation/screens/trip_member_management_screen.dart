import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_token_store.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../widgets/add_member_row.dart';
import '../widgets/member_row.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../trip/data/datasources/trip_remote_data_source.dart';
import '../../../trip/data/repositories/trip_repository_impl.dart';
import '../../../trip/domain/entities/trip.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../../trip/presentation/services/trip_list_loader.dart';

part '../widgets/trip_member_management_screen_widgets.dart';

class TripMemberManagementScreen extends StatefulWidget {
  final Trip trip;

  const TripMemberManagementScreen({super.key, required this.trip});

  @override
  State<TripMemberManagementScreen> createState() =>
      _TripMemberManagementScreenState();
}

class _TripMemberManagementScreenState
    extends State<TripMemberManagementScreen> {
  late final TripRepository _tripRepository;
  late final AuthRepository _authRepository;
  late Future<List<MemberRowModel>> _membersFuture;

  bool _membersChanged = false;

  String _myRoleText = 'Thành viên';

  final TextEditingController _addMemberEmailController =
      TextEditingController();
  bool _isAddingMember = false;

  @override
  void initState() {
    super.initState();
    _tripRepository = TripRepositoryImpl(
      TripRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );

    _authRepository = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(
        ApiClient(authTokenProvider: AuthTokenStore.getAccessToken),
      ),
    );

    _membersFuture = _loadMembers();
  }

  @override
  void dispose() {
    _addMemberEmailController.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    final at = v.indexOf('@');
    if (at <= 0) return false;
    final dot = v.lastIndexOf('.');
    if (dot <= at + 1) return false;
    if (dot >= v.length - 1) return false;
    return true;
  }

  void _showSuccess(String message) {
    final m = message.trim();
    if (m.isEmpty) return;
    showTopToast(context, message: m, type: TopToastType.success);
  }

  void _showError(String message) {
    final m = message.trim();
    if (m.isEmpty) return;
    showTopToast(context, message: m, type: TopToastType.error);
  }

  Future<void> _addMemberByEmail() async {
    if (_isAddingMember) return;
    final tripId = widget.trip.id;
    if (tripId == null) return;

    final email = _addMemberEmailController.text.trim();
    if (!_looksLikeEmail(email)) {
      _showError('Vui lòng nhập email hợp lệ.');
      return;
    }

    setState(() => _isAddingMember = true);
    try {
      TripListLoader.invalidateMembersCache(tripId: tripId);
      final raw = await _tripRepository.addTripMember(
        tripId: tripId,
        userEmail: email,
      );

      final msg = (raw['message'] ?? '').toString().trim();
      if (msg.isNotEmpty) {
        _showSuccess(msg);
      } else {
        _showSuccess('Đã thêm thành viên.');
      }

      _addMemberEmailController.clear();
      _membersChanged = true;
      if (mounted) {
        setState(() {
          _membersFuture = _loadMembers();
        });
      }
    } catch (_) {
      _showError('Không thể thêm thành viên.');
    } finally {
      if (mounted) {
        setState(() => _isAddingMember = false);
      }
    }
  }

  Future<List<MemberRowModel>> _loadMembers() async {
    final tripId = widget.trip.id;
    if (tripId == null) return const <MemberRowModel>[];

    final creator = await _loadTripCreator(tripId);
    final me = await _loadMeIdentity();

    final raw = await _tripRepository.listTripMembers(tripId: tripId);
    final members = _extractMembersFromMembersResponse(raw);

    final colors = widget.trip.memberColors
        .map((hex) => Color(int.parse(hex.replaceFirst('#', '0xFF'))))
        .toList(growable: false);

    Color colorAt(int index) {
      if (colors.isEmpty) return AppColors.iconBackground;
      return colors[index % colors.length];
    }

    var myIsLeader = _matchesMeToCreator(me: me, creator: creator);

    final out = <MemberRowModel>[];
    for (var i = 0; i < members.length; i++) {
      final m = members[i];
      final userMap = _extractNestedUser(m);

      final isActive = _extractIsActive(m, userMap);

      final isLeader =
          _isLeader(m, userMap) ||
          _matchesTripCreator(creator: creator, member: m, user: userMap);

      if (!myIsLeader && _matchesMeToMember(me: me, member: m, user: userMap)) {
        myIsLeader = isLeader;
      }

      final name = _extractDisplayName(m, userMap) ?? 'Thành viên';
      final contact = _extractSubtitle(m, userMap);
      final subtitle = contact ?? (isLeader ? '' : 'Thành viên');

      out.add(
        MemberRowModel(
          name: name,
          subtitle: subtitle,
          avatarUrl: _extractAvatarUrl(m, userMap),
          fallbackColor: colorAt(i),
          isLeader: isLeader,
          roleBadgeText: isLeader ? 'Trưởng nhóm' : null,
          isActive: isActive,
        ),
      );
    }

    TripListLoader.setMembersSnapshot(
      tripId: tripId,
      memberCount: members.length,
      avatarUrls: out
          .map((m) => (m.avatarUrl ?? '').trim())
          .where((u) => u.isNotEmpty)
          .take(5)
          .toList(growable: false),
    );

    final nextRoleText = myIsLeader ? 'Trưởng nhóm' : 'Thành viên';
    if (mounted && nextRoleText != _myRoleText) {
      setState(() => _myRoleText = nextRoleText);
    }

    return out;
  }

  Future<_MeIdentity> _loadMeIdentity() async {
    try {
      final raw = await _authRepository.me();
      return _extractMeIdentity(raw);
    } catch (_) {
      return const _MeIdentity();
    }
  }

  static _MeIdentity _extractMeIdentity(Map<String, dynamic> raw) {
    final data = raw['data'];

    Map<String, dynamic>? me;
    if (data is Map<String, dynamic>) {
      me = data;
    } else if (data is Map) {
      me = Map<String, dynamic>.from(data);
    }

    final id = _parseId(
      me?['id'] ??
          me?['user_id'] ??
          me?['userId'] ??
          raw['id'] ??
          raw['user_id'] ??
          raw['userId'],
    );

    final email = _parseString(me?['email'] ?? raw['email']);

    return _MeIdentity(id: id, email: email);
  }

  static bool _matchesMeToCreator({
    required _MeIdentity me,
    required _TripCreator creator,
  }) {
    if (me.id == null && (me.email == null || me.email!.isEmpty)) return false;

    if (me.id != null && creator.id != null) {
      return me.id == creator.id;
    }

    final mEmail = me.email?.trim().toLowerCase();
    final cEmail = creator.email?.trim().toLowerCase();
    if (mEmail != null &&
        mEmail.isNotEmpty &&
        cEmail != null &&
        cEmail.isNotEmpty) {
      return mEmail == cEmail;
    }

    return false;
  }

  static bool _matchesMeToMember({
    required _MeIdentity me,
    required Map<String, dynamic> member,
    required Map<String, dynamic>? user,
  }) {
    if (me.id == null && (me.email == null || me.email!.isEmpty)) return false;

    final memberUserId = _parseId(
      member['user_id'] ??
          member['userId'] ??
          user?['id'] ??
          user?['user_id'] ??
          user?['userId'] ??
          member['id'],
    );

    if (me.id != null && memberUserId != null) {
      return me.id == memberUserId;
    }

    final memberEmail = _parseString(
      member['email'] ??
          user?['email'] ??
          member['user_email'] ??
          member['userEmail'],
    );

    final mEmail = me.email?.trim().toLowerCase();
    final otherEmail = memberEmail?.trim().toLowerCase();
    if (mEmail != null &&
        mEmail.isNotEmpty &&
        otherEmail != null &&
        otherEmail.isNotEmpty) {
      return mEmail == otherEmail;
    }

    return false;
  }

  Future<_TripCreator> _loadTripCreator(int tripId) async {
    try {
      final raw = await _tripRepository.getTripDetail(tripId: tripId);
      return _extractTripCreator(raw);
    } catch (_) {
      return const _TripCreator();
    }
  }

  static _TripCreator _extractTripCreator(Map<String, dynamic> raw) {
    final data = raw['data'];

    Map<String, dynamic>? trip;
    if (data is Map<String, dynamic>) {
      trip = data;
    } else if (data is Map) {
      trip = Map<String, dynamic>.from(data);
    }

    final nested = trip?['trip'];
    if (nested is Map<String, dynamic>) {
      trip = nested;
    } else if (nested is Map) {
      trip = Map<String, dynamic>.from(nested);
    }

    if (trip == null) return const _TripCreator();

    final id = _parseId(
      trip['created_by_id'] ??
          trip['createdById'] ??
          trip['creator_id'] ??
          trip['creatorId'] ??
          trip['owner_id'] ??
          trip['ownerId'] ??
          (trip['created_by'] is Map
              ? (trip['created_by'] as Map)['id']
              : null) ??
          (trip['createdBy'] is Map
              ? (trip['createdBy'] as Map)['id']
              : null) ??
          (trip['creator'] is Map ? (trip['creator'] as Map)['id'] : null) ??
          (trip['owner'] is Map ? (trip['owner'] as Map)['id'] : null),
    );

    final email = _parseString(
      trip['created_by_email'] ??
          trip['createdByEmail'] ??
          trip['creator_email'] ??
          trip['creatorEmail'] ??
          trip['owner_email'] ??
          trip['ownerEmail'] ??
          (trip['created_by'] is Map
              ? (trip['created_by'] as Map)['email']
              : null) ??
          (trip['createdBy'] is Map
              ? (trip['createdBy'] as Map)['email']
              : null) ??
          (trip['creator'] is Map ? (trip['creator'] as Map)['email'] : null) ??
          (trip['owner'] is Map ? (trip['owner'] as Map)['email'] : null),
    );

    return _TripCreator(id: id, email: email);
  }

  static bool _matchesTripCreator({
    required _TripCreator creator,
    required Map<String, dynamic> member,
    required Map<String, dynamic>? user,
  }) {
    if (creator.id == null &&
        (creator.email == null || creator.email!.isEmpty)) {
      return false;
    }

    final memberUserId = _parseId(
      member['user_id'] ??
          member['userId'] ??
          member['created_by_id'] ??
          member['createdById'] ??
          user?['id'] ??
          user?['user_id'] ??
          user?['userId'] ??
          member['id'],
    );

    if (creator.id != null && memberUserId != null) {
      return creator.id == memberUserId;
    }

    final memberEmail = _parseString(
      member['email'] ??
          user?['email'] ??
          member['user_email'] ??
          member['userEmail'],
    );

    final cEmail = creator.email?.trim().toLowerCase();
    final mEmail = memberEmail?.trim().toLowerCase();
    if (cEmail != null &&
        cEmail.isNotEmpty &&
        mEmail != null &&
        mEmail.isNotEmpty) {
      return cEmail == mEmail;
    }

    return false;
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return int.tryParse(s);
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_membersChanged);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  title: 'Quản lý thành viên',
                  onBack: () => Navigator.of(context).pop(_membersChanged),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TripInviteCard(
                      code: _buildTripCode(trip),
                      onCopy: () {
                        // TODO: Copy code to clipboard.
                      },
                    ),
                    const SizedBox(height: 24),
                    _TripMemberStatsRow(
                      memberCount: trip.memberCount,
                      myRoleText: _myRoleText,
                    ),
                    const SizedBox(height: 24),
                    _MembersSectionHeader(onSort: () {}),
                    const SizedBox(height: 12),
                    AddMemberRow(
                      controller: _addMemberEmailController,
                      isLoading: _isAddingMember,
                      onSubmit: _addMemberByEmail,
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<MemberRowModel>>(
                      future: _membersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Không tải được danh sách thành viên.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                height: 1.3,
                              ),
                            ),
                          );
                        }

                        final members =
                            snapshot.data ?? const <MemberRowModel>[];
                        if (members.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Chưa có thành viên.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                height: 1.3,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (final m in members)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: MemberRow(model: m),
                              ),
                          ],
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTripCode(Trip trip) {
    final fromApi = trip.inviteCode.trim();
    if (fromApi.isNotEmpty) return fromApi;

    final value = trip.id ?? 8392;
    final suffix = value.abs().toString().padLeft(4, '0');
    return 'TRIP-$suffix';
  }

  static List<Map<String, dynamic>> _extractMembersFromMembersResponse(
    Map<String, dynamic> raw,
  ) {
    final data = raw['data'];

    List<dynamic>? list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in const <String>[
        'members',
        'participants',
        'users',
        'data',
      ]) {
        final v = map[key];
        if (v is List) {
          list = v;
          break;
        }
      }
    }

    if (list == null) return const <Map<String, dynamic>>[];

    final out = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        out.add(item);
      } else if (item is Map) {
        out.add(Map<String, dynamic>.from(item));
      }
    }
    return out;
  }

  static Map<String, dynamic>? _extractNestedUser(Map<String, dynamic> member) {
    final nested = member['user'] ?? member['profile'] ?? member['member'];
    if (nested is Map<String, dynamic>) return nested;
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return null;
  }

  static bool? _extractIsActive(
    Map<String, dynamic> member,
    Map<String, dynamic>? user,
  ) {
    final v =
        member['is_active'] ??
        member['isActive'] ??
        user?['is_active'] ??
        user?['isActive'];

    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return null;
  }

  static String? _extractDisplayName(
    Map<String, dynamic> member,
    Map<String, dynamic>? user,
  ) {
    const keys = <String>[
      'name',
      'full_name',
      'fullName',
      'display_name',
      'displayName',
      'username',
      'email',
    ];

    for (final key in keys) {
      final v = member[key] ?? user?[key];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
    }

    return null;
  }

  static String? _extractSubtitle(
    Map<String, dynamic> member,
    Map<String, dynamic>? user,
  ) {
    const keys = <String>['phone', 'phone_number', 'phoneNumber', 'email'];

    for (final key in keys) {
      final v = member[key] ?? user?[key];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
    }
    return null;
  }

  static bool _looksLikeLeaderRole(String role) {
    final r = role.trim().toLowerCase();
    return r == 'leader' ||
        r == 'owner' ||
        r == 'admin' ||
        r == 'host' ||
        r == 'manager' ||
        r == 'trip_leader' ||
        r == 'trưởng nhóm' ||
        r == 'truong nhom' ||
        r == 'truong_nhom' ||
        r == 'group_leader' ||
        r == 'group leader';
  }

  static String? _roleToString(dynamic role) {
    if (role == null) return null;
    if (role is String) return role;

    if (role is Map<String, dynamic>) {
      final v =
          role['name'] ??
          role['title'] ??
          role['code'] ??
          role['role'] ??
          role['type'];
      if (v is String) return v;
      if (v != null) return v.toString();
      return null;
    }

    if (role is Map) {
      final m = Map<String, dynamic>.from(role);
      final v = m['name'] ?? m['title'] ?? m['code'] ?? m['role'] ?? m['type'];
      if (v is String) return v;
      if (v != null) return v.toString();
      return null;
    }

    return role.toString();
  }

  static bool _isLeader(
    Map<String, dynamic> member,
    Map<String, dynamic>? user,
  ) {
    final flags = <dynamic>[
      member['is_leader'],
      member['isLeader'],
      member['is_owner'],
      member['isOwner'],
      user?['is_leader'],
      user?['isLeader'],
      user?['is_owner'],
      user?['isOwner'],
    ];

    for (final v in flags) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true' || s == '1' || s == 'yes') return true;
      }
    }

    final role =
        member['role'] ??
        member['role_name'] ??
        member['roleName'] ??
        user?['role'] ??
        user?['role_name'] ??
        user?['roleName'];
    final roleStr = _roleToString(role);
    if (roleStr != null && _looksLikeLeaderRole(roleStr)) return true;
    return false;
  }

  static String? _extractAvatarUrl(
    Map<String, dynamic> member,
    Map<String, dynamic>? user,
  ) {
    const avatarKeys = <String>[
      'avatar_url',
      'avatarUrl',
      'photo_url',
      'photoUrl',
      'profile_image_url',
      'profileImageUrl',
      'image_url',
      'imageUrl',
    ];

    for (final key in avatarKeys) {
      final v = member[key] ?? user?[key];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null') continue;
      return s;
    }
    return null;
  }
}

class _TripCreator {
  final int? id;
  final String? email;

  const _TripCreator({this.id, this.email});
}

class _MeIdentity {
  final int? id;
  final String? email;

  const _MeIdentity({this.id, this.email});
}
